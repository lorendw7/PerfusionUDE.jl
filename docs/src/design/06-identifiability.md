# 06 — Identifiability

**This is the central scientific risk of the project.** GPU speed is an engineering
problem with a known solution. Identifiability is not.

> **Revised 2026-08-06.** The vocabulary and §6.0 below come from Loman & Baker (2025),
> *Functional and parametric identifiability for universal differential equations applied
> to chemical reaction networks* (arXiv:2510.14140). See
> [11 §11.1(1)](11-literature-landscape.md).

---

## 6.0 Two kinds of identifiability, and one degeneracy

For a UDE, split the question in two:

| | Question | Object |
|---|---|---|
| **Parametric identifiability** | Can the mechanistic parameters be uniquely recovered? | $\boldsymbol{\theta}_{\mathrm{pop}}, \boldsymbol{\eta}_j$ |
| **Functional identifiability** | Can the unknown *function* the network stands for be recovered? | $\mathcal{N}_{\boldsymbol{\phi}}(\cdot)$ as a function, not its weights |

Note that $\boldsymbol{\phi}$ itself is *never* identifiable — different weight vectors give
the same function. Functional identifiability is about the function, and that is why every
metric in [07 §7.5](07-validation-protocol.md) is defined on
$\mathrm{CL}_{\mathrm{eff}}(\cdot)$ rather than on weights.

Loman & Baker report two findings that bear directly on this project:

- **Reassuring.** Across a wide range of models, generalising a mechanistic model to a UDE
  has *little impact on the mechanistic components' parametric identifiability*. The fear
  in §6.1 that the network destroys all parameter estimates is, empirically, overstated.
- **Alarming.** For some hybrid models, fitting the UDE is *equivalent to fitting a fully
  data-driven neural ODE* — the mechanistic formulation contributes nothing. Such a model
  is a neural ODE wearing a mechanistic costume.

### Test D — the mechanistic-content test (mandatory, Phase 1)

> Fit the UDE and an unconstrained neural ODE on the same observable, same data. If their
> fits **and** their held-out-dose predictions coincide within run-to-run variability, the
> mechanistic skeleton is contributing no information and the closure must be further
> constrained (narrower $\mathbf{z}$, tighter placement, stronger structural constraints).

This is a stronger statement than baseline B3 in [07 §7.3](07-validation-protocol.md): B3
compares performance, Test D decides whether the hybrid model is a hybrid model at all.

> **中文讲解｜CN**
> **先理解这个拆分，它比原来的表述精确得多：**
>
> - **参数可辨识性**：机理参数能不能唯一确定？
> - **函数可辨识性**：网络代表的那个**未知函数**能不能恢复？
>
> 注意一个容易搞混的点：**$\boldsymbol{\phi}$（网络权重）本身永远不可辨识**——
> 不同的权重可以表示同一个函数。所以我们关心的从来不是权重，而是**函数**。
> 这也是为什么 [07 §7.5](07-validation-protocol.md) 里所有指标都定义在
> $\mathrm{CL}_{\mathrm{eff}}(\cdot)$ 上而不是权重上。
>
> Loman & Baker 的两个结论：
> - **好消息**：加网络之后机理参数的可辨识性通常不会明显变差 → §6.1 的担心被部分缓解；
> - **坏消息**：某些混合模型**等价于纯 neural ODE**，机理结构只是件外衣。
>
> **Test D 就是用来排除后者的**，而且它必须在 Phase 1 就做，不能拖到最后。
> 做法：同一批数据、同一个观测量，分别拟合 UDE 和无约束 neural ODE，
> 比较**拟合质量**和**留出剂量的外推预测**。
> 如果两者在运行间波动范围内一致 → 机理骨架没起作用 → 必须回头收紧约束。
>
> 注意它和基线 B3 的区别：**B3 是性能比较（谁更准），Test D 是判定（是不是真的混合模型）。**
> 前者是加分项，后者是及格线。

---

## 6.1 The problem, stated plainly

A PBPK model has more parameters than a plasma concentration curve can determine. Adding a
neural network makes this dramatically worse: $\mathcal{N}_{\boldsymbol{\phi}}$ is a
universal approximator, so it can, in principle, absorb the effect of *any* misspecified
mechanistic parameter.

The concrete failure modes:

| Confounding | Mechanism | Consequence |
|---|---|---|
| $\boldsymbol{\phi}$ ↔ $\mathrm{CL}$ | Network learns a constant multiplier on elimination | Clearance estimate arbitrary; network absorbs it |
| $\boldsymbol{\phi}$ ↔ $K_p$ | Network compensates a wrong partition coefficient by adjusting apparent distribution | Both wrong, fit perfect |
| $\boldsymbol{\phi}$ ↔ $\boldsymbol{\Omega}$ | Network fits individual-specific deviations that should be random effects | Variance underestimated, no generalization to new individuals |
| $\mathrm{CL}$ ↔ $Q_{\mathrm{li}}$ | Classic PBPK degeneracy: for a high-extraction drug, only $Q_{\mathrm{li}}$ is seen; for low-extraction, only $\mathrm{CL}_{\mathrm{int}}$ | Well known in PK, unaffected by the network |
| $V_{\mathrm{adipose}}$ ↔ $K_{p,\mathrm{adipose}}$ | Only the product $V K_p$ appears in the plasma-observable dynamics | Never separable from plasma data alone |

The last row generalizes: **plasma-only data see certain products and sums of parameters,
never the factors individually.** No amount of data or computation fixes a structural
non-identifiability.

> **中文讲解｜CN**
> 请把这一节当成整个项目的**风险中心**来读。
>
> 核心矛盾：**神经网络是万能逼近器，因此它原则上能吸收任何机理参数的误设效果。**
> 换句话说，如果不加约束，模型总能把数据拟合得很好——但生理参数全错、网络学到的东西全是伪影。
> 而且**你从损失函数上完全看不出来**（loss 很低），这是最危险的地方。
>
> 表格最后一行给出了一个不可逾越的界限：**只有血浆数据时，某些参数只以乘积形式出现**
> （比如脂肪容积 × 脂肪分配系数），个别因子**永远**分不开。
> 这是**结构不可辨识**，不是"数据不够"或"算法不好"——加再多个体、跑再久 GPU 都无济于事。
>
> 所以本项目正确的态度不是"想办法把所有参数都反演出来"，
> 而是**"先搞清楚哪些量原则上可辨识，只反演那些，其余固定或加强先验"**。

---

## 6.2 Structural identifiability: do this first

Before any fitting, analyse the **mechanistic skeleton with the network removed**, using
`StructuralIdentifiability.jl` (differential-algebra based, exact):

- Input: the ODE system, the observable $h(\mathbf{u}) = C_{\mathrm{ven}}/R_b$, the
  candidate estimated-parameter set.
- Output: for each parameter, globally identifiable / locally identifiable / not
  identifiable, plus the identifiable combinations.

Iterate: remove or fix parameters until the estimated set is globally identifiable. **That
reduced set is the definition of $\boldsymbol{\eta}$.** Do not choose $\boldsymbol{\eta}$
by intuition.

Note the honest limitation: this analysis applies to the mechanistic skeleton. With a
universal approximator in the RHS, structural identifiability of $\boldsymbol{\phi}$ is not
a well-posed question in the same sense — which is exactly why §6.3–6.5 exist.

> **中文讲解｜CN**
> **顺序很重要：先做结构可辨识性分析，再决定反演哪些参数。**
>
> `StructuralIdentifiability.jl` 基于微分代数，给出的是**精确的、与数据无关的**结论：
> 在"无噪声、无限密集采样"的理想条件下，哪些参数能唯一确定。
>
> 用法是迭代的：把候选参数集喂进去 → 看哪些不可辨识 → 固定或删掉它们 → 再跑一遍，
> 直到全部全局可辨识。**最后剩下的这个集合，就是 $\boldsymbol{\eta}$ 的定义。**
>
> 不要凭直觉挑参数。凭直觉挑的结果通常是：拟合看起来没问题，但参数估计毫无意义。
>
> ⚠️ 诚实的局限：这个分析只对**去掉神经网络后的机理骨架**成立。
> 带万能逼近器的系统，$\boldsymbol{\phi}$ 的"结构可辨识性"不是一个良定义的问题。
> 所以后面几节的手段（先验锚定、实际可辨识性、符号回归）都是不可或缺的补充，不是可选项。

---

## 6.3 Anchoring the mechanism against the network

Four independent levers. Use all of them.

**1. Restrict the network's input.**
The narrower $\mathbf{z}$, the fewer things $\mathcal{N}_{\boldsymbol{\phi}}$ can imitate.
Phase 1 uses a *single* input, $\log \tilde{C}_{u,\mathrm{li}}$. It therefore cannot mimic
$\eta_{Q_{\mathrm{CO}}}$ (which changes *when* concentrations arrive, not *what happens at
a given concentration*), and it cannot depend on the individual.

**2. Restrict the network's placement.**
It appears only in the hepatic elimination term. It cannot mimic $K_p$ of adipose tissue,
because it does not act there.

**3. Structural constraints from [03 §3.2](03-ude-formulation.md).**
$R(0)=0$ and $R \ge 0$ eliminate whole families of degenerate solutions.

**4. Regularize toward the mechanism.**
Residual form + $\lambda_2\|\boldsymbol{\phi}\|^2$ means: "deviate from Michaelis–Menten
only to the extent the data demand it." This is a principled Occam prior and it is the
direct analogue of "baseline turbulence model + minimal learned correction field".

> **中文讲解｜CN**
> 四道防线是**互相独立**的，要全部用上，不能只靠正则化：
>
> 1. **限制网络输入。** 这是最有效的一道。Phase 1 只给一个输入 $\log C_{u,\mathrm{li}}$，
>    网络就在信息上**不可能**冒充心输出量的个体差异——因为 $Q_{\mathrm{CO}}$ 影响的是
>    "药物什么时候到达"，而网络只知道"当前浓度是多少"。这种约束是硬的，不靠调参保证。
> 2. **限制网络位置。** 它只出现在肝消除项里，就不可能去补偿脂肪组织的 $K_p$ 误差。
> 3. **结构约束**（$R(0)=0$、$R\ge0$）直接消掉整族退化解。
> 4. **向机理收缩的正则化**：残差形式 + L2，含义是"除非数据强烈要求，否则就保持米氏形式"。
>    这是有原则的奥卡姆先验，也正是 CFD 里"基线模型 + 最小修正场"的做法。
>
> 注意第 1、2 道防线是**建模阶段**的决定，一旦代码写完就很难改；
> 第 3、4 道是**可调**的。所以前两道更要想清楚再动手。

---

## 6.4 Practical identifiability diagnostics

Run these on every fit. They are cheap relative to the fit itself.

### (a) Profile likelihood

For a scalar parameter $\theta_m$, fix it at values on a grid and re-optimize everything
else:

$$
\mathrm{PL}(\theta_m^*) = \min_{\boldsymbol{\Theta}_{-m}} J(\theta_m^*, \boldsymbol{\Theta}_{-m})
$$

- Sharp parabola → identifiable.
- Flat valley → practically non-identifiable.
- Flat in one direction only → identifiable only from one side (common for $K_m$ when
  concentrations never saturate the enzyme).

Expensive (each point is a full re-fit), so run it on the population-level parameters and
a few representative $\eta$s, not on everything.

### (b) Fisher information / correlation matrix

$$
\mathbf{F} = \frac{1}{\sigma^2}\sum_{j,k} \left(\frac{\partial h_{jk}}{\partial \boldsymbol{\Theta}}\right)\left(\frac{\partial h_{jk}}{\partial \boldsymbol{\Theta}}\right)^\top
$$

The sensitivities are already computed for the gradient — $\mathbf{F}$ is nearly free.
Report the condition number and the parameter-correlation matrix
$\mathrm{corr}(\mathbf{F}^{-1})$. Any $|\rho| > 0.95$ pair is a confounding warning.

### (c) $\eta$-shrinkage

$$
\mathrm{sh}_m = 1 - \frac{\mathrm{sd}(\hat{\eta}_{m,j})_j}{\sqrt{\Omega_{mm}}}
$$

Shrinkage > 30% means the data do not inform that individual parameter; individual
estimates are being pulled to the population mean. High shrinkage invalidates any
individual-level interpretation, and it is the standard diagnostic in the PK field — a PK
audience will look for it.

### (d) The network-ablation test

Fit twice: with $\boldsymbol{\phi}$ free, and with $\boldsymbol{\phi} = \mathbf{0}$
(mechanistic only). If $\hat{\boldsymbol{\theta}}_{\mathrm{pop}}$ changes substantially
between the two, the network is stealing signal from the physiology.

> **中文讲解｜CN**
> 四个诊断的分工：
>
> | 诊断 | 回答什么问题 | 成本 |
> |---|---|---|
> | (a) 剖面似然 | 这个参数**到底**能不能定？置信区间多宽？ | 贵（每点一次完整重拟合） |
> | (b) Fisher 信息 / 相关矩阵 | 哪两个参数在**互相补偿**？ | 几乎免费（灵敏度已经算过了） |
> | (c) $\eta$-shrinkage | 个体估计**有没有意义**？ | 免费 |
> | (d) 网络消融 | 网络**有没有在偷生理参数的信号**？ | 中等（多跑一次拟合） |
> | **(D) 机制含量检验（§6.0）** | **这到底是不是一个混合模型？** | 中等（多跑一次 neural ODE 拟合） |
>
> 前四个诊断关注**参数可辨识性**；Test D 关注**这个混合模型是否名副其实**。两类问题都要回答。
>
> **(d) 是本项目特有的、也是最该重视的诊断。**
> 做法很简单：分别拟合"网络自由"和"网络关掉（纯机理）"两个版本，
> 对比 $\hat{\boldsymbol{\theta}}_{\mathrm{pop}}$。
> 如果关掉网络后清除率估计变了 50%，那说明网络确实在吸收本该由 $\mathrm{CL}$ 解释的信号，
> 两者混淆——这时候拟合再好也不能声称"学到了机制"。
>
> (c) shrinkage 是药代动力学领域的标准诊断，**PK 背景的审稿人一定会看这个数字**。
> 超过 30% 就不能对个体参数做任何解释。提前算好写进论文。

---

## 6.5 Recovering a formula: symbolic regression

The scientific payoff is not "we fit well". It is "we recovered the hidden mechanism".
Procedure:

1. Sample the trained network on a grid of $z$ **restricted to the empirical support**
   $\mathcal{Z}$ ([03 §3.6](03-ude-formulation.md)).
2. Run `SymbolicRegression.jl` on the resulting $(z, \mathcal{N}_{\boldsymbol{\phi}}(z))$
   pairs, with an operator set containing $+,-,\times,\div$ and constants — enough to
   express Michaelis–Menten and its sums.
3. Examine the Pareto front (accuracy vs. complexity). Report the whole front, not just
   the best-fitting expression.
4. **Refit the mechanistic model with the recovered expression substituted in**, and
   compare to the UDE fit. If the symbolic model matches, you have a genuine mechanistic
   result. If it does not, the network was fitting noise or unmodelled structure.

Step 4 is the one people skip and it is the one that makes the claim credible.

> **中文讲解｜CN**
> 这一节是**科学产出的落点**。要说服人的不是"我拟合得准"，而是"我把隐藏机制还原成了公式"。
>
> 流程四步，第 4 步最关键也最常被跳过：
>
> 1. 在**经验支撑集内**采样训练好的网络（超出数据覆盖范围的部分不能用于回归！）；
> 2. 用 `SymbolicRegression.jl` 做符号回归，算子集包含 $+,-,\times,\div$ 即可表达米氏形式；
> 3. **报告整条帕累托前沿**（精度 vs 复杂度），不要只挑一个最好的式子——
>    只报一个式子是选择性汇报，审稿人会怀疑你试了很多次；
> 4. **把还原出的公式代回机理模型重新拟合一次**，与 UDE 的拟合结果对比。
>
> 第 4 步为什么关键：符号回归总能给你一个式子。但**只有当这个式子代回原模型后还能拟合数据，
> 才说明网络学到的是真实机制而不是噪声。** 这是从"数值曲线相似"到"机制被还原"的唯一严格桥梁。
>
> 在孪生实验里（[07](07-validation-protocol.md)），你知道真实公式是什么，
> 所以可以直接检验符号回归有没有还原对——这正是孪生实验存在的意义。

---

## 6.6 The information-content question

An underappreciated point: **the amount of data needed to identify a closure term is not
the same as the amount needed to identify parameters.**

A parametric model with $p$ parameters needs $O(p)$ well-placed observations. A functional
unknown $\mathrm{CL}_{\mathrm{eff}}(C)$ needs observations **spanning the relevant range of
$C$**, and PK sampling schedules are designed for parameter estimation, not function
recovery.

Two practical consequences:

1. **Dose-ranging data are essential.** A single dose level probes a narrow concentration
   band. Multiple dose levels are what reveal nonlinearity. This should be a design
   criterion when selecting a real dataset.
2. **The population is the resource.** Inter-individual variability in clearance means
   different individuals visit different concentration ranges. With $N$ large, the *union*
   of individual trajectories covers far more of $\mathcal{Z}$ than any single individual
   does. **This is a genuine, quantifiable argument for why population-scale inversion is
   necessary — not merely convenient.**

Point 2 should be measured explicitly in the twin study: plot coverage of $\mathcal{Z}$ and
closure-recovery error as functions of $N$.

> **中文讲解｜CN**
> 这一节包含本项目**最好的一个论证**，值得放进开题报告和论文引言。
>
> 关键区别：
> - **估计参数**：需要 $O(p)$ 个位置合适的观测点；
> - **恢复一个函数** $\mathrm{CL}_{\mathrm{eff}}(C)$：需要观测**覆盖 $C$ 的相关取值范围**。
>
> 而临床 PK 的采样方案是为前者设计的，不是为后者。所以直接拿标准 PK 数据学闭合项，
> 覆盖度往往不够。
>
> 两个推论：
> 1. **必须要有剂量爬坡数据。** 单一剂量只能探测很窄的浓度带，看不出非线性。
>    这应当成为**选择真实数据集时的硬性标准**。
> 2. **群体本身就是信息资源。** 由于个体间清除率差异，不同个体的轨迹访问不同的浓度区间；
>    $N$ 越大，所有个体轨迹的**并集**覆盖的浓度范围越广，远超任何单个个体。
>
> 第 2 点是**"为什么必须做群体规模反演"的真正理由**——
> 不是"因为快"，而是"因为单个个体的数据在信息上不足以确定这个函数"。
> 这把 GPU 从"工程加速手段"提升为"科学上的必要条件"，是课题立论的关键一环。
>
> 而且它是**可以定量验证的**：在孪生实验里画出
> "闭合项恢复误差 vs 群体规模 $N$" 和 "支撑集覆盖度 vs $N$" 两条曲线即可。
> **建议把这张图作为论文的主结果图之一。**

---

**Next:** [07 — Validation Protocol](07-validation-protocol.md)
