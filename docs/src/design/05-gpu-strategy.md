# 05 — GPU Strategy

This is the engineering core of the project. The central question: **how do you compute
$\nabla_{\boldsymbol{\phi},\mathbf{H}} J$ for $N$ ODE trajectories on a GPU, correctly and
fast?**

---

## 5.1 Two fundamentally different ensemble layouts

There are two ways to put $N$ ODE systems on a GPU, and they are *not* interchangeable.
Choosing between them is the single most consequential architectural decision in the
project.

### Layout A — "Many small solvers" (`EnsembleGPUKernel`)

Each GPU thread runs its **own complete ODE solver** for one individual, with its own
adaptive step-size controller.

```
thread 0 ──► solve individual 1  (own dt, own steps)
thread 1 ──► solve individual 2  (own dt, own steps)
   ...
thread N ──► solve individual N
```

- Requires the RHS to be **kernel-compatible**: out-of-place, `StaticArrays`/`SVector`,
  no heap allocation, no dynamic dispatch, no `Base` functions that allocate.
- Per-trajectory adaptivity: individuals that are easy finish in few steps.
- Solvers: `GPUTsit5`, `GPUVern7` (non-stiff); `GPURosenbrock23`, `GPUKvaerno3` (stiff,
  more restricted).
- **Differentiation is the hard part.** Forward-mode (`ForwardDiff.Dual` inside the
  kernel) works and is well-trodden. Reverse-mode/adjoint through the kernel solver is
  fragile and, depending on package versions, may not work at all.
- Thread divergence: if individuals need very different numbers of steps, warps stall.

### Layout B — "One big vectorized system" (batched RHS over `CuArray`)

Concatenate all individuals into a single ODE of dimension $N \times n$, with the RHS
written as a vectorized/broadcast kernel over a $n \times N$ `CuArray`, and solve it with a
**single standard solver** from `OrdinaryDiffEq.jl`.

```
state U ∈ R^{n × N}   (column j = individual j)
dU/dt = F(U, Θ)       one fused broadcast kernel
one solver, one shared adaptive dt for the entire batch
```

- The RHS is ordinary Julia broadcasting over `CuArray`s — much easier to write and debug.
- **Reverse-mode adjoint works normally** (`SciMLSensitivity.jl` with
  `GaussAdjoint`/`InterpolatingAdjoint` and `EnzymeVJP`), because this is just a large ODE.
- **Shared time-stepping is the cost:** the step size is dictated by the single hardest
  individual in the batch. If the population contains a few very stiff individuals, all
  $N$ pay for them.
- Memory: the adjoint requires storing or recomputing the forward solution — $O(N \cdot n
  \cdot n_{\mathrm{steps}})$ if stored. Checkpointing is mandatory at scale.

> **中文讲解｜CN**
> **这是全项目最关键的架构选择，请务必看懂两种布局的本质区别。**
>
> | | 布局 A：多个小求解器 | 布局 B：一个大向量化系统 |
> |---|---|---|
> | 并行粒度 | 一个线程 = 一个完整求解器 | 一个大 ODE，$N$ 是"空间维度" |
> | 时间步长 | **每个个体独立自适应** | **全批量共享一个步长** |
> | RHS 写法 | 必须 kernel 兼容（SVector、零分配） | 普通 CuArray 广播，好写好调 |
> | 前向 AD | 成熟可用 | 可用 |
> | 反向 AD / 伴随 | **脆弱，可能不可用** | **正常可用** |
> | 主要代价 | 线程发散（步数差异大时 warp 停顿） | 最刚性的个体拖慢所有人 |
>
> 类比 CFD：
> - 布局 A ≈ **每个网格块跑自己的局部时间步（local time stepping）**；
> - 布局 B ≈ **全场统一时间步的显式推进**。
>
> 你在 CFD 里知道，local time stepping 快但只对定常问题合法、且实现复杂；
> 全局统一步长慢但简单可靠。这里的取舍结构完全一样。
>
> **建议：Phase 1 先用布局 B 把整条链路（正向 + 梯度 + 优化）打通并跑出正确结果，
> 再评估布局 A 能带来多少加速。** 反过来做的话，你极可能在"伴随穿不过 GPU kernel"
> 这个问题上卡住好几周，而那时你连一个正确的基线结果都还没有。

---

## 5.2 Recommended decision procedure

Do not guess. Measure, in this order:

1. **Characterize stiffness** (from [02 §2.9](02-pbpk-forward-model.md)). Compute
   $\kappa = \max_i \tau_i / \min_i \tau_i$ over the population's parameter range.
2. If $\kappa \lesssim 10^2$: explicit solvers are viable → both layouts open.
   If $\kappa \gtrsim 10^3$: you need a stiff solver, which sharply restricts Layout A.
3. Measure **step-count dispersion** across individuals with a CPU ensemble. If the ratio
   $\max_j n_{\mathrm{steps},j} / \mathrm{median}_j$ is large, Layout A wins more; if it is
   near 1, Layout B loses little.
4. Build Layout B first. Establish correctness and a wall-clock baseline.
5. Then port to Layout A **for the forward solve only**, and benchmark. Only if the
   speedup is >3× is it worth solving the reverse-mode problem for Layout A.

> **中文讲解｜CN**
> 步骤 3 值得强调：**先在 CPU 上跑一遍 ensemble，统计每个个体需要多少积分步。**
> 如果各个体步数差不多（比值接近 1），布局 B 几乎不损失什么，直接用它；
> 如果差异巨大（比如有 5% 的个体需要 10 倍步数），布局 A 的优势才显现。
>
> 这个测量成本极低（CPU 上几分钟），但能省下几周的架构返工。**不要跳过。**

---

## 5.3 Mixed-mode differentiation — the key idea

Recall the asymmetry from [00 §4](00-glossary.md):

$$
\underbrace{\boldsymbol{\eta}_j \in \mathbb{R}^{3\text{–}6}}_{\text{per-individual, few}} \qquad \underbrace{\boldsymbol{\phi} \in \mathbb{R}^{10^2\text{–}10^3}}_{\text{global, many}}
$$

Naive choices are both wasteful:

- **All forward-mode:** cost $\propto (N d_\eta + |\boldsymbol{\phi}|)$ — the
  $|\boldsymbol{\phi}|$ term dominates and kills it.
- **All reverse-mode:** must build a tape covering all $N$ trajectories to get the
  $\boldsymbol{\eta}$ gradients, most of which is redundant since
  $\partial J_j / \partial \boldsymbol{\eta}_{j'} = 0$ for $j \ne j'$.

**Mixed strategy.** For each individual $j$, the local sensitivity system is

$$
\frac{d}{dt}\frac{\partial \mathbf{u}_j}{\partial \boldsymbol{\eta}_j} = \mathbf{J}_j \frac{\partial \mathbf{u}_j}{\partial \boldsymbol{\eta}_j} + \frac{\partial f}{\partial \boldsymbol{\eta}_j}
$$

which is $d_\eta$ extra ODE systems — cheap, embarrassingly parallel per individual,
computed by forward mode inside the individual's own thread/column. Meanwhile
$\boldsymbol{\phi}$'s gradient is accumulated by a **single reverse pass whose adjoint
state is shared across the batch**:

$$
\nabla_{\boldsymbol{\phi}} J = \sum_{j=1}^N \int_{T}^{0} \boldsymbol{\lambda}_j(t)^\top \frac{\partial f_j}{\partial \boldsymbol{\phi}} \, dt .
$$

The adjoint ODEs $\boldsymbol{\lambda}_j$ are themselves an $N$-way ensemble — again a
perfect GPU workload — and the $\boldsymbol{\phi}$-gradient is a reduction over $j$.

> **中文讲解｜CN**
> **这是本课题在方法层面最有"技术含量"的一点，也是最值得写进论文的一点。**
>
> 核心观察：两类参数的维度结构完全不同，所以应该用**不同的微分模式**：
>
> $$\boldsymbol{\eta}_j:\ \text{每人 3–6 维} \Rightarrow \textbf{前向模式}\quad\quad \boldsymbol{\phi}:\ \text{全局 } 10^2\text{–}10^3 \text{ 维} \Rightarrow \textbf{反向模式（伴随）}$$
>
> - 全用前向：代价正比于 $N d_\eta + |\boldsymbol{\phi}|$，被 $|\boldsymbol{\phi}|$ 拖死；
> - 全用反向：为了拿 $\boldsymbol{\eta}$ 的梯度要给全部 $N$ 条轨迹建磁带，
>   而其中绝大部分是冗余的（个体之间没有耦合，$\partial J_j/\partial\boldsymbol{\eta}_{j'}=0$）。
>
> 混合方案：**在每个个体内部用前向灵敏度方程解出 $\partial\mathbf{u}_j/\partial\boldsymbol{\eta}_j$
> （$d_\eta$ 个附加 ODE，天然并行），同时用一次伴随反传得到 $\nabla_{\boldsymbol{\phi}}J$
> （伴随方程本身也是 $N$ 路 ensemble，最后对 $j$ 求和归约）。**
>
> 这在 CFD 里有直接对应：**伴随法用于多设计变量、前向灵敏度用于少参数**，
> 是气动优化里的常识性取舍。你把它用在了"个体参数 vs 共享闭合项"这个新的结构上。
>
> ⚠️ 工程提醒：混合模式实现复杂度显著高于单一模式。
> **建议 Phase 1 先全用一种模式跑通（哪种能跑通用哪种），把混合模式作为 Phase 2 的性能优化，
> 并把加速比作为论文的一个定量结果。** 不要一上来就写最复杂的方案。

---

## 5.4 Precision

Float32 is roughly 2× (consumer GPUs: up to 32–64×) faster than Float64. But PBPK
trajectories span decades in concentration and the terminal phase carries the clearance
information.

Policy:

| Quantity | Precision | Reason |
|---|---|---|
| ODE state, RHS, network forward pass | Float32 | Bandwidth-bound; fine **after** nondimensionalization |
| Solver tolerances | `reltol=1e-4, abstol=1e-6` (nondim) | Float32 cannot support tighter |
| Loss accumulation / reduction over $N$ | Float64 | Catastrophic cancellation in a sum over $10^4$ terms |
| Optimizer state (Adam moments, L-BFGS) | Float64 | Small; parameter updates must not be lost to rounding |
| Reference/verification solve | Float64 CPU | Ground truth for the Float32 check |

**Mandatory test:** for a sample of ~50 individuals, the Float32 GPU plasma trajectory must
match the Float64 CPU trajectory to a stated relative tolerance. Rerun this test after
every change to the RHS.

> **中文讲解｜CN**
> 精度策略是 GPU 科学计算最容易出隐性错误的地方，把规则写死：
>
> - **状态、RHS、网络前向：Float32**——这是性能来源，但**前提是已经做过无量纲化**（[02 §2.8](02-pbpk-forward-model.md)）。
>   没做无量纲化就用 Float32，误差控制会在浓度跨越几个数量级时失效。
> - **对 $N$ 求和的损失累加：Float64**——$10^4$ 项相加时 Float32 会发生灾难性相消。
>   这一步计算量很小，用 Float64 几乎不影响性能，但用 Float32 会让梯度带上系统性噪声。
> - **优化器状态：Float64**——Adam 的动量、L-BFGS 的历史都很小，
>   但如果参数更新量小于 Float32 的舍入误差，优化会**静默地停滞**（loss 不降但也不报错）。
>
> 最后一条特别阴险：训练"卡住不降"的时候，人的第一反应是调学习率、改架构，
> 很少有人想到是 Float32 精度吃掉了参数更新。**提前把优化器状态设成 Float64，省掉这一整类调试。**
>
> 并且：**每次改动 RHS 之后都要重跑 Float32-vs-Float64 一致性测试。** 写成 CI 测试。

---

## 5.5 Memory budget

Rough sizing for the forward solve:

$$
M_{\mathrm{fwd}} \approx N \times n \times n_{\mathrm{save}} \times 4\ \text{bytes}
$$

With $N = 10^4$, $n = 16$, $n_{\mathrm{save}} = 200$: $\approx 128$ MB. Trivial.

The adjoint is the problem. `InterpolatingAdjoint` with a stored dense forward solution
needs $n_{\mathrm{steps}}$ (not $n_{\mathrm{save}}$) time points, which can be $10^3$–$10^4$:

$$
M_{\mathrm{adj}} \approx N \times n \times n_{\mathrm{steps}} \times 4 \approx 0.6\text{–}6\ \text{GB}
$$

Mitigations, in order of preference:

1. **`GaussAdjoint`** — quadrature-based, avoids storing the parameter-gradient integrand
   trajectory; generally the best default for large parameter counts.
2. **Checkpointed `InterpolatingAdjoint`** — store every $k$-th step, recompute between.
   Classic time–memory trade-off; identical to checkpointing in unsteady adjoint CFD.
3. **Reduce $N$ per gradient step** (mini-batch) — last resort, see [04 §4.6](04-population-inverse-problem.md).

> **中文讲解｜CN**
> 正向求解的显存需求微不足道（~128 MB），**瓶颈永远在伴随**。
>
> 原因：伴随反传需要在反向积分时访问正向解，而正向解要按**实际积分步**（可能上万步）
> 而不是按保存点（几百点）存储 → 显存需求放大一到两个数量级。
>
> 三个缓解手段，优先级从高到低：
> 1. **`GaussAdjoint`**：基于求积公式，不需要存参数梯度被积函数的完整轨迹，
>    对大参数量场景通常是最佳默认选择；
> 2. **检查点化的 `InterpolatingAdjoint`**：每 $k$ 步存一次、中间重算 —
>    **这就是非定常伴随 CFD 里的 checkpointing，完全一样的时间-空间权衡**，你已有的直觉可以直接用；
> 3. 减小每步梯度的 $N$（分批）——最后手段。
>
> 建议在实现里把 sensealg 做成可配置项，这样三种方案可以直接对比并写进论文的性能分析。

---

## 5.6 Known engineering hazards

These are the things most likely to consume weeks. Read before writing code.

| Hazard | Symptom | Mitigation |
|---|---|---|
| Enzyme + CUDA + Lux version incompatibility | Compilation errors, wrong gradients, segfaults | Pin all versions in `Project.toml`; keep a working `Manifest.toml` committed; have `Zygote`+`ReverseDiff` as fallback VJP |
| Adjoint through `EnsembleGPUKernel` | Method errors or silently wrong gradients | Use Layout B for gradients; Layout A for forward-only |
| Silent gradient error | Loss plateaus, or optimization diverges | **Finite-difference gradient check** on a small case ($N=4$) — non-negotiable, run in CI |
| Callbacks (dosing) on GPU | Unsupported or incorrect on some backends | Phase 1: single IV bolus as initial condition, no callbacks |
| Stiffness from a bad $\boldsymbol{\phi}$ | Solver `maxiters` exceeded, `dtmin` warnings, NaN loss | Residual-form + zero-init network; clamp network output; use `verbose=false` + return `Inf` loss on failure so the optimizer backs off |
| Thread divergence | GPU utilization low despite large $N$ | Sort individuals by expected stiffness before batching |
| `NaN` propagating through AD | Gradient is `NaN` but forward solve looks fine | Guard `log`/`softplus` arguments; never `log(0)`; use `log1p`/`softplus` stable forms |
| Non-reproducibility | Results change between runs | Fix RNG seeds; note that GPU atomic reductions are non-deterministic — accumulate the loss deterministically |

**The finite-difference gradient check is the highest-value test in this entire project.**
Build it before the optimizer.

> **中文讲解｜CN**
> 整张表里如果只能记住一条，记这条：
>
> > **在写优化器之前，先写有限差分梯度检验。**
>
> 具体做法：取 $N=4$ 个个体、极小的网络，用中心差分
> $$\frac{\partial J}{\partial \phi_i} \approx \frac{J(\phi_i + h) - J(\phi_i - h)}{2h}$$
> 逐个分量与 AD 给出的梯度对比，要求相对误差 $< 10^{-4}$（用 Float64 做这个检验）。
>
> 为什么这条最重要：**梯度错误是本项目最危险的失败模式，因为它不报错。**
> 程序照常运行、loss 照常下降一点然后卡住，你会以为是超参数问题、是模型容量问题、
> 是数据问题，可能会浪费几周去调完全无关的东西。有了这个检验，
> 一旦 AD 链路出问题（版本不兼容、sensealg 选错、kernel 里有不可微操作），
> 你在五分钟内就知道。
>
> 另外两条值得展开：
> - **`dtmin` 警告 / `maxiters` 超限 = 网络把系统推刚性了。** 处理方式不是调大 `maxiters`，
>   而是让求解失败时返回 `Inf` 损失，优化器自然会退回去。这相当于给优化加了一道
>   "物理可行性"约束。
> - **GPU 上的原子归约不是确定性的**（浮点加法不满足结合律）。
>   如果你需要可复现结果，损失的求和必须用确定性的归约方式。

---

## 5.7 Benchmark plan

Performance claims must be measured, not asserted. Report:

1. **Strong scaling in $N$:** wall-clock per gradient evaluation vs.
   $N \in \{10^2, 10^3, 10^4\}$, for GPU Layout A, GPU Layout B, and multithreaded CPU
   ensemble.
2. **Breakeven $N$:** the population size at which GPU overtakes CPU. Report it honestly —
   it will not be small.
3. **Gradient-mode comparison:** forward-only vs. adjoint-only vs. mixed, at fixed $N$.
4. **Precision cost:** Float32 vs Float64 wall-clock *and* accuracy.
5. **End-to-end:** total time to converged fit, GPU vs. CPU vs. a reference NLME tool
   (nlmixr2/Pumas FOCEI) on the same dataset. This is the number a PK audience cares about.

Report hardware, versions, and whether timings include compilation.

> **中文讲解｜CN**
> 第 2 项**必须诚实报告**：GPU 相对 CPU 的**盈亏平衡点 $N$**。
>
> 小规模时 GPU 一定更慢（kernel 启动开销、数据传输、编译时间）。
> 如果你只报告 $N=10^4$ 时的加速比而不说盈亏点，是有误导性的，也很容易被审稿人识破。
> 相反，**明确给出"$N > N^*$ 时 GPU 才划算，$N^* \approx \ldots$"，是更强的结果**——
> 它说明你理解自己方法的适用边界。
>
> 第 5 项是给药代动力学读者看的：他们不关心你一次梯度算多快，
> 只关心"跑完一个完整拟合要多久，比 NONMEM/nlmixr2 快多少"。两类数字都要报。
>
> 另外 Julia 特有的坑：**计时一定要说明是否包含编译时间（JIT）。**
> 第一次调用的耗时可能是后续的几十倍。用 `BenchmarkTools.jl`，并明确写出你报告的是哪一种。

---

**Next:** [06 — Identifiability](06-identifiability.md)
