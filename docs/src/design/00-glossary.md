# 00 — Glossary / 术语表

This project sits between three vocabularies: pharmacokinetics (PK), scientific machine
learning (SciML), and computational fluid dynamics (CFD). The same object often has three
names. This document is the dictionary. Keep it open while reading the rest.

> **中文讲解｜CN**
> 本项目跨三个词汇体系：药代动力学、科学机器学习、计算流体力学。同一个数学对象在三个领域
> 有三个名字。**建议先通读本表再看其他文档**——很多"看起来是新概念"的东西，其实是你已经熟悉的东西换了个名字。

---

## 1. Pharmacokinetics core terms

| Term | 中文 | Definition | Units |
|---|---|---|---|
| PBPK | 生理药代动力学 | Physiologically-Based PK: compartments correspond to real organs with real volumes and blood flows | — |
| Compartment | 房室 | A well-mixed control volume representing an organ or tissue | — |
| $V_i$ | 房室容积 | Volume of tissue compartment $i$ | L |
| $Q_i$ | 灌注流量 | Blood flow perfusing compartment $i$ | L/h |
| $Q_{\mathrm{CO}}$ | 心输出量 | Cardiac output; $\sum_i Q_i = Q_{\mathrm{CO}}$ | L/h |
| $C_i$ | 浓度 | Drug concentration in compartment $i$ | µmol/L |
| $K_{p,i}$ | 组织–血浆分配系数 | Steady-state tissue-to-plasma concentration ratio | — |
| $f_u$ | 血浆游离分数 | Unbound fraction in plasma (not protein-bound) | — |
| $R_b$ | 血/血浆比 | Blood-to-plasma concentration ratio | — |
| CL | 清除率 | Clearance: volume of blood cleared of drug per unit time | L/h |
| $\mathrm{CL}_{\mathrm{int}}$ | 内在清除率 | Intrinsic (enzyme-level) clearance, independent of flow | L/h |
| GFR | 肾小球滤过率 | Glomerular filtration rate; drives renal elimination | L/h |
| $V_{\max}, K_m$ | 最大反应速率 / 米氏常数 | Michaelis–Menten saturable kinetics parameters | µmol/h, µmol/L |
| AUC | 曲线下面积 | Area under the concentration–time curve | µmol·h/L |
| $C_{\max}, t_{\max}$ | 峰浓度 / 达峰时间 | Peak concentration and its time | µmol/L, h |
| Perfusion-limited | 血流限速 | Exchange fast relative to delivery; tissue equilibrates instantly | — |
| Permeability-limited | 膜限速 | Membrane transfer is the bottleneck; tissue splits into vascular + extravascular sub-compartments | — |
| NLME | 非线性混合效应模型 | Nonlinear Mixed-Effects: the standard population-PK statistical framework | — |
| Fixed effect $\theta$ | 固定效应 | Population-typical parameter value | — |
| Random effect $\eta_j$ | 随机效应 | Individual $j$'s deviation from the population typical value | — |
| Shrinkage | 收缩 | Degeneracy of individual estimates toward the population mean when data are uninformative | — |
| VPC | 视觉预测检验 | Visual Predictive Check: simulate from the fitted model, compare percentiles to observed data | — |

---

## 2. SciML terms

| Term | 中文 | Definition |
|---|---|---|
| UDE | 通用微分方程 | Universal Differential Equation: an ODE/PDE whose RHS contains both known mechanistic terms and a universal approximator (neural network) |
| Neural ODE | 神经常微分方程 | The fully black-box limit: the entire RHS is a neural network |
| Closure term | 闭合项 | The learned term standing in for unresolved / unknown physics |
| Adjoint sensitivity | 伴随灵敏度 | Reverse-mode gradient of a scalar functional of an ODE solution w.r.t. its parameters, computed by solving a backward ODE |
| VJP / JVP | 向量–雅可比积 / 雅可比–向量积 | The primitive operations of reverse-mode and forward-mode AD |
| Forward-mode AD | 前向模式自动微分 | Cost scales with number of *inputs*; efficient when few parameters |
| Reverse-mode AD | 反向模式自动微分 | Cost scales with number of *outputs*; efficient when many parameters, one scalar loss |
| Checkpointing | 检查点 | Trading recomputation for memory in reverse-mode through time |
| Symbolic regression | 符号回归 | Recovering a closed-form expression from a learned numerical function |
| Structural identifiability | 结构可辨识性 | Whether parameters are uniquely determined by *noise-free, infinitely dense* data |
| Practical identifiability | 实际可辨识性 | Whether parameters are determined by the *actual* noisy, sparse data at hand |

---

## 3. The PK ↔ CFD dictionary

This is the table that makes the project legible to a CFD supervisor.

| PBPK / PK object | CFD / transport analogue | Shared mathematics |
|---|---|---|
| Compartment network | 0D lumped-parameter flow network | Directed graph mass balance |
| Compartment $V_i$ | Control volume | Finite-volume cell |
| Blood flow $Q_i$ | Volumetric flux across a face | Convective flux $Q C$ |
| Cardiac output constraint $\sum Q_i = Q_{\mathrm{CO}}$ | Network continuity / conservation of mass | Kirchhoff current law |
| Arterial–venous pooling | Manifold / mixing junction | Perfect-mixing junction condition |
| Perfusion-limited compartment | Well-stirred (CSTR) reactor | Instantaneous local equilibrium |
| Permeability-limited compartment | Finite mass-transfer coefficient, Sherwood number | Two-film / two-resistance model |
| $K_{p,i}$ | Partition / Henry coefficient at an interface | Equilibrium jump condition |
| Metabolic clearance term | Volumetric sink / reaction source term | Reaction–transport coupling |
| Empirical Michaelis–Menten law | Algebraic constitutive / closure relation | Unresolved-physics model |
| **Neural closure term (this project)** | **Data-driven turbulence closure, subgrid model, wall model** | Universal approximator inside a conservation law |
| Population of individuals | Monte-Carlo UQ ensemble | Parametric uncertainty propagation |
| Inter-individual variability $\Omega$ | Input uncertainty distribution | Random parameter field |
| Joint population fit | Ensemble-based inverse problem / data assimilation | Regularized nonlinear least squares over an ensemble |
| Gradient by adjoint | Adjoint-based shape/parameter optimization | Same continuous/discrete adjoint theory |
| Lumping a full PDE tissue model into a compartment | Reduced-order model (ROM) | Model-order reduction |
| Windkessel boundary condition in 3D hemodynamics | *Literally a PBPK-style compartment* | Identical ODE form |

> **中文讲解｜CN**
> 表格最后一行值得特别注意：**3D 血流仿真里常用的 Windkessel 出流边界条件，其数学形式就是一个
> PBPK 房室。** 也就是说，PBPK 不是"类似于"集总参数模型，它**就是**集总参数模型，只是状态变量
> 从压力/流量换成了药物浓度。这一点在向 CFD 方向的老师解释课题时是最有力的论据。
>
> 另一个关键对应：**Michaelis–Menten 之于 PBPK，等价于代数湍流模型之于 RANS**。
> 两者都是"用一个简单代数式去封闭一个我们没有分辨的物理过程"，也都因此在超出标定范围时失效。
> 用神经网络替换它，在 CFD 里叫 data-driven closure，在 PK 里就是本项目要做的事。

---

## 4. Notation conventions used throughout

| Symbol | Meaning |
|---|---|
| $j = 1,\dots,N$ | Index over individuals in the population |
| $i \in \mathcal{T}$ | Index over tissue compartments |
| $\mathbf{u}_j(t) \in \mathbb{R}^{n}$ | State vector (concentrations) of individual $j$ |
| $\boldsymbol{\theta}_j$ | Physiological parameters of individual $j$ |
| $\boldsymbol{\theta}_{\mathrm{pop}}$ | Population typical (fixed-effect) parameters |
| $\boldsymbol{\eta}_j$ | Random effects of individual $j$; $\boldsymbol{\theta}_j = g(\boldsymbol{\theta}_{\mathrm{pop}}, \boldsymbol{\eta}_j, \mathbf{x}_j)$ |
| $\mathbf{x}_j$ | Observed covariates of individual $j$ (body weight, age, creatinine, genotype…) |
| $\boldsymbol{\Omega}$ | Covariance of random effects |
| $\boldsymbol{\phi}$ | Neural network weights — **shared across all individuals** |
| $\mathcal{N}_{\boldsymbol{\phi}}(\cdot)$ | The neural closure term |
| $y_{jk}$ | The $k$-th observation of individual $j$, at time $t_{jk}$ |
| $\sigma_{\mathrm{add}}, \sigma_{\mathrm{prop}}$ | Additive and proportional residual error scales |

The single most important structural fact of the whole project:

```math
\boxed{\;\boldsymbol{\eta}_j \text{ is per-individual and low-dimensional; } \boldsymbol{\phi} \text{ is global and high-dimensional.}\;}
```

Every algorithmic decision — parallel layout, choice of AD mode, regularization — follows
from this asymmetry.

> **中文讲解｜CN**
> 记住这个不对称性，后面所有设计都是它的推论：
> - $\boldsymbol{\eta}_j$ 每人一份、维度低（约 3–8）→ **前向模式 AD** 便宜，且天然按个体并行；
> - $\boldsymbol{\phi}$ 全局一份、维度高（约 $10^2$–$10^3$）→ **反向模式 AD**，且梯度要在整个群体上求和。
>
> 于是最优方案不是"全用反向"或"全用前向"，而是**混合模式**。详见
> [05-gpu-strategy.md](05-gpu-strategy.md)。
