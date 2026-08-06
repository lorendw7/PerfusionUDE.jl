# 01 — Background & Motivation

## 1.1 A PBPK model is a lumped-parameter transport network

Classical compartmental PK ("one-compartment with first-order elimination") treats the
body as an abstract volume with no anatomical meaning. PBPK does the opposite: every
compartment is a real organ with a measured volume $V_i$ and a measured blood flow $Q_i$,
and the compartments are wired together in the anatomical topology of the circulation.

The structure is fixed by anatomy:

```
                    ┌──────────────────────────────┐
                    │                              │
              ┌─────▼─────┐                        │
   ┌─────────►│   LUNG    ├────────┐               │
   │          └───────────┘        │               │
   │                               ▼               │
┌──┴──────┐                  ┌───────────┐         │
│ VENOUS  │                  │ ARTERIAL  │         │
│  POOL   │                  │   POOL    │         │
└──▲──────┘                  └─────┬─────┘         │
   │                               │               │
   │   ┌────────┬────────┬─────────┼────────┐      │
   │   │        │        │         │        │      │
   │ ┌─┴──┐  ┌──┴──┐  ┌──┴───┐  ┌──┴──┐  ┌──┴───┐  │
   └─┤BRAIN│ │MUSCLE│ │ADIPOSE│ │KIDNEY│ │ GUT  │  │
     └────┘  └─────┘  └──────┘  └──┬──┘  └──┬───┘  │
                                   │        │      │
                              (renal CL)    │ portal vein
                                            ▼      │
                                       ┌─────────┐ │
                                       │  LIVER  ├─┘
                                       └─────────┘
                                      (hepatic CL)
```

Mass balance on each node, convective coupling on each edge. **This is a directed graph
finite-volume discretization with one cell per organ.** It is the same object as a 0D
lumped-parameter flow network in CFD, and the same object as the Windkessel models used
as outflow boundary conditions in 3D hemodynamics — only the transported quantity differs
(drug mass instead of blood volume/pressure).

> **中文讲解｜CN**
> 请把上图看成一张**有向图上的有限体积网格**：每个器官是一个控制体，每条血管是一条通量边，
> 节点上写质量守恒。你在 CFD 里做的所有事情——守恒律离散、通量组装、源项处理、时间推进——
> 在这里都原封不动地成立，只是网格只有十几个单元，且拓扑由解剖学固定而非由网格生成器给出。
>
> 特别注意两条"非平凡边"：
> - **门静脉**：肠道的血流不直接回心脏，而是先进肝脏 → 这是"首过效应"的结构来源；
> - **肺**：全部心输出量都要过肺 → 肺是串联在回路上的，不是并联分支。
>
> 这两条边让图不是简单的星形拓扑，也是 PBPK 与朴素房室模型的本质区别。

---

## 1.2 What is well known, and what is not

The strength of PBPK is that a large part of the model is **not fitted at all** — it is
looked up.

| Model component | Source | Uncertainty |
|---|---|---|
| Compartment volumes $V_i$ | Reference-individual anatomy (ICRP, Brown et al.), scaled by body weight / BSA | Low (±10–20%) |
| Blood flows $Q_i$ | Same references, as fractions of cardiac output | Low–moderate |
| Cardiac output $Q_{\mathrm{CO}}$ | Allometric scaling from body weight | Moderate |
| Plasma protein binding $f_u$ | Measured in vitro | Moderate |
| Tissue partition $K_{p,i}$ | Predicted from physicochemistry (Rodgers–Rowland, Poulin–Theil) | **High** |
| Intrinsic clearance $\mathrm{CL}_{\mathrm{int}}$ | Scaled from in vitro microsomes/hepatocytes | **High** |
| Transporter-mediated uptake | Often simply omitted | **Very high** |
| Nonlinear / time-dependent effects (autoinduction, inhibition, saturable binding) | Ad hoc empirical terms | **Very high** |

The first three rows are the "known physics". The last four are the closure problem.

> **中文讲解｜CN**
> 这张表是整个课题的立论基础，务必理解透。
>
> **PBPK 的价值在于：模型中相当大一部分不是"拟合出来的"，而是"查出来的"。**
> 器官容积和血流量来自解剖学参考值，按体重/体表面积缩放即可，不确定性很小。
>
> 但是表格下半部分——组织分配系数、内在清除率、转运体介导的摄取、非线性时变效应——
> 要么靠体外实验外推（外推误差常达数倍），要么靠经验公式，要么干脆被忽略。
>
> 这就是典型的**闭合问题**：控制方程的守恒部分是可信的，本构关系是不可信的。
> 在 CFD 里你会说"RANS 方程本身是精确的，问题出在湍流模型上"——这里是完全一样的处境。

---

## 1.3 Why the empirical closures fail

Take hepatic elimination. The textbook closure is Michaelis–Menten:

$$
R_{\mathrm{elim}} = \frac{V_{\max}\, C_u}{K_m + C_u}
$$

This is derived under assumptions that are routinely violated in vivo:

1. **Single enzyme, single substrate.** Real drugs are cleared by several CYP isoforms
   plus conjugation plus biliary transport, each with its own kinetics. The sum of several
   MM terms is not an MM term.
2. **Free intracellular concentration equals free plasma concentration.** This fails
   whenever an active uptake transporter (OATP, OCT) concentrates drug in the hepatocyte.
   The apparent $K_m$ then becomes a lumped, condition-dependent quantity.
3. **Enzyme amount constant in time.** Violated by autoinduction (drug increases its own
   metabolism over days) and mechanism-based inhibition (drug destroys its own enzyme).
4. **No metabolite feedback.** Metabolites frequently compete for the same enzyme.

Similarly, the perfusion-limited distribution closure

$$
\text{flux into tissue } i \;=\; Q_i\!\left(C_{\mathrm{art}} - \frac{C_i}{K_{p,i}/R_b}\right)
$$

assumes instantaneous intra-tissue equilibrium with a *constant, concentration-independent*
partition coefficient. That fails for drugs with saturable tissue binding, for
transporter-rich tissues (brain, kidney, liver), and for tissues where membrane
permeability, not perfusion, is rate-limiting.

The usual response is to add more empirical terms and more fitted parameters. The result
is a model that interpolates the calibration dataset and extrapolates badly — again,
exactly the failure mode of over-tuned algebraic turbulence models.

> **中文讲解｜CN**
> 这一节要说明的是：**经验闭合式的失效不是"参数没调好"，而是函数形式本身就是错的。**
>
> 米氏方程的推导前提（单酶、单底物、胞内游离浓度=血浆游离浓度、酶量不随时间变化）在体内几乎
> 条条被违反。多个酶的米氏项之和**不是**一个米氏项——就像多个尺度的涡黏性之和不是一个涡黏性。
>
> 传统做法是"再加一项经验修正、再加两个可调参数"，结果是标定集拟合得漂亮、外推就崩。
> 这与过度标定的代数湍流模型是同一种病。
>
> UDE 的思路则是：**不要再猜函数形式了，把这一项交给神经网络，让数据决定它长什么样。**
> 但同时保留守恒律和已知的输运结构——这是它与纯黑箱模型的关键区别。

---

## 1.4 The UDE proposition

Instead of guessing a functional form, write

$$
\frac{d\mathbf{u}}{dt} \;=\; \underbrace{f_{\mathrm{known}}(\mathbf{u}, \boldsymbol{\theta})}_{\text{mass balance + perfusion: trusted}} \;+\; \underbrace{\mathcal{N}_{\boldsymbol{\phi}}(\mathbf{u}, \boldsymbol{\theta}, t)}_{\text{unknown mechanism: learned}}
$$

and estimate $\boldsymbol{\phi}$ from data.

Three properties make this attractive here, and they are the reasons to prefer a UDE over
either a pure mechanistic model or a pure neural ODE:

1. **Conservation is enforced by construction**, not learned. The network only ever
   modifies terms whose sign and location in the network are known.
2. **Extrapolation in the mechanistic directions is retained.** Changing body weight,
   organ volume, or dose changes $f_{\mathrm{known}}$ correctly, without retraining.
3. **The learned term is interpretable and testable.** Because $\mathcal{N}_{\boldsymbol{\phi}}$
   has a small, known input set, it can be plotted, compared against the nominal
   Michaelis–Menten curve, and passed to symbolic regression to recover a candidate
   formula.

Property 3 is the scientific payoff and must be planned for from the beginning — see
[06-identifiability.md](06-identifiability.md).

> **中文讲解｜CN**
> 为什么不直接上纯黑箱的 Neural ODE？三个理由：
> 1. **守恒律不用学。** 网络只修改"我们知道位置和符号"的项，质量守恒由结构保证，不靠数据保证。
> 2. **机理方向的外推能力保留。** 换体重、换器官容积、换剂量，$f_{\mathrm{known}}$ 自动正确响应，
>    不需要重训。纯黑箱做不到这一点。
> 3. **学到的项可解释、可检验。** 网络输入维度很小（通常 1–3 维），可以直接画出来，跟名义米氏
>    曲线对比，还能送去符号回归还原成公式。
>
> 第 3 点是本课题真正的科学产出——**不是"我拟合得比别人准"，而是"我把隐藏机制学回来了并且
> 写成了公式"**。这一点必须从一开始就设计进验证方案，不能等做完再补。

---

## 1.5 Why the inverse problem needs a GPU

A single individual's PBPK model is cheap: ~15 ODE states, integrated over hours to days.
On a CPU this takes milliseconds. There is no reason to involve a GPU.

The computational problem appears in **population pharmacokinetics**. A real study
contains $N = 10^2$–$10^4$ individuals, each with different body weight, organ volumes,
enzyme activity (genotype-dependent), and renal function. Each individual is described by
the *same* ODE structure with *different* parameters. The inverse problem is to recover,
simultaneously:

- each individual's physiological parameters $\{\boldsymbol{\eta}_j\}_{j=1}^N$,
- the population distribution $(\boldsymbol{\theta}_{\mathrm{pop}}, \boldsymbol{\Omega})$,
- the shared neural closure $\boldsymbol{\phi}$.

Every optimizer iteration requires integrating all $N$ systems and differentiating through
all of them. With $N = 10^3$, a few hundred outer iterations, and gradient evaluation
costing several forward solves, the total is $10^5$–$10^7$ ODE solves.

This is precisely the workload GPUs are built for: **many small, structurally identical,
parameter-varying ODE integrations, executed in lockstep.** `DiffEqGPU.jl`'s
`EnsembleGPUKernel` is designed for exactly this shape, with reported speedups of one to
two orders of magnitude over multithreaded CPU ensembles for small systems.

The direct methodological analogue in CFD is the **UQ ensemble**: propagating parametric
uncertainty by running many instances of the same solver with perturbed inputs. The
difference here is that we do not merely propagate — we *invert*, i.e. we differentiate
through the ensemble and optimize.

> **中文讲解｜CN**
> 这一节回答"为什么需要 GPU"，必须讲清楚，否则课题会被质疑"用 GPU 是为了用而用"。
>
> **单个个体的 PBPK 根本不需要 GPU**——15 个状态、CPU 上几毫秒就解完了。诚实地承认这一点。
>
> GPU 的落点在**群体反问题**：$N$ 个个体，结构完全相同、参数各不相同的 ODE。
> 每次优化器迭代都要把 $N$ 条轨迹全部积分一遍并求梯度，总计算量是 $10^5$–$10^7$ 次 ODE 求解。
>
> 这个形状——**大量小规模、结构同构、参数异构的 ODE 并行积分**——正是 GPU 的最佳适用场景，
> 也正是 `DiffEqGPU.jl` 的 `EnsembleGPUKernel` 设计目标。
>
> 与 CFD 的对应：这就是 **UQ 集成模拟**。区别在于我们不只是"正向传播不确定性"，
> 而是要**反演**——要穿过整个 ensemble 求梯度并优化。这就把 UQ ensemble 和伴随反问题
> 两条 CFD 方法论合在了一起。

---

## 1.6 Positioning relative to existing work

> ⚠️ **Superseded.** This section reflects the position as of the original draft. A
> literature sweep on 2026-08-06 found four papers that change it materially — including
> variational EM for neural NLME at 15k parameters, a formal functional-identifiability
> framework for UDEs, and an open-source composable Julia NLME package. **Read
> [11 — Literature Landscape](11-literature-landscape.md) instead**; the revised novelty
> statement is in [11 §11.4](11-literature-landscape.md). The section below is kept for
> the reasoning, not the conclusions.

Honest positioning matters for a thesis proposal. The following already exist:

- **UDEs in pharmacology.** Rackauckas et al. introduced the UDE framework, and
  Pumas-AI's *DeepPumas* is a commercial product that combines neural networks with
  nonlinear mixed-effects models. The idea "neural network inside a PK ODE" is **not
  novel**.
- **GPU ensemble ODE solving.** `DiffEqGPU.jl` is an established tool.
- **Population PBPK.** Standard practice in industry, using NONMEM / Monolix / Pumas /
  PK-Sim.

What this project can legitimately claim as its contribution:

1. **Joint, gradient-based inversion of individual physiology *and* a shared neural
   closure at population scale on GPU** — as opposed to the standard two-stage or
   EM-based workflows. The scaling behaviour of this approach is not well documented.
2. **A quantitative recovery study**: under what data density, noise level, and population
   size can a hidden mechanism actually be recovered? This is a
   *practical-identifiability* question, and it is largely open.
3. **The explicit methodological bridge to CFD closure modelling and adjoint-based
   inverse problems**, which frames PBPK as one instance of a general
   lumped-parameter-network inverse problem.

Claims 1–3 are defensible. "We invented neural PBPK" is not.

> **中文讲解｜CN**
> 这一节是写给开题报告的**诚实定位**。评审老师一定会问"这个想法别人做过没有"，
> 提前把答案写在文档里，比被当场问住好得多。
>
> 已经存在的：UDE 框架（Rackauckas）、DeepPumas（商业产品，神经网络+NLME）、
> DiffEqGPU、群体 PBPK 工业实践。所以 **"把神经网络塞进 PK 的 ODE 里"这个 idea 本身不新。**
>
> 可以站得住的贡献有三条：
> 1. **GPU 上大规模、基于梯度的"个体生理参数 + 共享神经闭合项"联合反演**——
>    不是两阶段、不是 EM，而是端到端联合优化；这条路的可扩展性文献里没有系统研究过。
> 2. **定量的可恢复性研究**：数据多稀疏、噪声多大、群体多大时，隐藏机制才能被学回来？
>    这是实际可辨识性问题，基本是开放的。
> 3. **与 CFD 闭合建模、伴随反问题的方法论桥接**——把 PBPK 表述为
>    "集总参数网络反问题"的一个实例。
>
> 千万不要写成"我们发明了神经 PBPK"，那是站不住的。

---

**Next:** [02 — PBPK Forward Model](02-pbpk-forward-model.md)
