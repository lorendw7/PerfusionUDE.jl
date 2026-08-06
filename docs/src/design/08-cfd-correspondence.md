# 08 — CFD Correspondence

The purpose of this document is to make the project legible as a **transport-modelling and
inverse-problem** contribution, so that PK is an application domain rather than a change of
field.

> **中文讲解｜CN**
> 这份文档的用途很具体：**当老师问"这跟我们组的方向有什么关系"时，你需要一套精确的、
> 不是牵强类比的回答。**
>
> 本文档的立场是：**这些不是"类比"，而是同一套数学在不同应用领域的实例化。**
> 下面每一节都给出可验证的对应关系，而不是修辞性的相似。

---

## 8.1 Level 1 — The governing equations are the same object

A 0D lumped-parameter transport network:

```math
V_i \frac{dc_i}{dt} = \sum_{k \in \mathcal{E}_{\mathrm{in}}(i)} Q_k c_{u(k)} - \sum_{k \in \mathcal{E}_{\mathrm{out}}(i)} Q_k c_i + V_i s_i(c_i)
```

subject to network continuity $\sum_{\mathcal{E}_{\mathrm{in}}(i)} Q_k = \sum_{\mathcal{E}_{\mathrm{out}}(i)} Q_k$.

This is exactly:

- **a finite-volume discretization** of $\partial_t c + \nabla\cdot(\mathbf{v}c) = s$ on a
  graph, with one cell per node and upwind convective fluxes;
- **a PBPK model**, when $c$ is drug concentration and the graph is the circulation;
- **a Windkessel / 0D circulation model**, when $c$ is pressure or volume — the standard
  outflow boundary condition for 3D hemodynamic CFD;
- **a CSTR reactor network** in chemical engineering.

There is no approximation being made in the analogy. The same code solves all four.

> **中文讲解｜CN**
> 这一节是最强的论据，因为它不是类比而是**恒等**：
>
> 上面那个方程，就是把对流输运方程 $\partial_t c + \nabla\cdot(\mathbf{v}c) = s$
> **在一张图上做有限体积离散**（每个节点一个控制体，边上用迎风通量）的结果。
>
> 换一下 $c$ 的物理含义，它同时是：
> - $c$ = 药物浓度 → **PBPK 模型**
> - $c$ = 压力/容积 → **Windkessel 模型**（3D 血流 CFD 的标准出流边界条件）
> - $c$ = 组分浓度 → **化工的全混流反应器网络**
>
> **同一段代码可以解这四个问题。** 所以"PBPK 是集总参数输运网络"不是修辞，是字面事实。
> 向 CFD 老师解释时，从这一条开始讲。

---

## 8.2 Level 2 — The closure problem is the same problem

| | RANS turbulence modelling | PBPK closure (this project) |
|---|---|---|
| Exact part | Conservation of mass/momentum | Conservation of drug mass, perfusion topology |
| Unresolved part | Reynolds stress $\overline{u'_i u'_j}$ | Metabolic/transport rate $R(\cdot)$ |
| Classical closure | Algebraic eddy viscosity, $k$–$\epsilon$ | Michaelis–Menten, constant $K_p$ |
| Calibration | A handful of canonical flows | A handful of in vitro assays |
| Failure mode | Poor extrapolation outside calibration regime | Poor extrapolation to new doses, populations, drug–drug interactions |
| Data-driven fix | Field-inversion + ML, neural closure, differentiable solvers | UDE with neural closure (this project) |
| Physical constraints imposed on the learned term | Realizability, Galilean invariance, correct tensor form | Nonnegativity, $R(0)=0$, mass conservation, no individual-specific weights |
| Validity region | Only the flows in the training set | Only the concentration range $\mathcal{Z}$ visited by the data |

The "field inversion and machine learning" (FIML) paradigm in turbulence modelling — infer
a spatially varying correction from data, then learn a functional map from local features
to that correction — has the identical structure to what is done here, with concentration
playing the role of the local feature.

> **中文讲解｜CN**
> 这张表逐行都成立，建议直接放进开题报告。几条特别值得展开：
>
> **"施加在学习项上的物理约束"这一行是关键。**
> 在湍流建模里，人们不会让网络自由输出雷诺应力，而是强制它满足**可实现性**
> （能量非负、Schwarz 不等式）、**伽利略不变性**、**正确的张量形式**。
> 本项目对应的约束是：非负、$R(0)=0$、质量守恒、权重全局共享
> （详见 [03 §3.2–3.3](03-ude-formulation.md)）。
>
> **"有效性区域"这一行同样重要。** 数据驱动湍流模型只在训练流动的参数范围内可信，
> 这是该领域公认的软肋；本项目的对应物是浓度支撑集 $\mathcal{Z}$。
> 两者面对的批评一模一样，所以两者的应对手段也可以互相借鉴。
>
> **FIML（场反演 + 机器学习）** 的结构与本项目完全同构：
> 先从数据反演出一个修正场，再学一个从局部特征到修正量的映射。
> 这里"局部特征"就是浓度。可以在论文里明确写出这个对应。

---

## 8.3 Level 3 — The inverse problem is the same problem

**Adjoint gradients.** For a functional $J = \int_0^T g(\mathbf{u}, \boldsymbol{\phi})\,dt$
subject to $\dot{\mathbf{u}} = f(\mathbf{u},\boldsymbol{\phi})$:

```math
-\dot{\boldsymbol{\lambda}} = \left(\frac{\partial f}{\partial \mathbf{u}}\right)^\top \boldsymbol{\lambda} + \frac{\partial g}{\partial \mathbf{u}}, \quad \boldsymbol{\lambda}(T) = 0,
\qquad
\nabla_{\boldsymbol{\phi}} J = \int_0^T \left[\boldsymbol{\lambda}^\top \frac{\partial f}{\partial \boldsymbol{\phi}} + \frac{\partial g}{\partial \boldsymbol{\phi}}\right] dt .
```

This is the same continuous adjoint used for unsteady aerodynamic shape optimization. The
same issues arise and the same remedies apply:

| Issue | CFD unsteady adjoint | This project |
|---|---|---|
| Storing the forward solution | Checkpointing (Griewank/Walther) | Checkpointed `InterpolatingAdjoint` / `GaussAdjoint` |
| Chaotic sensitivity over long horizons | Least-squares shadowing | Multiple shooting / interval growth ([04 §4.5](04-population-inverse-problem.md)) |
| Discrete vs continuous adjoint consistency | Well-known discrepancy | `sensealg` choice; validate by finite differences |
| Ill-posedness | Tikhonov regularization on the design field | $\boldsymbol{\Omega}^{-1}$ penalty + $\mathcal{R}(\boldsymbol{\phi})$ |

**Regularization = prior.** The term
$\frac{1}{2}\boldsymbol{\eta}_j^\top\boldsymbol{\Omega}^{-1}\boldsymbol{\eta}_j$ in
[04 §4.3](04-population-inverse-problem.md) is simultaneously a Bayesian prior and a
Tikhonov regularizer with a non-diagonal weighting matrix. In data assimilation this is the
background-error covariance $\mathbf{B}^{-1}$ in 3D/4D-Var. **The population model *is* a
background-error covariance.**

> **中文讲解｜CN**
> **这一节包含一个很漂亮的对应，值得在论文里专门写一段：**
>
> ```math
> \underbrace{\tfrac{1}{2}\boldsymbol{\eta}_j^\top\boldsymbol{\Omega}^{-1}\boldsymbol{\eta}_j}_{\text{NLME 里的随机效应先验}} \;\equiv\; \underbrace{\tfrac{1}{2}(\mathbf{x}-\mathbf{x}_b)^\top\mathbf{B}^{-1}(\mathbf{x}-\mathbf{x}_b)}_{\text{4D-Var 里的背景误差项}}
> ```
>
> 也就是说：**群体药代动力学里的"个体间变异协方差 $\boldsymbol{\Omega}$"，
> 在数据同化里就是"背景误差协方差 $\mathbf{B}$"。**
> 两个领域各自发展了几十年，用着完全不同的术语，但数学对象是同一个。
>
> 同样地，"正则化"和"贝叶斯先验"在这里是一体两面：
> 反问题的人说"Tikhonov 正则化"，统计的人说"高斯先验"，说的是同一个二次项。
>
> 表格里的四行"同样的问题、同样的解法"也都是实打实的：
> 特别是**检查点技术**（非定常伴随存不下正向解 → 每 $k$ 步存一次、中间重算），
> 你在 CFD 里的经验可以**原封不动**用在这里。

---

## 8.4 Level 4 — The ensemble is the same ensemble

| | CFD UQ ensemble | Population PK |
|---|---|---|
| Ensemble member | One simulation with perturbed inputs | One individual |
| Input uncertainty | Random field / parametric distribution | $\boldsymbol{\eta}_j \sim \mathcal{N}(0,\boldsymbol{\Omega})$ |
| Ensemble size | $10^2$–$10^4$ (Monte Carlo) | $10^2$–$10^4$ individuals |
| Output of interest | Statistics of a QoI | Statistics of exposure (AUC, $C_{\max}$) |
| Standard practice | Forward propagation | **Inverse**: infer the input distribution from output observations |
| Acceleration | GPU ensembles, surrogate models, multi-level MC | GPU ensembles (this project) |

The distinguishing feature of this project is that the ensemble is **differentiated
through**, not merely propagated. That combination — ensemble UQ + adjoint inversion +
learned closure — is where the methodological novelty sits, and it is a combination that
CFD is also actively pursuing (e.g. ensemble-based field inversion).

> **中文讲解｜CN**
> 群体药代与 UQ 集成模拟的对应几乎是逐项的，但有一个关键差别值得强调：
>
> - **CFD 里的 UQ 通常是正向的**：已知输入分布 → 求输出分布；
> - **群体 PK 是反向的**：观测到输出 → 反推输入分布。
>
> 而本项目更进一步：**不只反推输入分布，还要同时学一个共享的闭合项，
> 并且要穿过整个 ensemble 求梯度。**
>
> 所以本项目的方法学定位可以精确表述为：
> ```math
> \textbf{UQ 集成} + \textbf{伴随反演} + \textbf{数据驱动闭合} \text{ 三者的结合}
> ```
>
> 这个组合在 CFD 领域本身也是活跃的前沿（例如基于集成的场反演），
> 所以它不是"从 CFD 借了个工具"，而是"在一个新场景里做 CFD 也在做的事"。
> 这个表述对开题答辩很有用。

---

## 8.5 Level 5 — Model reduction

The decision in [07 §7.7](07-validation-protocol.md) to use a lumped (minimal) PBPK when
plasma-only data are available is a **model-order reduction driven by information content**,
not by computational cost.

The parallel to ROM in CFD:

| | CFD ROM | PBPK lumping |
|---|---|---|
| Full model | 3D Navier–Stokes | 13-compartment PBPK (itself already a reduction of a 3D tissue-transport PDE) |
| Reduced model | POD-Galerkin, DMD, balanced truncation | Lumped mPBPK (5–6 compartments) |
| Reduction criterion | Energy content / controllability–observability | **Observability from the available measurement** |
| Risk | Loss of unresolved dynamics | Loss of organ-specific interpretation |

Note that PBPK is *itself* already a reduced-order model: the well-stirred compartment is
the zero-Péclet limit of a spatially resolved tissue-transport model (Krogh cylinder,
axial-dispersion models). Lumping compartments is a second reduction on top of the first.

> **中文讲解｜CN**
> 这一节的要点：**"简化模型"不是妥协，是方法论上正当的一步，而且有名字——降阶（ROM）。**
>
> 特别注意这个层次结构：
> ```math
> \text{3D 组织输运 PDE} \xrightarrow{\ \text{Pe}\to 0\ } \text{全 PBPK（13 房室）} \xrightarrow{\ \text{可观测性}\ } \text{最小 PBPK（5–6 房室）}
> ```
>
> 第一步降阶（3D PDE → 房室）的依据是**物理**：良搅拌假设是零 Péclet 数极限，
> 更精细的版本是 Krogh 圆柱模型、轴向弥散模型。
> 第二步降阶（房室合并）的依据是**可观测性**：血浆数据看不到的自由度就不该保留在模型里。
>
> **降阶判据是"从可用测量的可观测性"而不是"计算成本"**——这一点与 CFD ROM 常见的
> "按能量含量截断"不同，反而更接近平衡截断（balanced truncation）里
> 同时考虑可控性和可观测性的思路。写论文时点出这个区别会显得更专业。

---

## 8.6 One-paragraph framing for a CFD audience

> We study inverse problems on lumped-parameter transport networks in which part of the
> constitutive law is unknown. The network conserves mass and its convective structure is
> given, but the volumetric sink terms — which represent unresolved sub-network chemistry
> and interfacial transport — are known only through empirical algebraic closures that
> extrapolate poorly. We replace those closures with constrained neural operators embedded
> in the ODE right-hand side, and recover them jointly with per-realization network
> parameters from an ensemble of $10^3$–$10^4$ realizations of the same network with
> different parameters. The ensemble is integrated on GPU and differentiated end-to-end by
> a mixed forward/adjoint scheme, exploiting the asymmetry between the few
> per-realization parameters and the many shared closure parameters. We characterize when
> the closure is recoverable as a function of ensemble size, measurement density, and
> noise. Physiologically-based pharmacokinetics provides the application, and a validation
> setting in which the ground-truth closure can be prescribed.

> **中文讲解｜CN**
> 上面这段是给 CFD 背景听众的**一段话版本**。注意它的写法：
> **全程不出现"药物""器官""患者"这些词**，只用输运网络、本构关系、闭合、集成、伴随、
> 可恢复性这些方法论词汇，最后一句才落到"PBPK 是应用场景，并且它提供了一个能规定真值闭合项
> 的验证环境"。
>
> 这样组织的好处：
> 1. 听众从第一句就在自己的知识框架里，不需要先学药代动力学；
> 2. "能规定真值"被表述为 PBPK 的**优势**（就像 DNS 数据之于湍流建模），
>    而不是"我们只好做合成实验"。
>
> 建议把这段背下来，开题答辩时作为开场。
> 后面再展开讲 PBPK 的具体内容，听众就有了正确的接收框架。

---

**Next:** [09 — Implementation Roadmap](09-implementation-roadmap.md)
