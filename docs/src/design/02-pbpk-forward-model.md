# 02 — The PBPK Forward Model

This document specifies the mechanistic model completely: state vector, governing
equations, parameters, scaling laws, dosing, and numerical considerations. It is the
$f_{\mathrm{known}}$ of the UDE.

---

## 2.1 State vector and topology

Let $\mathcal{T}$ be the set of tissue compartments. The default configuration:

```math
\mathcal{T} = \{\text{lung, brain, heart, muscle, adipose, skin, bone, gut, spleen, liver, kidney, rest}\}
```

plus two blood pools. The state vector is

```math
\mathbf{u} = \big(C_{\mathrm{ven}},\, C_{\mathrm{art}},\, \{C_i\}_{i \in \mathcal{T}},\, A_{\mathrm{gut lumen}},\, A_{\mathrm{elim}}\big) \in \mathbb{R}^{n}, \quad n \approx 16 .
```

$A_{\mathrm{elim}}$ is a cumulative-eliminated-amount accumulator. It carries no feedback
but is invaluable for verifying mass conservation — **include it from day one.**

> **中文讲解｜CN**
> 强烈建议把 $A_{\mathrm{elim}}$（累计消除量）作为一个状态变量加进去，虽然它不参与任何反馈。
> 理由：有了它，就可以在任意时刻检查
> ```math
> \sum_i V_i C_i + V_{\mathrm{ven}}C_{\mathrm{ven}} + V_{\mathrm{art}}C_{\mathrm{art}} + A_{\mathrm{gut}} + A_{\mathrm{elim}} = A_{\mathrm{dose,cumulative}}
> ```
> 是否成立。这是**离散守恒检验**，和你在 CFD 里检查全局质量守恒是完全一样的做法。
> 在引入神经网络之后，这个检验会成为"网络有没有偷偷制造/销毁质量"的唯一可靠探针，
> 到时候再加就晚了。

Topology rules:

- All tissues except lung, gut, spleen, liver receive arterial blood and drain to the
  venous pool.
- Gut and spleen drain into the **portal vein**, which enters the liver.
- Liver receives hepatic artery flow $Q_{\mathrm{ha}}$ **plus** portal flow, and drains to
  the venous pool.
- The venous pool feeds the lung; the lung drains to the arterial pool. Full cardiac
  output passes through the lung.

Flow continuity (must be asserted in code as a test):

```math
Q_{\mathrm{CO}} = \sum_{i \in \mathcal{T} \setminus \{\text{lung, liver}\}} Q_i \;+\; Q_{\mathrm{ha}},
\qquad
Q_{\mathrm{liver,in}} = Q_{\mathrm{ha}} + Q_{\mathrm{gut}} + Q_{\mathrm{spleen}} .
```

---

## 2.2 Perfusion-limited tissue

For a well-stirred, flow-limited tissue $i$ with no elimination:

```math
V_i \frac{dC_i}{dt} \;=\; Q_i\left(C_{\mathrm{art}} - \frac{C_i}{K_{p,i}^{\mathrm{app}}}\right),
\qquad
K_{p,i}^{\mathrm{app}} \equiv \frac{K_{p,i}}{R_b}
```

where $C_i$ is the *total* concentration in tissue $i$ and $C_{\mathrm{art}}$ is the
arterial **blood** concentration. The emergent venous concentration leaving the tissue is
$C_{v,i} = C_i / K_{p,i}^{\mathrm{app}}$.

The characteristic equilibration time of the compartment is

```math
\tau_i = \frac{V_i K_{p,i}^{\mathrm{app}}}{Q_i} .
```

These time constants span roughly three orders of magnitude across organs (lung and
kidney: minutes; adipose with a lipophilic drug: many hours). **This is the origin of the
stiffness** of the system and it drives all solver choices later.

> **中文讲解｜CN**
> $\tau_i = V_i K_{p,i}^{\mathrm{app}} / Q_i$ 是每个房室的特征平衡时间，注意它可以跨三个数量级：
> - 肺、肾：$\tau$ 以分钟计（容积小、血流大）
> - 脂肪 + 亲脂性药物：$\tau$ 以小时甚至十小时计（容积大、血流小、$K_p$ 大）
>
> **这就是系统刚性的来源。** 在 CFD 里你熟悉的"多尺度导致刚性"在这里以最直白的形式出现。
> 建议在建模阶段就把所有 $\tau_i$ 打印出来，算一下 $\max\tau_i / \min\tau_i$，
> 这个比值直接决定你能不能用显式求解器（详见 [05-gpu-strategy.md](05-gpu-strategy.md)）。

---

## 2.3 Eliminating organs

### Liver

```math
V_{\mathrm{li}} \frac{dC_{\mathrm{li}}}{dt}
= Q_{\mathrm{ha}} C_{\mathrm{art}}
+ Q_{\mathrm{gut}} \frac{C_{\mathrm{gut}}}{K_{p,\mathrm{gut}}^{\mathrm{app}}}
+ Q_{\mathrm{sp}} \frac{C_{\mathrm{sp}}}{K_{p,\mathrm{sp}}^{\mathrm{app}}}
- Q_{\mathrm{li,in}} \frac{C_{\mathrm{li}}}{K_{p,\mathrm{li}}^{\mathrm{app}}}
- R_{\mathrm{hep}}
```

with the nominal (to-be-replaced) hepatic elimination rate

```math
R_{\mathrm{hep}} = \mathrm{CL}_{\mathrm{int}} \cdot f_{u,\mathrm{li}} \cdot \frac{C_{\mathrm{li}}}{K_{p,\mathrm{li}}^{\mathrm{app}}}
\quad\text{(linear)}
\qquad\text{or}\qquad
R_{\mathrm{hep}} = \frac{V_{\max} C_{u,\mathrm{li}}}{K_m + C_{u,\mathrm{li}}}
\quad\text{(Michaelis–Menten)} .
```

### Kidney

```math
V_{\mathrm{ki}} \frac{dC_{\mathrm{ki}}}{dt}
= Q_{\mathrm{ki}}\left(C_{\mathrm{art}} - \frac{C_{\mathrm{ki}}}{K_{p,\mathrm{ki}}^{\mathrm{app}}}\right)
- \mathrm{CL}_R \, f_u \, C_{\mathrm{art}},
\qquad
\mathrm{CL}_R = \mathrm{GFR} \cdot f_u \;+\; \mathrm{CL}_{\mathrm{secr}} - \mathrm{CL}_{\mathrm{reabs}} .
```

Renal secretion and reabsorption are both transporter-mediated and both are prime
candidates for neural closure.

### Blood pools

```math
V_{\mathrm{ven}} \frac{dC_{\mathrm{ven}}}{dt}
= \sum_{i \in \mathcal{D}} Q_i \frac{C_i}{K_{p,i}^{\mathrm{app}}} \;-\; Q_{\mathrm{CO}} C_{\mathrm{ven}},
\qquad
V_{\mathrm{art}} \frac{dC_{\mathrm{art}}}{dt}
= Q_{\mathrm{CO}}\left(\frac{C_{\mathrm{lu}}}{K_{p,\mathrm{lu}}^{\mathrm{app}}} - C_{\mathrm{art}}\right)
```

where $\mathcal{D}$ is the set of tissues draining directly into the venous pool
(everything except lung, gut, spleen — the latter two drain via the liver).

**The observable** is nearly always plasma concentration:

```math
C_{\mathrm{plasma}} = \frac{C_{\mathrm{ven}}}{R_b} .
```

Sampling is venous, not arterial. Getting this wrong is a classic silent bug.

> **中文讲解｜CN**
> 三个极易出错的细节，务必在实现时写成单元测试：
> 1. **观测量是静脉血浆浓度，不是动脉、不是全血。** 临床采血采的是外周静脉血，报告的是血浆浓度。
>    $C_{\mathrm{plasma}} = C_{\mathrm{ven}} / R_b$。搞错了模型会系统性偏移但不会报错。
> 2. **肠和脾的血流不进静脉池，走门静脉进肝。** 忘了这条，肝的输入通量就错了，
>    首过效应完全消失。
> 3. **$K_p$ 用的是组织总浓度对血浆浓度之比，但通量式里除的是"表观" $K_p^{\mathrm{app}} = K_p/R_b$**，
>    因为流的是血不是血浆。这个 $R_b$ 因子在文献里经常被省略不写，是最常见的实现分歧点。

---

## 2.4 Permeability-limited tissues (optional extension)

When membrane transfer is rate-limiting, split tissue $i$ into vascular ($\mathrm{vas}$)
and extravascular ($\mathrm{ev}$) sub-compartments:

```math
\begin{aligned}
V_i^{\mathrm{vas}} \frac{dC_i^{\mathrm{vas}}}{dt} &= Q_i\left(C_{\mathrm{art}} - C_i^{\mathrm{vas}}\right) - \mathrm{PS}_i\left(f_{u,b} C_i^{\mathrm{vas}} - \frac{f_{u,t} C_i^{\mathrm{ev}}}{K_{p,i}}\right) \\[4pt]
V_i^{\mathrm{ev}} \frac{dC_i^{\mathrm{ev}}}{dt} &= \phantom{Q_i\left(C_{\mathrm{art}} - C_i^{\mathrm{vas}}\right)} \; + \mathrm{PS}_i\left(f_{u,b} C_i^{\mathrm{vas}} - \frac{f_{u,t} C_i^{\mathrm{ev}}}{K_{p,i}}\right)
\end{aligned}
```

$\mathrm{PS}_i$ is the permeability–surface-area product. The ratio

```math
\mathrm{Pe}_i \;=\; \frac{Q_i}{\mathrm{PS}_i}
```

decides the regime: $\mathrm{Pe}_i \ll 1$ recovers the perfusion-limited model,
$\mathrm{Pe}_i \gg 1$ gives permeability control.

> **中文讲解｜CN**
> $\mathrm{Pe}_i = Q_i / \mathrm{PS}_i$ 就是这个问题的 **Péclet 数**：对流输运能力与扩散/渗透输运能力之比。
> - $\mathrm{Pe} \ll 1$：膜很"透"，组织瞬间与血达到平衡 → 退化为血流限速模型（2.2 节）
> - $\mathrm{Pe} \gg 1$：膜是瓶颈 → 必须显式分血管相/血管外相
>
> 这与 CFD 中"对流主导 vs 扩散主导"的判据在数学上是同一件事，也与化工里的**双膜模型**、
> 传质中的 **Sherwood 数**同构。建议 Phase 1 只做血流限速，Phase 3 再引入膜限速作为扩展。

---

## 2.5 Dosing

**IV bolus** — set as an initial condition or a discrete callback:

```math
C_{\mathrm{ven}}(t_d^+) = C_{\mathrm{ven}}(t_d^-) + \frac{D}{V_{\mathrm{ven}}} .
```

**IV infusion** — a rectangular source term on the venous pool over $[t_d, t_d + T_{\mathrm{inf}}]$.

**Oral** — first-order absorption from a gut-lumen amount compartment into the gut tissue
compartment:

```math
\frac{dA_{\mathrm{lumen}}}{dt} = -k_a A_{\mathrm{lumen}}, \qquad
V_{\mathrm{gut}} \frac{dC_{\mathrm{gut}}}{dt} = \dots + F_a\, k_a A_{\mathrm{lumen}} .
```

Implementation note: prefer **discrete callbacks with `tstops`** over smoothed
approximations of dosing events. Smoothing a bolus into a narrow Gaussian corrupts the
adaptive step-size controller and makes gradients noisy. However, callbacks interact
awkwardly with some GPU ensemble backends — see
[05-gpu-strategy.md §5.6](05-gpu-strategy.md).

> **中文讲解｜CN**
> 给药事件的处理有一个反直觉的坑：**不要为了"让 ODE 光滑可微"而把 bolus 抹成窄高斯脉冲。**
> 那样做会让自适应步长控制器在脉冲附近疯狂减步，梯度反而变噪。正确做法是用离散 callback +
> `tstops` 精确落在给药时刻。
>
> 但要提前知道：**部分 GPU ensemble 后端对 callback 的支持有限**。
> 建议 Phase 1 只做单次 IV bolus（写成初值即可，完全绕开 callback），
> 把多剂量/口服推迟到 Phase 3，那时你已经确定了 GPU 后端的能力边界。

---

## 2.6 Population parameterization

Individual $j$ has covariates $\mathbf{x}_j$ (body weight $\mathrm{BW}_j$, height, age,
sex, serum creatinine, genotype). Parameters are generated as:

**Anatomy — deterministic allometry plus variability:**

```math
V_{i,j} = V_i^{\mathrm{ref}} \cdot \frac{\mathrm{BW}_j}{\mathrm{BW}^{\mathrm{ref}}} \cdot e^{\eta_{V_i,j}},
\qquad
Q_{\mathrm{CO},j} = Q_{\mathrm{CO}}^{\mathrm{ref}} \left(\frac{\mathrm{BW}_j}{\mathrm{BW}^{\mathrm{ref}}}\right)^{3/4} e^{\eta_{Q,j}}
```

Blood flows are then $Q_{i,j} = q_i \, Q_{\mathrm{CO},j}$ with fixed fractions $q_i$, which
automatically preserves the continuity constraint.

**Physiology — the actually-estimated random effects:**

```math
\mathrm{CL}_{\mathrm{int},j} = \mathrm{CL}_{\mathrm{int}}^{\mathrm{pop}} \left(\frac{\mathrm{BW}_j}{70}\right)^{3/4} \cdot \mathrm{AF}(\text{genotype}_j) \cdot e^{\eta_{\mathrm{CL},j}},
\qquad
\boldsymbol{\eta}_j \sim \mathcal{N}(\mathbf{0}, \boldsymbol{\Omega}) .
```

**Critical design decision.** Do *not* attempt to estimate all $\eta_{V_i}$ and $\eta_Q$
from plasma data. Organ volumes are not identifiable from a plasma concentration curve.
Fix them at their allometric values (or give them tight informative priors) and estimate
only a small vector, typically:

```math
\boldsymbol{\eta}_j = \big(\eta_{\mathrm{CL}}, \eta_{Q_{\mathrm{CO}}}, \eta_{K_p,\mathrm{scale}}, \eta_{\mathrm{CL}_R}, \eta_{k_a}\big)_j \in \mathbb{R}^{3\text{–}6}.
```

> **中文讲解｜CN**
> **这是全项目最容易致命的设计决策，请务必认真对待。**
>
> 一个诱人的错误想法是："既然是反问题，那就把每个人的所有生理参数都反演出来。"
> 事实是：**血浆浓度–时间曲线携带的信息量极其有限**，通常只能支撑 3–6 个个体参数。
> 想从一条血药浓度曲线里反演出这个人的脂肪容积和肌肉血流量，是不可能的——
> 这不是算法问题，是信息论问题。
>
> 正确做法：
> - **器官容积、血流分配比例 → 固定**（由体重按异速生长律给出），或加很紧的信息先验；
> - **只反演少数几个真正影响曲线形状的量**：清除率、心输出量、$K_p$ 的整体缩放、肾清除、吸收速率。
>
> 详见 [06-identifiability.md](06-identifiability.md)。如果这一步做错了，
> 后面 GPU 跑得再快也只是在快速地拟合噪声。

---

## 2.7 Reference-individual values

**ICRP Publication 89 reference adult male: body mass 73 kg, cardiac output 6.5 l/min
= 390 L/h.** Verified against the primary document on 2026-08-16 and implemented in
`src/physiology/reference.jl`, where each row carries its own table citation.

Volumes are masses at an assumed tissue density of 1.00 kg/L, taken from ICRP 89
Table 2.8 (adult male column); blood is the exception, being a volume already
(Table 2.12). Flow fractions are ICRP 89 Table 2.40, male column.

| Compartment | $V_i$ (L) | $q_i = Q_i/Q_{\mathrm{CO}}$ | ICRP 89 source |
|---|---|---|---|
| Lung | 0.5 | 1.00 (series) | T2.8 "Lung — tissue only"; bronchial 2.5% is in *Rest* |
| Adipose | 14.5 | 0.05 | T2.8 "Separable adipose tissue, excluding yellow marrow"; T2.40 "Fat" |
| Muscle | 29.0 | 0.17 | T2.8; T2.40 "Skeletal muscle" |
| Skin | 3.3 | 0.05 | T2.8 (itemised in T2.27); T2.40 |
| Bone | 10.5 | 0.05 | T2.8 "Total skeleton"; T2.40 "Skeleton" |
| Brain | 1.45 | 0.12 | T2.8; T2.40 |
| Heart | 0.33 | 0.04 | T2.8 "Heart — tissue only"; T2.40 "Coronary tissue" |
| Kidney | 0.31 | 0.19 | T2.8 "Kidneys (2)"; T2.40 |
| Liver | 1.8 | 0.065 (hepatic artery) | T2.8; T2.40 "6.5 (arterial)" |
| Gut | 1.35 | 0.16 (→ portal) | T2.8 walls of oesophagus/stomach/intestines + pancreas; T2.40 same four rows |
| Spleen | 0.15 | 0.03 (→ portal) | T2.8; T2.40 |
| Rest | 4.51 | 0.075 | residual; see below |
| Venous blood | 3.82 | — | T2.12 total 5.3 L; 72% split derived from T2.13 |
| Arterial blood | 1.48 | — | T2.12 total 5.3 L; 28% split derived from T2.13 |

Two identities make the table checkable rather than merely cited, and both are
asserted in the test suite:

- $\sum_i q_i = 1$ over the perfused tissues. This works out because the male column
  of Table 2.40 sums to exactly 100% when the liver is counted by its *arterial*
  share alone, and the 7.5% left over for *Rest* is exactly that table's bronchial
  2.5 + thyroid 1.5 + lymph nodes 1.7 + gonads 0.05 + adrenals 0.3 + urinary bladder
  0.06 + all other 1.39.
- **Total hepatic inflow = 0.065 + 0.16 + 0.03 = 25.5% of cardiac output**, which is
  the figure Table 2.40 states independently on its liver row. Reproducing it from
  the model's own portal topology is a genuine check on the splanchnic bed.

> **中文讲解｜CN**
> ⚠️ **这张表在 2026-08-16 已逐条对照 ICRP 89 原文核实，不再是示意值。**
> 核实过程改掉了四个错误，其中一个是实质性的：
>
> - **原表把肠道流量写成 0.19，同时又单列脾 0.03**——0.19 其实是 ICRP 的**门静脉总量**
>   （已含脾 3% 与胰 1%）。这样一来肝总入血流变成 28.5% 而非 25.5%，**高估约 12%**。
>   肝血流恰恰是肝清除率、也就是本项目闭合项目标 A 最敏感的那一个量。
>   正确做法是肠道取 16%（胃食管 1.0 + 小肠 10 + 大肠 4.0 + 胰 1.0），脾另计 3%。
> - 体重 70 kg → **73 kg**（ICRP 参考男性）；脾 0.19 → 0.15 L；皮肤 3.4 → 3.3 L；
>   脂肪 14.3 → 14.5 L（用"可分离脂肪、不含黄骨髓"那一行，否则与骨骼重复计算）。
>
> **这类错误不会让程序崩溃，只会让曲线看起来仍然合理。** 所以 `ReferenceIndividual`
> 的每个数值都带 `source::String`，测试里断言 $\sum q_i = 1$（肺除外）和
> 肝总入 = 25.5%——后者是从拓扑重新算出来的，与 ICRP 独立给出的数字对上才算通过。
>
> 另外注意：Brown et al. (1997) 与 ICRP 89 的数值**并不一致**（如肝 22.7% vs 25.5%、
> 肾 17.5% vs 19%），**两套不能混用**。本项目全程使用 ICRP 89。

---

## 2.8 Nondimensionalization (do this before touching the GPU)

Raw PBPK states span many orders of magnitude in concentration, and time constants span
three. Both hurt Float32 GPU arithmetic and hurt the optimizer's conditioning. Define

```math
\tilde{C} = \frac{C}{C_{\mathrm{ref}}}, \quad C_{\mathrm{ref}} = \frac{D}{V_{\mathrm{ss}}};
\qquad
\tilde{t} = \frac{t}{t_{\mathrm{ref}}}, \quad t_{\mathrm{ref}} = \frac{V_{\mathrm{ss}}}{\mathrm{CL}^{\mathrm{pop}}} .
```

In these variables, all states are $O(1)$ over most of the trajectory and the dominant
elimination time constant is $O(1)$.

Additionally, **optimize in log-space** for all strictly-positive parameters
($\mathrm{CL}$, $K_p$, $V_{\max}$, $K_m$, $k_a$). This enforces positivity for free and
makes the random-effects model $\eta \sim \mathcal{N}(0,\Omega)$ natural.

> **中文讲解｜CN**
> 无量纲化不是"锦上添花"，在本项目里是**必需的前置步骤**，原因有三：
> 1. **Float32 精度。** GPU 上用 Float32 才能跑满带宽，但 Float32 只有约 7 位有效数字。
>    如果状态量在 $10^{-3}$ 到 $10^{3}$ 之间横跨六个数量级，误差控制会失效。
> 2. **优化器条件数。** 参数尺度差几个数量级会让 Adam/L-BFGS 的表现急剧恶化。
> 3. **神经网络输入。** 神经网络对输入尺度极其敏感，喂给它 $O(1)$ 的量是基本要求。
>
> 另外**所有正定参数一律在对数空间优化**（$\log \mathrm{CL}$ 而非 $\mathrm{CL}$）：
> 免费获得正性约束，且与 $\eta \sim \mathcal{N}(0,\Omega)$ 的对数正态假设天然一致。
>
> 顺序上，**先做无量纲化、再上 GPU**。反过来做的话，你会花大量时间去调试
> 其实是精度问题的"GPU bug"。

---

## 2.9 Numerical checklist for $f_{\mathrm{known}}$

Before adding any neural network, the mechanistic model must pass:

1. **Mass conservation.** With all elimination set to zero, total drug amount is constant
   to solver tolerance for $t \in [0, 10^3 \tau_{\max}]$.
2. **Flow continuity.** $\sum_i Q_i = Q_{\mathrm{CO}}$ asserted at construction.
3. **Steady-state consistency.** Under constant IV infusion at rate $R_0$, the analytic
   steady state $C_{\mathrm{plasma}}^{ss} = R_0 / \mathrm{CL}$ is reproduced.
4. **Nonnegativity.** No state goes negative for physically valid parameters and
   reasonable tolerances (`isoutofdomain` or a positivity-preserving formulation).
5. **Reference-solution agreement.** Float32 GPU solution matches Float64 CPU solution to
   a stated relative tolerance (target: $<10^{-3}$ relative on plasma).
6. **Stiffness characterization.** Report $\max_i \tau_i / \min_i \tau_i$ and the spectral
   radius of the Jacobian for the parameter ranges of interest.

Item 6 determines whether an explicit GPU solver is viable.

> **中文讲解｜CN**
> 这六条是**在写任何神经网络代码之前必须全部通过的验收条件**。
> 尤其是第 1 条和第 5 条：
> - 第 1 条（关掉消除后质量严格守恒）是抓通量组装错误的最强手段；
> - 第 5 条（Float32 GPU 与 Float64 CPU 的一致性）建立了"参考解"，
>   将来 GPU 结果不对时，你才有办法二分定位是精度问题还是逻辑问题。
>
> 第 6 条（刚性刻画）直接决定 [05-gpu-strategy.md](05-gpu-strategy.md) 里的求解器选型：
> 如果 $\max\tau/\min\tau$ 只有 $10^2$ 量级，显式的 GPU Tsit5 可能够用；
> 如果达到 $10^4$，就必须上 GPU 上的刚性求解器，代价和实现难度都要重新评估。

---

**Next:** [03 — UDE Formulation](03-ude-formulation.md)
