# 11 — Literature Landscape & Repositioning (August 2026)

Results of the literature sweeps conducted **2026-08-06** (§11.1–§11.5) and
**2026-08-07** (§11.6), and the consequent revisions to the research plan. **Read this
before [01 §1.6](01-background.md) — it supersedes the positioning written there.**

**§11.6 amends §11.1–§11.5. Where the two disagree, §11.6 wins.**

Citation status is marked explicitly:
**[V]** = title/authors/venue confirmed during this sweep ·
**[U]** = pointer only, **you must verify before citing**.

> **中文讲解｜CN**
> 本文档是 2026-08-06 做的文献扫描结果，以及由此对研究计划的修正。
> **它取代 [01 §1.6](01-background.md) 里的定位段落。**
>
> 每条文献都标了状态：**[V]** 表示本次检索中确认了标题/作者/出处；
> **[U]** 表示只是检索线索，**引用前必须自己核实**。
> 请严格遵守这个区分——用未核实的引用会在送审时出问题。

---

## 11.1 The field moved. Four papers change the plan.

### (1) Functional identifiability for UDEs — Loman & Baker, 2025 **[V]**

*Functional and parametric identifiability for universal differential equations applied to
chemical reaction networks*, arXiv:2510.14140.

This is the single most important paper for this project. It supplies the vocabulary and
the theory that [06-identifiability.md](06-identifiability.md) was groping toward:

- **Parametric identifiability** — can the mechanistic parameters be recovered?
- **Functional identifiability** — can the unknown *function* represented by the network be
  recovered?

Two findings, one reassuring and one alarming:

> Reassuring: across a wide range of models, generalising a fully mechanistic model to a
> UDE has **little impact on the mechanistic components' parametric identifiability**.

> Alarming: for some hybrid models, fitting the UDE is **equivalent to fitting a fully
> data-driven neural ODE** — i.e. the hybrid formulation contributes no mechanistic
> knowledge at all.

**Consequence for this project — a new mandatory test.** We must prove our UDE is *not*
in the degenerate class. Concretely, add to Phase 1:

> **Test D (mechanistic-content test).** Show that the Phase-1 UDE is not observationally
> equivalent to an unconstrained neural ODE on the same observable. Operationally: fit both
> to the same twin data; if their fits *and* their held-out-dose predictions coincide, the
> mechanistic skeleton is contributing nothing and the closure must be further constrained.

Note this is a sharper version of baseline **B3** in
[07 §7.3](07-validation-protocol.md): B3 was a performance comparison; Test D is an
identifiability statement.

> **中文讲解｜CN**
> **这篇是本次检索里对项目影响最大的一篇，务必精读。**
>
> 它把 UDE 的可辨识性正式拆成两类，正好补上了我们 [06](06-identifiability.md) 里缺的理论语言：
> - **参数可辨识性**：机理参数能不能定？
> - **函数可辨识性**：网络代表的那个未知函数能不能恢复？
>
> 两个结论一好一坏：
> - **好消息**：加了神经网络之后，机理参数的可辨识性通常**不会明显变差**。
>   这缓解了我们在 [06 §6.1](06-identifiability.md) 里最担心的"网络吸收一切"的忧虑。
> - **坏消息**：某些混合模型，**拟合 UDE 等价于拟合一个纯黑箱 neural ODE**——
>   也就是说机理骨架完全没起作用，只是个装饰。
>
> 后者直接产生一条新的必做检验（**Test D**）：
> 必须证明我们的 UDE **不属于**这个退化类。做法是把 UDE 和无约束 neural ODE 同时拟合同一批孪生数据，
> 如果两者的拟合**和留出剂量预测都一致**，说明机理结构没有贡献任何信息，
> 必须回头加强闭合项的约束（缩小输入集、加强结构约束）。
>
> 注意它比原来的基线 B3 更强：B3 只是比性能，Test D 是**可辨识性层面的判定**。
> 建议在论文里把 Test D 单列一节——主动做这个检验，会显著提高工作的可信度。

**Related, verify before citing:**
- *Structural functional identifiability and model discovery in differential equation
  models*, arXiv:2606.30289 **[U]**
- *Robust parameter estimation and identifiability analysis with hybrid neural ODEs in
  computational biology*, npj Systems Biology and Applications, 2024,
  doi:10.1038/s41540-024-00460-3 **[U — authors unverified]**
- *Structural Identifiability of Compartmental Models: Recent Progress and Future
  Directions*, arXiv:2507.04496 **[U]**
- *A Tutorial on Structural Identifiability of Epidemic Models Using
  StructuralIdentifiability.jl*, arXiv:2505.10517 **[U]** — useful as a how-to template.

---

### (2) Variational EM for large neural NLME — Tarek & Afonso, 2026 **[V]**

*Fitting Large Nonlinear Mixed Effects Models Using Variational Expectation Maximization*,
arXiv:2604.26160. Uses flexible variational families + reverse-mode AD to maximize the
marginal likelihood; demonstrated on a warfarin model and a **DeepNLME Friberg model with
15,410 population parameters and 16 random effects**. Implemented in Pumas.

**Two consequences.**

**(a) A claim we can no longer make.** "Large-scale neural NLME" as such is taken. Their
scaling axis is the **number of population parameters** (network weights). Ours must be
explicitly the **number of individuals $N$ and the cost of the ensemble ODE solve** —
a different axis, and one where GPU ensembles are the natural answer. State this
distinction in the paper; do not let a reviewer discover it.

**(b) An upgrade to our estimation strategy.** VEM is a strictly better-motivated version
of what [04 §4.3](04-population-inverse-problem.md) filed under (S3) "amortized/variational
inference" and deprioritized. Revise:

| Strategy | Old status | **New status** |
|---|---|---|
| S1 Joint MAP | Primary | Primary for Phases 1–3 (GPU-friendly, simple) |
| S2 Laplace / FOCE | Phase 4 | Phase 4, unchanged — bias reference |
| **S3 Variational EM** | "distraction, Phase 5+" | **Promoted to Phase 4.** Marginal-likelihood-correct, reverse-mode-AD-friendly, published precedent at scale |
| S4 Full Bayes | Small-$N$ reference | Unchanged |

> **中文讲解｜CN**
> 这篇有两个后果，一坏一好。
>
> **坏消息**：**"大规模神经 NLME"这个卖点已经被占了。**
> 但注意他们的"大规模"是**参数量大**（15,410 个总体参数），
> 而我们的"大规模"是**个体数 N 大、ensemble ODE 求解贵**——**两条不同的轴**。
> 这个区分必须在论文里主动写清楚，不要等审稿人来发现。
>
> **好消息**：VEM 是我们原来在 [04 §4.3](04-population-inverse-problem.md) 里
> 归为 S3 并且打算不做的那条路的成熟版本，而且**它在边缘似然意义上是正确的**
> （不像 S1 联合 MAP 会低估方差）。既然已有大规模成功先例，
> **把 S3 从"Phase 5+ 或不做"提升到 Phase 4**，作为 S1 的统计学升级路径。
>
> 顺带一提：这也说明我们在 [04 §4.3](04-population-inverse-problem.md) 里
> 主动承认 S1 方差偏差是对的——现在有了现成的解决方案可以对接。

---

### (3) NoLimits.jl — Huth, Arruda, Schmid, Gusinow, Wieland, Peiter, Hasenauer, 2026 **[V]**

*NoLimits.jl: Flexible and Composable Nonlinear Mixed-Effects Modeling in Julia*,
arXiv:2606.24427; `github.com/manuhuth/NoLimits.jl`.

Open-source Julia NLME, composable, built on DifferentialEquations.jl, supports
likelihood/EM/Bayesian inference (Turing.jl backend), and mentions UDE support. GPU
support not documented.

**This is the closest open-source competitor, and the correct response is to compose with
it rather than duplicate it.**

Recommended architecture consequence:

> **PerfusionUDE.jl provides (i) the PBPK transport-network domain layer, (ii) the
> constrained neural-closure layer, (iii) the GPU population-ensemble and mixed-mode
> gradient layer, and (iv) the identifiability/recoverability analysis tooling.
> It provides its own lightweight joint-MAP estimator, and offers an interoperability path
> so that NoLimits.jl (or Pumas) can be used as the inference backend where a
> marginal-likelihood-correct estimator is required.**

For JOSS this is a much stronger story than "another NLME package": it is a domain layer
plus a compute layer that fills a documented gap, and it demonstrates ecosystem
citizenship rather than reinvention.

> **中文讲解｜CN**
> **NoLimits.jl 是最接近的开源竞品，但正确的应对不是竞争而是"组合"。**
>
> 理由有三：
> 1. 重造一个通用 NLME 包，工作量巨大且没有胜算——他们已经做了；
> 2. JOSS 明确要求说明"与现有软件相比有什么不同"，
>    "又一个 NLME 包"是最弱的回答，"领域层 + 计算层，与现有推断引擎互操作"是最强的回答；
> 3. 生态友好在 JOSS 评审里是加分项（reviewer 常常就是生态里的人）。
>
> 所以 PerfusionUDE.jl 的定位应当收窄并明确为四层：
> **(i) PBPK 输运网络领域层 → (ii) 受约束的神经闭合层 → (iii) GPU 群体 ensemble 与混合模式梯度层
> → (iv) 可辨识性/可恢复性分析工具**，
> 自带一个轻量的联合 MAP 估计器，同时开放接口让 NoLimits.jl / Pumas 作为推断后端。
>
> **这个定位收窄是本次修订最重要的一条产品决策**，直接决定 JOSS 论文能不能过。

---

### (4) The gap: no general-purpose open-source Julia PBPK package **[V, by absence]**

What exists:
- `metrumresearchgroup/bioPBPK` — a **collection of PBPK models** in Julia and mrgsolve,
  not a package with an API.
- `metrumresearchgroup/BayesPBPK-tutorial` — companion to Elmokadem et al., *Bayesian PBPK
  modeling using R/Stan/Torsten and Julia/SciML/Turing.jl*, CPT:PSP 2023,
  doi:10.1002/psp4.12926 **[V]**. A **tutorial**, not a package.
- `Kwatee-PBPKModel-Plugin` (varnerlab) — a **code generator**, largely dormant.
- Pumas.jl — handles PBPK, **commercial and closed**.
- PK-Sim / MoBi (Open Systems Pharmacology) — open-source PBPK, but a GUI/XML modelling
  environment with no differentiable-programming or GPU-ensemble path.

No package occupies "composable, differentiable, GPU-parallel PBPK in Julia". **That is the
JOSS niche, and it is a real one.**

> **中文讲解｜CN**
> 这一条是**通过"检索不到"确立的空白**，也是 JOSS 论文 statement of need 的核心。
>
> 现状梳理清楚了：
> - bioPBPK = **模型集合**，不是包（没有 API）；
> - BayesPBPK-tutorial = **教程仓库**，配套 Elmokadem 2023 CPT:PSP 论文；
> - Kwatee 插件 = 代码生成器，基本停止维护；
> - Pumas.jl = 能做，但**商业闭源**；
> - PK-Sim/MoBi = 开源 PBPK，但是 GUI/XML 环境，**没有可微编程和 GPU 路径**。
>
> 也就是说，**"可组合、可微、GPU 并行的 Julia PBPK"这个位置是空的**。
>
> ⚠️ 提醒：**这类"空白"论证有时效性。** 建议在投 JOSS 前一周重新检索一遍，
> 确认这半年里没有新包出现；如果出现了，及时调整 statement of need。
> 在论文里也要写明检索日期。

---

## 11.2 The PBPK + deep learning landscape is crowding fast

All 2024–2026, all **[U]** — verify before citing, but note the trend:

| Work | Approach | How we differ |
|---|---|---|
| *Dynamic Graph Neural Network for Data-Driven PBPK Modeling*, arXiv:2510.22096 | GNN over the compartment graph, largely data-driven | We keep the ODE and conserve mass; they learn the dynamics |
| *PBPK-iPINNs: Inverse PINNs for PBPK Brain Models*, arXiv:2509.12666 | PINN-based inverse parameter estimation | Single-subject; no population hierarchy, no ensemble |
| *PINNs for Chemotherapy PK: ... Exposing Parameter Identifiability*, arXiv:2606.12658 | PINN + identifiability | Confirms identifiability is the field's live issue |
| *Neural Controlled Differential Equations in PK/PD*, PMC12823316 | NCDE for irregular sampling | Black-box; no mechanistic conservation |
| *Bridging pharmacology and neural networks: neural ODEs*, Losada et al., CPT:PSP 2024, doi:10.1002/psp4.13149 | Review | Use as the framing reference for a PK audience |
| *Deep compartment models*, CPT:PSP 2022, PMC9286722 | NN predicts PK parameters from covariates; ODE stays mechanistic | **A different hybridization point** — worth an explicit comparison |
| *Data-driven discovery of feedback in AML with Deep NLME + symbolic regression*, bioRxiv 2024.06.17.599366 | DeepNLME + symbolic recovery | **Closest to our §6.5 workflow** — read carefully |

Two of these deserve action:

- **Deep compartment models** put the network on the *covariate → parameter* map, leaving
  the ODE untouched. We put it *inside the RHS*. These are complementary and a reviewer
  will ask why we chose ours. Answer: theirs cannot discover an unknown *mechanism*, only
  an unknown *covariate relationship*. Make that explicit, and consider adding it as a
  fifth baseline (**B4**).
- **The AML DeepNLME + symbolic regression paper** already executes the
  "learn a term, then symbolically recover it" workflow of
  [06 §6.5](06-identifiability.md), in a different disease area. Read it before writing
  our own methods section, and cite it as precedent rather than presenting the workflow as
  novel.

> **中文讲解｜CN**
> **这个领域 2024–2026 明显在加速，"PBPK + 深度学习"已经不是空白了。**
> 但注意：这些工作大多是 **(a) 单个体、(b) 正向替代模型、或 (c) 纯数据驱动**，
> 我们的"群体反问题 + 守恒约束闭合 + 机制恢复"仍然有位置。
>
> 两条要立即行动：
>
> 1. **Deep compartment models（CPT:PSP 2022）把网络放在"协变量→参数"的映射上，ODE 不动。**
>    我们把网络放在 **RHS 内部**。这是两个不同的杂交点，审稿人一定会问为什么选我们这种。
>    答案要准备好：**他们的方法只能发现未知的协变量关系，发现不了未知的机制。**
>    建议把它加成第五个基线 **B4**——这个对比很有说服力。
>
> 2. **AML 那篇（DeepNLME + 符号回归）已经把我们 [06 §6.5](06-identifiability.md) 的工作流跑过一遍了**，
>    只是换了疾病领域。**务必在写方法学章节之前读它**，并且把它作为先例引用，
>    不要把"学一个项再符号回归还原"当作我们的原创贡献——那会被一眼识破。

---

## 11.3 GPU precedent in pharmacometrics

- *Novel hybrid GPU–CPU implementation of parallelized Monte Carlo parametric expectation
  maximization for population PK*, PubMed 24002801 (≈2013) **[U]** — GPU population PK has
  a decade-old precedent, but on **MCPEM sampling**, not on differentiable ensemble ODE
  solving. Cite it so the novelty claim is precise.
- *GACELLE: GPU-accelerated tools for model parameter estimation and image reconstruction*,
  PMC12676372 **[U]** — adjacent, general-purpose.
- **Utkarsh et al., 2024 [V]** — *Automated translation and accelerated solving of
  differential equations on multiple GPU platforms*, Computer Methods in Applied Mechanics
  and Engineering 419:116591, arXiv:2304.06835. The `DiffEqGPU.jl` paper. Reports
  outperforming hand-written C++/CUDA and 20–100× over `vmap`-based JAX/PyTorch for
  ensembles of small ODEs, across NVIDIA/AMD/Intel/Apple via KernelAbstractions.jl.
  **This is the load-bearing citation for [05](05-gpu-strategy.md).**

> **中文讲解｜CN**
> 第一条很重要：**GPU 加速群体药代不是全新的**，2013 年就有 MCPEM 的 GPU 实现。
> 所以我们的新颖性表述必须精确到："**可微的** ensemble ODE 求解 + 端到端梯度联合反演"，
> 而不是笼统的"用 GPU 做群体 PK"。**把这条先例主动引出来，比被审稿人指出来好。**
>
> Utkarsh et al. 2024 是 [05](05-gpu-strategy.md) 的**承重引用**，
> 它的 20–100× 加速数据是我们性能预期的依据（但注意那是小 ODE ensemble 的场景，
> 我们的 PBPK 有 16 个状态，属于该论文的适用范围内，但仍需自己测）。

---

## 11.4 Revised novelty statement

Everything above compresses into one paragraph that should appear, in some form, in every
document, proposal, and paper:

> Neural closures inside PK ODEs exist (DeepPumas, DeepNLME). Large-scale neural NLME
> fitting exists (variational EM, 15k parameters). GPU ensemble ODE solving exists
> (DiffEqGPU.jl). Open composable Julia NLME exists (NoLimits.jl). GPU population PK
> exists (MCPEM, 2013). **What does not exist is (i) an open, differentiable, GPU-parallel
> PBPK transport-network layer, (ii) a systematic characterization of when a
> physiologically-constrained closure is *functionally identifiable* from population PK
> data as a function of population size, sampling density, and noise, and (iii) the
> mechanistic-content test that distinguishes a genuine hybrid model from a disguised
> neural ODE.** (i) is the software contribution; (ii) and (iii) are the scientific
> contribution.

> **中文讲解｜CN**
> 这段是**修订后的新颖性陈述**，建议直接背下来，开题、JOSS 论文、PLOS 论文里反复用。
>
> 它的结构值得学习：**先把所有已经存在的东西一条条列出来**（神经闭合、大规模神经 NLME、
> GPU ensemble、开源 Julia NLME、GPU 群体 PK），**然后才说什么不存在**。
>
> 这种"先自曝竞品再定位"的写法比"我们首次提出……"强得多：
> - 它证明你做了扎实的文献工作；
> - 它让剩下的空白显得可信（因为读者看到你没有回避）；
> - 它把贡献切得很具体，审稿人不容易攻击。
>
> 三条贡献里，**(i) 是软件贡献 → JOSS**，**(ii)(iii) 是科学贡献 → PLOS Comp Biol**。
> 这个切分直接对应 [13-publication-strategy.md](13-publication-strategy.md) 的双论文策略。

---

## 11.5 Plan amendments (checklist)

- [ ] Adopt the parametric / functional identifiability vocabulary throughout
      [06](06-identifiability.md).
- [ ] **Add Test D (mechanistic-content test)** to Phase 1 exit criteria.
- [ ] Add baseline **B4** (deep compartment model: NN on covariate → parameter map).
- [ ] Promote **S3 variational EM** to Phase 4; keep S1 as the GPU workhorse.
- [ ] Reframe the scaling claim: axis is **$N$ (individuals)**, not parameter count.
- [ ] Narrow the package scope to the four layers of §11.3; add a NoLimits.jl
      interoperability path.
- [ ] Read before writing the methods section: Loman & Baker 2025; the AML DeepNLME +
      symbolic regression preprint; Deep compartment models (CPT:PSP 2022).
- [ ] Re-run this literature sweep one week before each submission, and record the date.

---

# 11.6 Second sweep — 2026-08-07

A verification pass over §11.1–§11.5 plus a deliberate search of the **pharmacometrics
journals** rather than arXiv alone.

**Method and its limits.** Every entry below was checked for title, authors and venue via
web search. **No full text was read.** `[V]` therefore means exactly what it meant in the
first sweep — the reference exists as stated — and nothing about whether the paper's
claims survive scrutiny. The papers flagged **READ** below still have to be read before
the methods section is written.

> **中文讲解｜CN**
> 本节是对第一次扫描的复核，外加一次**针对药代动力学期刊**的补充检索。
>
> **必须说清楚验证的深度**：下面每一条都核实了标题/作者/发表venue，但**没有读全文**。
> 所以 `[V]` 的含义仍然是"这篇文献确实存在且信息无误"，
> **不代表**其结论已被审阅。标了 **READ** 的几篇仍然必须在动笔写方法学之前读完。

## 11.6.1 Citation status upgrades

All four of these were `[U]` in the first sweep and are now confirmed:

| First sweep | Status now | Full reference |
|---|---|---|
| "hybrid neural ODEs, npj Syst Biol Appl, authors unverified" | **[V]** | Giampiccolo, Reali, Fochesato, Iacca, Marchetti, *Robust parameter estimation and identifiability analysis with hybrid neural ordinary differential equations in computational biology*, npj Systems Biology and Applications, Nov 2024, doi:10.1038/s41540-024-00460-3 |
| "Deep compartment models, PMC9286722" | **[V]** | Janssen et al., *Deep compartment models: a deep learning approach for the reliable prediction of time-series data in pharmacokinetic modeling*, CPT:PSP, 2022, doi:10.1002/psp4.12808 |
| "AML DeepNLME + symbolic regression preprint" | **[V]** | *Data-driven discovery of feedback mechanisms in acute myeloid leukaemia: alternatives to classical models using deep nonlinear mixed effect modeling and symbolic regression*, bioRxiv, 2024-06-19, doi:10.1101/2024.06.17.599366 |
| "arXiv:2606.30289 structural functional identifiability" | **[V]** | *Structural functional identifiability and model discovery in differential equation models*, arXiv:2606.30289 |
| "NCDE in PK/PD, PMC12823316" | **[V]** | *Neural controlled differential equation and its application in pharmacokinetics and pharmacodynamics*, CPT:PSP, 2026; 15:e70146 |

The two load-bearing `[V]` citations of the first sweep were re-confirmed independently:
**Loman & Baker, arXiv:2510.14140** (Torkel E. Loman, Ruth E. Baker) and **NoLimits.jl,
arXiv:2606.24427** (Huth, Arruda, Schmid, Gusinow, Wieland, Peiter, Hasenauer). The
NoLimits.jl abstract confirms the §11.1(3) reading: macro-based model language over ODEs,
Markov models and neural networks; Laplace / stochastic EM / MCMC inference; normalizing
flows for random-effects distributions. **GPU is still not mentioned.**

## 11.6.2 The first sweep had an arXiv bias — five works it missed

This is the substantive finding of the second sweep. §11.2 surveyed preprints thoroughly
and under-sampled **CPT: Pharmacometrics & Systems Pharmacology** and **Clinical and
Translational Science**, which is where the directly competing work is published. Three of
the five below are *closer to this project* than several papers §11.2 does list.

### (a) Valderrama et al., CPT:PSP 2024 **[V] — READ FIRST**

*Integrating machine learning with pharmacokinetic models: benefits of scientific machine
learning in adding neural networks components to existing PK models*, doi:10.1002/psp4.13054.

Learns an **unknown absorption process with a neural network while simultaneously
estimating the remaining distribution and elimination parameters** of a one-compartment PK
model, and evaluates extrapolation to **new dosing regimens at different sparsity levels
and to new patients**.

**This is the same hybridization point as ours** — network inside the ODE right-hand side,
mechanistic parameters estimated jointly — one compartment instead of a PBPK network, and
without the population hierarchy or the identifiability analysis. §11.4 says "neural
closures inside PK ODEs exist (DeepPumas, DeepNLME)", which is true but names the wrong
precedent: **this is the closest published one, and it is not currently cited anywhere in
the plan.**

Its extrapolation protocol also overlaps our held-out-dose validation in
[07](07-validation-protocol.md). Read it before finalising that protocol — either we adopt
their setup and cite it, or we say why ours differs.

### (b) Valderrama et al., CPT:PSP 2025 **[V] — READ**

*Comparing scientific machine learning with population pharmacokinetic and classical
machine learning approaches for prediction of drug concentrations*, CPT:PSP 14(4):759–769,
doi:10.1002/psp4.13313 (preprint medRxiv 2024.05.06.24306555). Proposes **MMPK-SciML** and
benchmarks it against PopPK and classical ML.

This is the **population-level** follow-up to (a), i.e. it occupies part of the ground
§11.4 claims as open. It does not do PBPK, GPU ensembles, or functional identifiability —
but "SciML vs PopPK vs ML on drug-concentration prediction" is now a published comparison,
and a reviewer will know it. Our baseline set in [07 §7.3](07-validation-protocol.md)
should be checked against theirs.

### (c) Elmokadem et al., Clinical and Translational Science 2024 **[V] — READ**

*Hierarchical deep compartment modeling: a workflow to leverage machine learning and
Bayesian inference for hierarchical pharmacometric modeling*, doi:10.1111/cts.70045
(PubMed 39402751). Elmokadem, Wiens, Knab, Utsey, Callisto, Kirouac — Metrum Research Group.

Three reasons this matters more than its absence from §11.2 suggests:

1. **It is implemented in Julia**, and it is *hierarchical* — population structure included.
2. **It is by the same author as the BayesPBPK tutorial** that §11.1(4) dismisses as "a
   tutorial, not a package". That dismissal is still correct about the 2023 tutorial, but
   the group has since published a Julia ML + Bayesian pharmacometrics workflow. The
   sentence "no package occupies this space" now needs to be said more carefully.
3. It uses **Bayesian priors as regularisation on the network**, which is a direct
   alternative to our declarative constraint layer — and one a reviewer may prefer.

**The gap claim survives**, because HDCM puts the network on the covariate → parameter map
(it is a hierarchical **B4**, not a UDE), has no PBPK transport network, and has no GPU
ensemble path. But §11.1(4) must be rewritten to state that explicitly instead of implying
nothing exists.

**Consequence: B4 is promoted from optional comparison to mandatory baseline.** §11.2
already recommended adding it; with a *hierarchical* Julia implementation now published,
the "why not just put the network on the covariate map?" question is no longer
hypothetical, and [09 §T.2](09-implementation-roadmap.md) currently lists B4 as a cut.
That cut is no longer safe.

### (d) *Open source differentiable ODE solving infrastructure*, arXiv:2411.19882 **[V]**

GPU-accelerated, **fully differentiable** ODE solvers integrated into DeepChem, explicitly
**benchmarked on pharmacokinetic compartment models**.

This does not take our niche — it is Python/DeepChem, single-model rather than population
ensemble, and has no NLME hierarchy — but it does mean "differentiable GPU ODE solving,
demonstrated on PK" is published prior art. **Sharpen claim (ii) of §11.4**: the
contribution is not "GPU + differentiable + PK", it is *the population-ensemble layout and
the mixed forward/adjoint gradient policy over N individuals*. State the narrower claim.

### (e) *Sharpness-aware hybrid model learning for architecture-agnostic parameter
estimation*, arXiv:2602.06837 **[U]**

Surfaced next to the hybrid-neural-ODE identifiability literature; not verified beyond its
existence. Potentially relevant to [06](06-identifiability.md) as an optimisation-side
approach to the same degeneracy problem. **Verify before citing.**

Also noted, not yet assessed: *Machine-learning-enabled modeling of pharmacokinetics and
pharmacodynamics*, Drug Discovery Today 2026 (ScienceDirect S1359644626000504) **[U]** —
a review, potentially useful as a framing citation alongside Losada et al. 2024.

> **中文讲解｜CN**
> **本次复核最重要的发现是：第一次扫描偏向 arXiv，漏掉了药代期刊这条线。**
>
> 漏掉的五篇里有三篇比 §11.2 已列的多数论文更接近本项目：
>
> - **Valderrama 2024** 的杂交点和我们**完全一样**（网络放在 ODE 右端项内部，
>   同时估计其余机理参数），只是单房室、无群体层级、无可辨识性分析。
>   §11.4 说"PK ODE 里的神经闭合已存在（DeepPumas/DeepNLME）"——这句没错，
>   但**举的先例不对**，最近的先例是这一篇，而它目前在整个计划里一次都没被引用。
>   它做的"外推到新剂量方案 / 新病人"还和我们 [07](07-validation-protocol.md) 的留出验证撞了。
>
> - **Valderrama 2025** 是上一篇的群体版，且已经发表了
>   "SciML vs 群体PK vs 传统ML"的对比。这占了 §11.4 声称开放的一部分地盘。
>
> - **Elmokadem 2024（HDCM）** 最需要注意：**用 Julia 写的、带群体层级的 ML+贝叶斯药代工作流**，
>   而且作者就是 §11.1(4) 里被我们判为"只是教程"的 BayesPBPK 那位。
>   对 2023 教程的判断没错，但"这个位置是空的"这句话现在必须说得更小心。
>   它还用**贝叶斯先验来正则化网络**——这是我们声明式约束层的直接替代方案，审稿人可能更偏好它。
>
> **空白仍然成立**（HDCM 是把网络放在"协变量→参数"上，属于 B4，不是 UDE；
> 没有 PBPK 输运网络；没有 GPU 路径），**但必须把这句话明确写出来，而不是暗示"什么都没有"。**
>
> **由此产生一条计划变更：B4 从"可选对比"升为"必做基线"。**
> [09 §T.2](09-implementation-roadmap.md) 现在把 B4 列在单人轨道的删减项里——
> 既然已经有了**带群体层级的 Julia 实现**，"为什么不干脆把网络放在协变量映射上"
> 就不再是假设性问题，这一刀不能砍了。
>
> 另外 arXiv:2411.19882 提醒我们把 §11.4 的第 (ii) 条**收窄**：
> 贡献不是"GPU + 可微 + PK"（这已经有了），而是
> **N 个个体的 ensemble 布局 + 前向/伴随混合梯度策略**。说小一点，反而站得更稳。

## 11.6.3 Problems in the plan that are not about literature

Found while implementing [`src/physiology/reference.jl`](../../../src/physiology/reference.jl)
and re-reading the schedule.

### (a) The physiology verification task is not in the schedule — **blocking**

[02 §2.7](02-pbpk-forward-model.md) states that its reference table is order-of-magnitude
only and **must** be checked against ICRP Publication 89 and Brown et al. (1997) before
use. The implemented `ReferenceIndividual` records that non-verification honestly in every
`source` field.

But [09 §T.3](09-implementation-roadmap.md) has no slot for doing the verification. Month
0–1 says "`physiology/` and `topology.jl`", which reads as a coding task. **Every numerical
result in the project rests on that table**, so this is a genuine gate, not a chore: if the
volumes or flow fractions change after Phase 0, every test tolerance and every figure is
invalidated.

Scheduled below as an explicit Phase −0.5 item.

### (b) Test D has no decision rule — **methodological hole**

§11.1(1) defines Test D as: fit the UDE and an unconstrained neural ODE to the same twin
data, and *"if their fits and their held-out-dose predictions coincide"*, the mechanistic
skeleton contributes nothing.

**"Coincide" is not operational.** Two fits never coincide exactly, so as written the test
can never fail, which makes it decorative. Before Phase 1 it needs:

- a **statistic** (e.g. difference in held-out-dose predictive log-likelihood, or a
  distributional distance between the two predicted concentration–time curves);
- a **threshold**, justified in advance rather than after seeing the result;
- a **direction of failure** — what specifically is done to the closure when the test fails
  (§11.1 says "further constrained", which needs to name which constraint is tightened
  first).

This matters more than the usual "define your metric" complaint, because Test D is one of
the two items [09 §T.4](09-implementation-roadmap.md) says cannot be a stub at submission.
A test with no failure condition is a stub with extra steps.

### (c) The six-month rule is real, and slightly stricter than the plan assumes

Checked against the JOSS submission documentation on 2026-08-07: the six-month public
period in [13 §13.2](13-publication-strategy.md) is **a genuine JOSS requirement, not this
project's own conservatism**. Two details sharpen it:

1. The wording is *"public for **more than** six months prior to submission"*. The
   roadmap's "earliest 2027-02-06" is exactly six months from 2026-08-06, i.e. the
   boundary itself. **Do not submit on that date** — leave a margin.
2. The requirement is not merely elapsed time. JOSS also asks for *"active development
   spanning that period"* and *"iterative development over time"*, and states that
   repositories where *"all significant work was added in a concentrated window"* will be
   rejected. **This is the external justification for the weekly-commit rule in §T.3**,
   which until now was stated as good practice without a source.

Also confirmed in the same pass, and worth recording because it bears on §T.4: JOSS sets
no minimum lines of code, but excludes minor utilities and single-function packages, and
looks for *"clear research impact"* evidenced by published papers, external adopters or
integrations. The NoLimits.jl interoperability path of §11.1(3) is therefore not only good
ecosystem citizenship — it is evidence against the "thin wrapper" rejection.

> **中文讲解｜CN**
> 这三条不是文献问题，是计划本身的问题。
>
> **(a) 最要紧**：整个项目所有数值结果都建立在 §2.7 那张生理参数表上，
> 而文档自己写了"用之前必须核对 ICRP 89 / Brown 1997"——但**排期表里没有这项任务**。
> 已实现的 `ReferenceIndividual` 老老实实在每个 `source` 字段写明"未核对"。
> 如果拖到 Phase 0 之后才核对，数值一变，所有测试容差和图全部作废。所以它是**闸门**，不是杂务。
>
> **(b) Test D 没有判定规则**：原文说"如果两者的拟合和留出预测**一致**"就判定机理骨架无贡献。
> 但"一致"不可操作——两个拟合永远不会精确一致，所以这条检验**永远不会失败**，等于摆设。
> 需要补三样：统计量、**事先**定好的阈值、以及失败后具体先收紧哪一条约束。
> 这一条不能含糊，因为 §T.4 明说 Test D 是投稿时不能是空壳的两项之一——
> **没有失败条件的检验就是加了工序的空壳。**
>
> **(c) 六个月是 JOSS 的真实硬性要求**（2026-08-07 核对官方投稿说明确认），不是本项目自己加的保守规则。
> 但有两处比计划里写的更严：
> 一是原文是"公开**超过**六个月"，而 2027-02-06 正好是六个月**当天**，是边界本身，**不要卡着这天投**；
> 二是它同时要求"这段期间有持续开发"，并明言**"所有实质工作集中在一小段时间内完成"的仓库会被拒**——
> 这正是 §T.3 那条"每周至少一次提交"的**外部依据**，此前它只是被当作良好习惯来写，没有出处。

## 11.6.4 Amended checklist

Supersedes the corresponding lines of §11.5.

- [ ] **Phase −0.5 (blocking, before Phase 0):** verify every value in
      `physiology/reference.jl` against ICRP 89 and Brown et al. (1997); replace each
      `source` string with a real table/page reference; record which source was preferred
      where the two disagree.
- [ ] **Un-cut baseline B4** in [09 §T.2](09-implementation-roadmap.md) — it is now a
      mandatory comparison, and cite Janssen 2022 **and** Elmokadem 2024 for it.
- [ ] **Give Test D a statistic, a pre-registered threshold, and a named failure response**
      before Phase 1 begins.
- [ ] **Rewrite §11.1(4)** to say explicitly what Elmokadem 2024 does and does not cover,
      instead of implying the space is empty.
- [ ] **Narrow §11.4 claim (ii)** from "GPU-parallel population ensembles with gradients"
      to the ensemble layout plus mixed forward/adjoint gradient policy over N individuals,
      citing arXiv:2411.19882 as prior art on differentiable GPU ODE solving for PK.
- [ ] **Cite Valderrama 2024 as the nearest precedent** for a neural closure inside a PK
      ODE, in place of the vaguer DeepPumas/DeepNLME reference in §11.4.
- [ ] Read before writing the methods section — now five, not three: Loman & Baker 2025;
      the AML DeepNLME preprint; Janssen 2022; **Valderrama 2024**; **Elmokadem 2024**.
- [ ] Check [07 §7.3](07-validation-protocol.md) baselines against Valderrama 2025.
- [ ] Verify arXiv:2602.06837 and the Drug Discovery Today 2026 review before citing.
- [ ] Move the earliest-submission date past 2027-02-06 — JOSS requires *more than* six
      months public, and that date is the boundary itself.
- [ ] Next sweep: include CPT:PSP, Clinical and Translational Science, Journal of
      Pharmacokinetics and Pharmacodynamics and Clinical Pharmacokinetics explicitly.
      **Searching arXiv alone missed the closest competitors.**

---

**Next:** [12 — Package Design](12-package-design.md)
