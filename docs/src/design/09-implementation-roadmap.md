# 09 — Implementation Roadmap

Phased plan with explicit exit criteria. Each phase produces something that works before
the next begins.

> **中文讲解｜CN**
> 本路线图的组织原则：**每个阶段结束时都要有一个"能跑、能验证、能给人看"的东西。**
>
> 最常见的失败模式是"先把架构搭完美再验证"——等到第一次能跑通已经三个月过去，
> 而此时发现某个基础假设错了，全部返工。所以每个阶段都设了 **Exit criteria（出口条件）**，
> 不满足就不进入下一阶段。

---

## Phase −1 — Go public (do this first, this week)

Not a research phase, but it gates the JOSS submission and costs almost nothing.

1. Push the repository to GitHub **as public**, with `LICENSE`, `README.md`,
   `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `CITATION.cff`, CI, and the design docs.
2. Enable Issues and Discussions.
3. Verify all dependency UUIDs by letting `Pkg` resolve them (see the note at the top of
   `Project.toml`).
4. Tag `v0.1.0`; commit regularly from then on.

**Exit criteria:** repository public, CI green, docs building.

> **中文讲解｜CN**
> **这是本路线图里唯一一个"今天就该做"的阶段。**
>
> JOSS 要求仓库**公开满 6 个月且期间有持续开发活动**
> （见 [13 §13.2](13-publication-strategy.md)）。这个时钟只能靠"早点开始"来省，
> 没有任何技术手段能压缩它。
>
> 仓库现在只有文档、没有代码，**这完全不影响公开**——
> 文档提交同样计入开发活动，而且能证明项目是有设计、逐步演进的，
> 反而比"某天突然出现一个完整的包"更符合 JOSS 的期待。
>
> **每推迟一周公开，JOSS 就推迟一周能投。**

---

## Phase 0 — Mechanistic forward model (CPU only)

**Goal:** a correct, tested, Float64 CPU PBPK model. No GPU. No neural network.

Tasks:
1. `ReferenceIndividual` data structure with sourced physiological values ([02 §2.7](02-pbpk-forward-model.md)).
2. Allometric scaling functions; covariate → parameter map.
3. RHS as an out-of-place function using `StaticArrays` **from the start** (retrofitting
   this later is painful).
4. Nondimensionalization layer ([02 §2.8](02-pbpk-forward-model.md)).
5. The six numerical tests of [02 §2.9](02-pbpk-forward-model.md).
6. Stiffness characterization: report $\kappa = \max\tau_i/\min\tau_i$ and solver benchmarks
   (`Tsit5` vs `Rodas5P` vs `QNDF`) for the target parameter range.

**Exit criteria:** all six tests green; stiffness characterized; solver selected.

> **中文讲解｜CN**
> 第 3 点值得强调：**从第一天就用 `StaticArrays` 的 out-of-place 写法。**
>
> 理由：`EnsembleGPUKernel`（布局 A）要求 RHS 必须是零分配、SVector 的。
> 如果 Phase 0 用了普通 `Vector` + in-place 写法，将来要改的时候会牵动整个代码库，
> 而且改的过程中极易引入静默的物理错误。**这个约束几乎零成本（Phase 0 就该这么写），
> 但事后补代价很大。**
>
> 第 6 点的输出直接决定 Phase 2 的架构选择，务必量化，不要凭感觉。

---

## Phase 1 — CPU UDE, small population

**Goal:** the whole method working end-to-end on CPU with $N = 50$.

Tasks:
1. `Lux.jl` network, residual form, zero-init ([03 §3.4](03-ude-formulation.md)).
2. Joint parameter vector as a `ComponentArray`.
3. Objective per [04 §4.4](04-population-inverse-problem.md), full-batch.
4. **Finite-difference gradient check** — build this before the optimizer.
5. Optimization schedule Stages 0–3 ([04 §4.5](04-population-inverse-problem.md)).
6. Twin data generator with mechanism H1, including all corruptions ([07 §7.2](07-validation-protocol.md)).
7. Baselines B0, B1, B3, B4.
8. **Test D — mechanistic-content test** ([06 §6.0](06-identifiability.md)).

**Exit criteria:** on $N=50$, rich sampling, 5% noise, the UDE recovers H1 with
$\mathrm{E}_{\mathrm{mech}} < 20\%$, beats B1 on held-out dose, and **passes Test D**.
Gradient check passes.

> **中文讲解｜CN**
> **Test D 被放进 Phase 1 出口条件，是 2026-08-06 文献修订的直接结果。**
> 理由：如果这个 UDE 其实等价于一个纯 neural ODE，那么后面所有阶段
> （GPU 加速、相图 sweep、真实数据）做的都是无意义的功。
> **这个检验必须在投入大规模计算之前完成，成本很低但排除的风险很大。**

> **中文讲解｜CN**
> **Phase 1 完全不碰 GPU，这是刻意的。**
>
> 理由：如果在 CPU 上、$N=50$ 的小规模下方法就不работ，那上 GPU 只是让错误跑得更快。
> 而且 CPU 上调试成本低得多——可以用调试器、可以打印中间量、可以用 Float64、
> 出问题时不需要区分"是方法错了还是 CUDA 出问题了"。
>
> **第 4 点的顺序不可颠倒：先写有限差分梯度检验，再写优化器。**
> 这在 [05 §5.6](05-gpu-strategy.md) 里已经强调过，这里再说一次是因为它真的最重要。
>
> Phase 1 的出口条件比最终目标宽松（20% 而不是 10%），因为 $N=50$ 信息量本来就有限。
> 关键是**趋势正确**：比误设机理模型好、能在留出剂量上外推。

---

## Phase 2 — GPU, Layout B

**Goal:** the same result, on GPU, at $N = 10^3$–$10^4$.

Tasks:
1. Batched RHS over `CuArray` (Layout B, [05 §5.1](05-gpu-strategy.md)).
2. Float32 policy per [05 §5.4](05-gpu-strategy.md); Float32-vs-Float64 verification test.
3. Reverse-mode gradients: `SciMLSensitivity` + `GaussAdjoint` + `EnzymeVJP`; fallback
   chain documented if Enzyme fails.
4. Repeat the finite-difference gradient check **on GPU** (small $N$, Float64).
5. Scaling benchmark: GPU vs multithreaded CPU, $N \in \{10^2,10^3,10^4\}$; report
   breakeven $N$.
6. Memory profiling; enable checkpointing if required.

**Exit criteria:** GPU result matches CPU result within tolerance at $N=200$;
gradient check passes on GPU; measured speedup and breakeven $N$ reported.

> **中文讲解｜CN**
> 第 4 点容易被忽略但必须做：**GPU 上要重新跑一遍有限差分梯度检验。**
> CPU 上梯度对，不代表 GPU 上梯度对——sensealg 的 GPU 路径、Enzyme 的 CUDA 支持、
> 归约的实现都可能引入不同的错误。用小 $N$ + Float64 在 GPU 上再验一次，几分钟的事。
>
> 第 3 点的"fallback chain"要提前写下来并测试：
> 如果 `EnzymeVJP` 编译失败 → 试 `ReverseDiffVJP(true)` → 试 `ZygoteVJP` → 最差退回 `ForwardDiffSensitivity`。
> **把这条链写进文档和代码注释**，否则半年后你自己都想不起来当时为什么选了某个 sensealg。

---

## Phase 3 — Full twin study

**Goal:** the phase diagram of [07 §7.4](07-validation-protocol.md).

Tasks:
1. Sweep $N \times n_{\mathrm{obs}} \times \sigma$; several seeds per cell.
2. Mechanisms H1, H2, H3.
3. Full diagnostic suite ([06 §6.4](06-identifiability.md)).
4. Symbolic regression with refit verification ([06 §6.5](06-identifiability.md)).
5. Baseline B2 (classical NLME via nlmixr2) added.
6. Coverage-vs-$N$ analysis ([06 §6.6](06-identifiability.md)).

**Exit criteria:** all Part I go/no-go gates in [07 §7.6](07-validation-protocol.md).

> **中文讲解｜CN**
> Phase 3 是**计算量最大的阶段**（几百次完整拟合），也是 GPU 投入真正兑现的地方。
>
> 建议：每个 sweep 单元跑 **3–5 个随机种子**，报告均值和离散度。
> 单次运行的结果在这类研究里说服力很弱——优化有随机性、数据生成有随机性，
> 没有重复就区分不出"方法更好"和"这次运气好"。
>
> 另外 Phase 3 要做好**实验管理**：几百次运行的配置、结果、随机种子必须可追溯。
> 建议每次运行输出一个带完整配置哈希的结果文件，否则到写论文时你会分不清哪张图是哪个配置跑的。

---

## Phase 4 — Real data + methodological upgrades

Tasks:
1. Dataset acquisition and license verification (**start this in Phase 1** — it has the
   longest lead time).
2. Reproduce the published NLME analysis ([07 §7.9](07-validation-protocol.md) step 1).
3. mPBPK reduction (R1); R2 as sensitivity analysis.
4. Laplace/FOCE objective (S2) to quantify the bias of joint MAP (S1).
5. **Variational EM (S3)** — the marginal-likelihood-correct upgrade path
   ([04 §4.3](04-population-inverse-problem.md), revised).
6. Full-Bayes HMC on $N \le 30$ subset as an uncertainty reference (S4).
7. Multiple dosing / oral absorption with callbacks, if the dataset requires it.
8. Interoperability path to NoLimits.jl as an inference backend
   ([12 §12.2](12-package-design.md)).

> **中文讲解｜CN**
> **第 1 点必须提前到 Phase 1 就开始做，这是本路线图里最容易出事的地方。**
>
> 数据获取的周期长、不确定性大：可能要注册账号、可能要签数据使用协议、
> 可能发现"公开"的数据其实只有汇总统计而没有个体数据、可能许可证不允许发表。
> 这些问题如果到 Phase 4 才发现，整个真实数据研究就要推倒重来。
>
> **具体建议：Phase 1 期间就去把数据下载下来、打开看一眼、确认里面确实有个体级的
> 浓度-时间记录和协变量、确认许可证。** 这件事花不了两天，但能避免几个月的风险。

---

## Phase 5 — Optional extensions

Only if Phases 0–4 are complete:
- Layout A (`EnsembleGPUKernel`) with mixed-mode differentiation ([05 §5.3](05-gpu-strategy.md)) as a performance study.
- Permeability-limited compartments ([02 §2.4](02-pbpk-forward-model.md)).
- Amortized inference (S3).
- Time-dependent enzyme dynamics (closure target C).

---

## Risk Register

| # | Risk | Likelihood | Impact | Mitigation | Trigger for fallback |
|---|---|---|---|---|---|
| R1 | Enzyme/CUDA/Lux version incompatibility | **High** | High | Pin versions; commit `Manifest.toml`; documented VJP fallback chain | Any gradient check failure attributable to AD |
| R2 | Adjoint unusable through GPU ensemble | Medium | High | Layout B is the primary path; Layout A forward-only | Phase 2 gradient check fails on GPU |
| R3 | System too stiff for explicit GPU solvers | Medium | High | Characterized in Phase 0; use `GPURosenbrock23`, or reduce $\kappa$ by lumping fast compartments | $\kappa > 10^4$ |
| R4 | Closure not identifiable even in the twin study | **High** | **Very high** | This is a *result*, not a failure — the phase diagram *is* the contribution | $\mathrm{E}_{\mathrm{mech}} > 50\%$ at the easiest setting |
| R5 | No suitable public nonlinear-PK dataset | Medium | Medium | Verify in Phase 1; fall back to preclinical tissue data (R3) or a purely synthetic study | License or data-content check fails |
| R6 | GPU speedup smaller than expected | Medium | Low | Report the breakeven $N$ honestly; the scientific results do not depend on the speedup | Breakeven $N > 10^4$ |
| R7 | Scope creep into 3D hemodynamics / PD modelling | Medium | Medium | Scope boundaries in README; Phase 5 gating | — |
| R8 | Float32 precision insufficient | Low | Medium | Nondimensionalization first; selective Float64 | Float32-vs-Float64 test fails after nondimensionalization |
| R9 | JOSS 6-month public-repo clock not started | **Certain if delayed** | Medium | **Phase −1: go public now** | Any day the repo is still private |
| R10 | UDE turns out to be observationally equivalent to a neural ODE | Medium | **Very high** | Test D in Phase 1; narrow $\mathbf{z}$, tighten placement and structural constraints | Test D fails |
| R11 | A competing package or paper closes the gap mid-project | Medium | Medium | Early arXiv preprint; re-run the literature sweep before each submission | New package/paper found in a sweep |

> **中文讲解｜CN**
> **R4 需要重新理解一下，它是本项目最重要的风险管理决定。**
>
> "闭合项在孪生实验里也学不回来" ——直觉上这是项目失败。但实际上：
>
> > **"在什么条件下学不回来"本身就是本课题要回答的问题。**
>
> 只要相图画得扎实、诊断做得清楚、原因分析得明白（是数据密度不够？噪声太大？
> 还是存在结构不可辨识？），一个以负面结果为主的相图**依然是一篇合格的方法学论文**，
> 而且比"我们在一个精心挑选的设置下成功了"更有长期价值。
>
> 所以 R4 的缓解措施不是"想办法让它成功"，而是**从一开始就把研究问题表述为
> "何时可行"而不是"我们做到了"**。这个表述上的选择，决定了负面结果是灾难还是成果。
>
> 同理 **R6**：如果 GPU 加速比不如预期，诚实报告盈亏平衡点即可——
> 本项目的科学结论（相图、机制恢复）**不依赖于加速比有多大**。
> 把科学结论和工程结论解耦，是降低整体风险的关键设计。

---

## Version Pinning

Record in `Project.toml` and commit `Manifest.toml`. Before starting, verify mutual
compatibility of the AD/GPU stack — this combination is the most fragile part of the
ecosystem and compatible version sets change frequently.

Suggested procedure:
1. Create the environment and resolve.
2. Run a minimal end-to-end smoke test: tiny ODE + tiny Lux network + `GaussAdjoint` +
   `EnzymeVJP` on GPU, gradient-checked against finite differences.
3. **Only then** commit the `Manifest.toml` as the known-good baseline.
4. Re-run the smoke test after any dependency update; never update mid-experiment.

> **中文讲解｜CN**
> Julia SciML 生态里 **AD + GPU 的组合是最脆弱的一环**，版本兼容性经常变。
>
> 强烈建议按上面四步走，其中第 2 步的"最小冒烟测试"要单独写成一个几十行的脚本：
> 一个 2 维玩具 ODE + 一个 3 层小网络 + GPU + 你选定的 sensealg + 有限差分校验。
>
> 这个脚本的价值在于：**当主程序出问题时，你可以先跑冒烟测试，
> 五秒钟就知道是环境坏了还是自己的代码坏了。** 没有它，你会花大量时间
> 在一个几千行的程序里找一个其实是包版本导致的问题。
>
> 还有一条纪律：**实验进行中绝不更新依赖。** 一次 `Pkg.update()` 可能让你之前跑的
> 所有结果不可复现。要更新就在阶段之间做，并重跑冒烟测试和梯度检验。

---

## Interface Contracts (for your implementation)

Types and signatures only — no implementations, as agreed.

```julia
# ─── Physiology ───────────────────────────────────────────────────────────
struct ReferenceIndividual              # sourced anatomical/physiological values
struct Covariates                       # BW, age, sex, genotype, creatinine, ...
struct IndividualParams                 # concrete V, Q, Kp, CL for one subject

scale_physiology(::ReferenceIndividual, ::Covariates, η) -> IndividualParams

# ─── Model ────────────────────────────────────────────────────────────────
struct PBPKTopology                     # graph: which compartment drains where
struct PBPKProblem                      # topology + nondimensionalization + dosing

pbpk_rhs!(du, u, p, t)                  # mechanistic only,  SVector, allocation-free
ude_rhs!(du, u, p, t)                   # mechanistic + Sᵀ·N_φ(z)
closure_input(u, p, t)     -> z         # the ONLY place z is defined
closure_apply(nn, φ, z, p) -> ΔR        # includes softplus + multiplicative C factor

# ─── Ensemble ─────────────────────────────────────────────────────────────
struct Population                       # N individuals: covariates, doses, obs times
build_ensemble(::Population, ::PBPKProblem, H, φ)  -> EnsembleProblem
solve_population(...)                   -> Array{Float32,3}   # (states, N, saveat)

# ─── Inference ────────────────────────────────────────────────────────────
struct ObservationModel                 # h(u), σ_add, σ_prop, LOQ  (BLQ handling)
struct HierarchicalPrior                # Ω, θ_pop, covariate model
objective(Θ, ::Population, ::ObservationModel, ::HierarchicalPrior) -> Float64
gradient!(g, Θ, ...)                    # dispatch on sensealg

# ─── Analysis ─────────────────────────────────────────────────────────────
support_density(::Population, sol)      -> ρ(z)      # empirical support
profile_likelihood(Θ̂, index, grid)     -> Vector
fisher_information(Θ̂, ...)             -> Matrix
eta_shrinkage(Ĥ, Ω̂)                     -> Vector
ablation_test(...)                      -> NamedTuple
recover_symbolic(nn, φ, ρ)              -> ParetoFront
```

Two contracts to enforce in code review:

- **`closure_input` is the only definition of $\mathbf{z}$.** Every place that needs the
  network's input — the RHS, the support-density calculation, the plotting, the symbolic
  regression — calls this one function. Duplicating the definition is how the "learned
  curve" and the "curve actually used in the ODE" silently diverge.
- **Every $\pm$ paired transfer term is computed once and applied twice with opposite
  sign.** Never write the same expression in two equations.

> **中文讲解｜CN**
> 最后这两条契约是**血泪经验级别的建议**：
>
> 1. **$\mathbf{z}$ 的定义只能有一处（`closure_input`）。**
>    RHS 用它、算支撑密度用它、画图用它、符号回归用它——全都调同一个函数。
>    如果画图时重新写了一遍 $z$ 的计算（比如忘了取 log、忘了无量纲化），
>    你画出来的"学到的曲线"和 ODE 里真正在用的曲线就不是同一个东西，
>    **而且这个错误不会报错，只会让你得出错误的科学结论。**
>
> 2. **成对的 $\pm$ 传递项只算一次、加减各用一次。**
>    如果在组织方程和血池方程里各写一遍同样的表达式，日后改动其中一个而忘了另一个，
>    质量守恒就被破坏了——而且只有在你正好做守恒检验时才会发现。
>
> 这两条都属于"写代码时多花两分钟，能省下两周调试"的类型。

---

**Next:** [10 — References & Data Sources](10-references.md) ·
[11 — Literature Landscape](11-literature-landscape.md) ·
[12 — Package Design](12-package-design.md) ·
[13 — Publication Strategy](13-publication-strategy.md)
