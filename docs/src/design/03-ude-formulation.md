# 03 — UDE Formulation

Where the neural network goes, what it may and may not do, and how to keep it physical.

---

## 3.1 The general form

$$
\frac{d\mathbf{u}}{dt} \;=\; f_{\mathrm{known}}(\mathbf{u}, \boldsymbol{\theta}_j, t) \;+\; \mathbf{S}\,\mathcal{N}_{\boldsymbol{\phi}}\!\big(\mathbf{z}(\mathbf{u}, \boldsymbol{\theta}_j, t)\big)
$$

Three objects must be specified, and each is a modelling decision with consequences:

| Object | Meaning | Design question |
|---|---|---|
| $\mathbf{z}$ | Network **inputs** | What is the closure allowed to depend on? |
| $\mathcal{N}_{\boldsymbol{\phi}}$ | The network itself | Architecture, output transform, size |
| $\mathbf{S}$ | **Stoichiometry / placement matrix** | Where in the network does the term act, and with what sign? |

$\mathbf{S}$ is where physics is enforced. It is a fixed, hand-written matrix, never
learned.

> **中文讲解｜CN**
> 请把 UDE 的设计拆成三个独立的决策，不要混在一起想：
> 1. **$\mathbf{z}$：网络能看到什么？** 这决定了闭合项的"因果范围"。给得太多 → 不可辨识；
>    给得太少 → 学不到东西。
> 2. **$\mathcal{N}_{\boldsymbol{\phi}}$：网络本身。** 架构其实是三者中最不重要的。
> 3. **$\mathbf{S}$：网络的输出加到哪几个方程上、什么符号？** ——**这里是物理的入口。**
>
> $\mathbf{S}$ 是**手写的固定矩阵，绝不学习**。它编码了"这个未知机制是一个从肝房室到消除池的
> 单向质量流"这类结构性先验。这与 CFD 中"雷诺应力必须以散度形式进入动量方程"是同一类约束：
> 我们不知道闭合项的**大小**，但我们完全知道它在方程中的**位置和守恒角色**。

---

## 3.2 Candidate closure targets, in priority order

### Target A — Hepatic elimination (Phase 1, the primary target)

Replace $R_{\mathrm{hep}}$ entirely:

$$
R_{\mathrm{hep}} \;=\; V_{\mathrm{li}}\, C_{u,\mathrm{li}} \cdot \mathrm{softplus}\big(\mathcal{N}_{\boldsymbol{\phi}}(\log \tilde{C}_{u,\mathrm{li}})\big)
$$

Read this carefully — every factor is doing work:

- **$\times\, C_{u,\mathrm{li}}$** enforces $R_{\mathrm{hep}}(0) = 0$ exactly. No drug, no
  metabolism. Without this, the network can produce a nonzero elimination rate at zero
  concentration, which destroys the terminal phase and violates the physics.
- **$\mathrm{softplus}$** enforces $R_{\mathrm{hep}} \ge 0$. Elimination is a sink, never a
  source.
- **$\log \tilde{C}$ as input** matches the concentration range spanned by PK data
  (typically 3–4 decades) to the network's effective input range.
- The network therefore learns the **effective clearance as a function of concentration**,
  $\mathrm{CL}_{\mathrm{eff}}(C)$, not the rate itself. The nominal Michaelis–Menten model
  corresponds to $\mathrm{CL}_{\mathrm{eff}}(C) = V_{\max}/(K_m + C)$, which is a simple
  monotone decreasing curve — easy to plot, easy to compare against.

> **中文讲解｜CN**
> **这个构造是全文档最重要的一段，请逐个因子理解。**
>
> 把 $R_{\mathrm{hep}}$ 写成 $C_u \times \mathrm{softplus}(\mathcal{N}(\log C_u))$ 而不是直接
> $\mathcal{N}(C_u)$，带来三个硬约束：
>
> | 因子 | 强制的物理性质 | 不加会怎样 |
> |---|---|---|
> | $\times C_u$ | $R(0)=0$，零浓度零代谢 | 网络可能在 $C=0$ 时给出非零消除率，终末相彻底崩坏 |
> | $\mathrm{softplus}$ | $R \ge 0$，消除只能是汇 | 网络可能"制造"药物，质量守恒被破坏 |
> | $\log$ 输入 | 匹配 PK 数据跨 3–4 个数量级的浓度范围 | 网络在低浓度区完全没有分辨率 |
>
> 结果是：**网络实际学的是"有效清除率 $\mathrm{CL}_{\mathrm{eff}}(C)$"这个一维函数。**
> 名义米氏模型对应 $\mathrm{CL}_{\mathrm{eff}}(C) = V_{\max}/(K_m+C)$，是一条简单的单调下降曲线。
> 所以最终验证时，你可以把"学到的曲线"和"真实曲线"画在同一张图上直接对比——
> 这就是本课题的核心结果图。
>
> 这套"用乘法因子和输出变换把硬约束焊进网络结构"的做法，与 CFD 中
> "构造保证可实现性(realizability)的湍流模型"是同一种思想。

### Target B — Tissue distribution correction (Phase 3)

$$
V_i \frac{dC_i}{dt} = Q_i\left(C_{\mathrm{art}} - \frac{C_i}{K_{p,i}^{\mathrm{app}}}\right) + \underbrace{V_i\,\mathcal{N}^{(i)}_{\boldsymbol{\phi}}\!\left(\tilde{C}_{\mathrm{art}}, \tilde{C}_i\right)}_{\text{net transporter flux}}
$$

**Mandatory pairing:** the identical term must be subtracted from the arterial or venous
pool, so the correction is a *transfer*, not a *creation*:

$$
V_{\mathrm{ven}} \frac{dC_{\mathrm{ven}}}{dt} = \dots - V_i\,\mathcal{N}^{(i)}_{\boldsymbol{\phi}}(\cdot) .
$$

Additionally impose the equilibrium condition $\mathcal{N}^{(i)}_{\boldsymbol{\phi}} = 0$
whenever $C_{\mathrm{art}} = C_i / K_{p,i}^{\mathrm{app}}$, e.g. by the construction

$$
\mathcal{N}^{(i)}_{\boldsymbol{\phi}}(\cdot) = \left(C_{\mathrm{art}} - \frac{C_i}{K_{p,i}^{\mathrm{app}}}\right) \cdot g_{\boldsymbol{\phi}}(\cdot)
$$

which makes the network learn a *concentration-dependent effective permeability* $g$.

> **中文讲解｜CN**
> Target B 有两条不可妥协的约束：
> 1. **必须成对出现。** 加到组织房室上的项，必须原样从血池中减掉。
>    否则网络就在"凭空创造药物"，质量守恒立刻破坏。
>    实现上建议把这一项算一次、加一次、减一次，**绝不允许写两次同样的表达式**（会出现不一致的隐性 bug）。
> 2. **必须在平衡点为零。** 用因式分解 $(C_{\mathrm{art}} - C_i/K_p) \cdot g_{\boldsymbol{\phi}}$ 强制满足。
>    这样网络学的是"浓度相关的有效渗透率"，而不是一个可以随便漂移的加性项。
>
> 第 2 条同时解决了一个隐蔽的可辨识性问题：如果不做因式分解，网络可以通过在平衡点加一个常数
> 来伪装成 $K_p$ 的改变，于是 $\boldsymbol{\phi}$ 和 $K_p$ 完全混淆。

### Target C — Time-dependent enzyme dynamics (stretch goal)

Add an enzyme-amount state $E(t)$ with

$$
\frac{dE}{dt} = k_{\mathrm{syn}} - k_{\mathrm{deg}} E + \mathcal{N}_{\boldsymbol{\phi}}(E, C_{u,\mathrm{li}}),
\qquad R_{\mathrm{hep}} \propto E \cdot \mathrm{CL}_{\mathrm{eff}}(C_{u,\mathrm{li}}) .
$$

This is only identifiable from **multiple-dose, long-duration** data. Do not attempt it
with single-dose data.

---

## 3.3 What the network must *not* be allowed to do

| Forbidden | Why | Enforcement |
|---|---|---|
| Create mass | Violates conservation | Paired $\pm$ terms; $\mathbf{S}$ has zero column sums for transfer terms |
| Produce negative elimination | Elimination is a sink | `softplus` / `exp` output transform |
| Be nonzero at $C=0$ | Destroys terminal phase | Multiplicative $C$ factor |
| Depend on the individual's identity $j$ | Would memorize, not generalize | $\boldsymbol{\phi}$ shared; $\mathbf{z}$ contains no individual index |
| Depend on $t$ directly (Phase 1) | Time-dependence is unfalsifiable from single-dose data | Exclude $t$ from $\mathbf{z}$ |
| Take absolute concentrations across many decades | Float32 + optimizer conditioning | Nondimensionalize, then $\log$ |

The fourth row deserves emphasis. **$\boldsymbol{\phi}$ is global.** If the network were
allowed per-individual weights, it would absorb all inter-individual variability and the
physiological parameters would become unidentifiable. The whole scientific premise is that
the *mechanism* is shared and the *physiology* varies.

> **中文讲解｜CN**
> 第四行是**本项目的科学前提，不是技术细节**：
>
> $$\text{机制（}\boldsymbol{\phi}\text{）是全人群共享的；生理（}\boldsymbol{\eta}_j\text{）是因人而异的。}$$
>
> 一旦允许网络有个体专属权重，它就会把所有个体间差异都吸收进去，
> 生理参数随即完全不可辨识，模型退化成"每人一个黑箱"，毫无外推能力和科学价值。
>
> 相反地，正因为 $\boldsymbol{\phi}$ 被 $N$ 个个体共享，**群体规模越大，闭合项的估计反而越稳**——
> 这是本方法相对于"逐个体拟合"的根本优势，也是为什么要做群体反演而不是单体反演。
>
> 第五行也值得注意：Phase 1 阶段**不要把 $t$ 喂给网络**。单剂量数据无法区分
> "浓度依赖的非线性"和"时间依赖的酶变化"——两者在数据上完全等价。
> 允许 $t$ 作输入等于主动引入一个不可辨识方向。

---

## 3.4 Architecture

Deliberately small:

- 2 hidden layers, 16–32 units, `tanh` or `gelu` activation.
- Input dimension 1–3 (Phase 1: **one** input, $\log \tilde{C}_{u,\mathrm{li}}$).
- Output dimension 1.
- Total parameter count $|\boldsymbol{\phi}| \approx 10^2$–$10^3$.
- Use `Lux.jl` (explicit, immutable parameter handling) rather than implicit-parameter
  frameworks — this matters for GPU kernels and for `Enzyme` compatibility.
- Store $\boldsymbol{\phi}$ in a `ComponentArray` so the joint parameter vector
  $(\boldsymbol{\phi}, \{\boldsymbol{\eta}_j\}, \boldsymbol{\theta}_{\mathrm{pop}})$ is a
  flat differentiable array with named views.

**Initialization matters more than architecture.** Initialize such that
$\mathcal{N}_{\boldsymbol{\phi}_0} \approx$ the nominal mechanistic law (e.g. linear
clearance). Two workable ways:

1. Pre-train $\boldsymbol{\phi}$ by regression against the nominal law before touching the
   ODE (cheap, no ODE solves).
2. Use a residual form $R = R_{\mathrm{nominal}} \cdot \big(1 + \varepsilon\,
   \mathcal{N}_{\boldsymbol{\phi}}\big)$ with small-initialized final layer, so
   $\boldsymbol{\phi}_0 = \mathbf{0}$ recovers the mechanistic model exactly.

> **中文讲解｜CN**
> **初始化比架构重要得多，这是 SciML 与常规深度学习最不同的一点。**
>
> 原因：随机初始化的网络会给出一个物理上荒谬的闭合项，ODE 求解器可能直接发散或者
> 变得极度刚性、步长塌缩，训练第一步就失败。而且这类失败常常表现为"梯度是 NaN"，
> 极难调试。
>
> 两种可靠做法（推荐第 2 种）：
> 1. 先用名义米氏/线性清除律做一次纯回归预训练网络（不涉及 ODE，几秒钟的事）；
> 2. **残差形式**：$R = R_{\text{nominal}}(1 + \varepsilon\mathcal{N}_{\boldsymbol{\phi}})$，
>    最后一层权重初始化为 0 → $\boldsymbol{\phi}_0 = \mathbf{0}$ 时**精确退化为机理模型**。
>
> 第 2 种有额外好处：它把问题变成"机理模型 + 学习到的修正"，
> 正则项 $\lambda\|\boldsymbol{\phi}\|^2$ 于是有了明确物理含义——**向机理模型收缩**。
> 这正是 CFD 里 data-driven 湍流模型常用的"基线模型 + 修正场"框架。

---

## 3.5 Regularization

The objective (see [04](04-population-inverse-problem.md)) carries three penalties on
$\boldsymbol{\phi}$, each with a distinct purpose:

$$
\mathcal{R}(\boldsymbol{\phi}) = \underbrace{\lambda_2 \|\boldsymbol{\phi}\|_2^2}_{\text{shrink toward mechanism}} + \underbrace{\lambda_1 \|\boldsymbol{\phi}\|_1}_{\text{sparsity, aids symbolic recovery}} + \underbrace{\lambda_s \int \left|\frac{\partial^2 \mathcal{N}}{\partial z^2}\right|^2 dz}_{\text{smoothness in }z}
$$

The third term is the important and often-omitted one. PK data are sparse; without a
smoothness penalty the learned $\mathrm{CL}_{\mathrm{eff}}(C)$ curve will oscillate wildly
in concentration regions that are poorly sampled. Evaluate the integral by finite
differences on a fixed grid of $z$ values spanning the observed concentration range —
cheap, and it does not require any extra ODE solves.

Select $(\lambda_1, \lambda_2, \lambda_s)$ by held-out-individual cross-validation, not by
training loss.

> **中文讲解｜CN**
> 三个正则项各司其职，不要只用 L2：
> - $\lambda_2\|\boldsymbol{\phi}\|_2^2$：向机理模型收缩（配合残差形式初始化时含义最清楚）；
> - $\lambda_1\|\boldsymbol{\phi}\|_1$：稀疏化，有利于后续符号回归还原公式；
> - $\lambda_s \int |\partial^2\mathcal{N}/\partial z^2|^2$：**平滑性惩罚，最重要也最常被忽略。**
>
> 为什么平滑性关键：PK 数据非常稀疏，某些浓度区间几乎没有数据点。
> 没有平滑约束，网络在这些"数据真空区"会剧烈震荡——拟合损失照样很低，
> 但学到的 $\mathrm{CL}_{\mathrm{eff}}(C)$ 曲线画出来是锯齿状的，物理上毫无意义。
>
> 实现上很便宜：在观测浓度范围内取固定网格，用有限差分算二阶导的平方和即可，
> **不需要额外求解任何 ODE**。
>
> 超参数一律用**留出个体交叉验证**选，绝不能看训练损失——
> 训练损失永远是 $\lambda \to 0$ 最好。

---

## 3.6 Coverage: the network is only valid where data lives

A learned closure is meaningful only on the region of input space actually visited by the
training trajectories. Define the **empirical support**

$$
\mathcal{Z} = \left\{ z : \rho(z) > \epsilon \right\}, \qquad
\rho(z) \propto \sum_{j=1}^{N} \sum_{k} w_{jk} \,\delta_h\!\big(z - z(t_{jk})\big)
$$

weighted by observation density, not merely by simulation time.

**Every plot of the learned closure must show $\rho(z)$ underneath it, and every
extrapolation claim must be checked against $\mathcal{Z}$.**

> **中文讲解｜CN**
> 这是一条必须写进论文、也必须写进绘图代码里的纪律：
>
> **神经闭合项只在"训练轨迹实际访问过的输入区间"上有意义。**
>
> 做法：统计所有个体、所有观测时刻对应的网络输入 $z$ 的分布 $\rho(z)$，
> 每次画"学到的 $\mathrm{CL}_{\mathrm{eff}}(C)$ 曲线"时，**在下方画一条 $\rho(z)$ 的直方图或密度带**。
> 曲线在 $\rho$ 很低的区间必须画成虚线或灰色，明确标注"外推区，不可信"。
>
> 注意权重要按**观测密度**而不是按仿真时间加权：药物大部分时间处在低浓度终末相，
> 按时间加权会严重高估低浓度区的信息量。
>
> 这与 CFD 中"数据驱动湍流模型只在训练流动的参数空间内可信"是完全一样的问题，
> 也是这类方法最常被批评的地方。**主动地、显式地处理它，会成为加分项而不是被攻击的软肋。**

---

## 3.7 Summary of the Phase-1 UDE

$$
\boxed{
\begin{aligned}
&\text{States: } \mathbf{u} \in \mathbb{R}^{16}, \text{ perfusion-limited PBPK, single IV bolus} \\
&\text{Closure: } R_{\mathrm{hep}} = R_{\mathrm{hep}}^{\mathrm{nom}}(C_{u,\mathrm{li}}) \cdot \big(1 + \varepsilon\, \mathcal{N}_{\boldsymbol{\phi}}(\log \tilde{C}_{u,\mathrm{li}})\big) \\
&\text{Network: MLP } 1 \to 16 \to 16 \to 1, \; \tanh, \; \text{zero-init final layer} \\
&\text{Per-individual: } \boldsymbol{\eta}_j \in \mathbb{R}^{3}, \; (\log \mathrm{CL}, \log Q_{\mathrm{CO}}, \log K_p^{\mathrm{scale}}) \\
&\text{Shared: } \boldsymbol{\phi} \in \mathbb{R}^{\sim 300}, \; \boldsymbol{\theta}_{\mathrm{pop}} \in \mathbb{R}^{3}, \; \boldsymbol{\Omega} \in \mathbb{R}^{3\times 3}
\end{aligned}
}
$$

Everything else is deferred to later phases.

---

**Next:** [04 — Population Inverse Problem](04-population-inverse-problem.md)
