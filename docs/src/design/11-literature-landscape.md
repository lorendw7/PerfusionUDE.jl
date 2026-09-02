# 11 — Literature Landscape & Repositioning

Results of the literature sweeps conducted **2026-08-06** (§11.1–§11.5), **2026-08-07**
(§11.6) and **2026-09-02** (§11.7), and the consequent revisions to the research plan.
**Read this before [01 §1.6](01-background.md) — it supersedes the positioning written
there.**

**Later sweeps amend earlier ones. Where they disagree, the later sweep wins:
§11.7 > §11.6 > §11.1–§11.5.**

Citation status is marked explicitly:
**[V]** = confirmed against a primary source that was opened ·
**[S]** = title/authors/venue consistent across independent search results, **landing page
not opened — re-check before it enters a manuscript** ·
**[U]** = pointer only, **you must verify before citing**.

`[S]` was introduced by the third sweep, which ran from a network that allowed a search
index but blocked the publisher and preprint sites themselves — see §11.7.0. Nothing that
was `[V]` before was downgraded; `[S]` exists so that weaker evidence is not recorded as
if it were stronger.

**A `[U]` entry carries an identifier and a one-line description only — never a guessed
title.** §11.7.1 explains what happened the one time this rule was broken.

> **中文讲解｜CN**
> 本文档是三次文献扫描（2026-08-06 / 08-07 / 09-02）的结果，以及由此对研究计划的修正。
> **它取代 [01 §1.6](01-background.md) 里的定位段落。**
> **后一次扫描覆盖前一次：§11.7 > §11.6 > §11.1–§11.5。**
>
> 每条文献都标了状态：
> **[V]** = 打开了原始来源核实过；
> **[S]** = 多组检索结果的元数据一致，但**没有真的打开页面**，进稿前必须重查；
> **[U]** = 只是检索线索。
>
> `[S]` 是第三次扫描新增的：那次检索所在的网络只能用搜索索引，打不开 arXiv 和出版商页面
> （见 §11.7.0）。**没有任何原先的 `[V]` 被降级**——新增这一档是为了
> **不把弱证据记成强证据**。
>
> 还有一条硬规矩：**`[U]` 条目只写标识符和一句话描述，不许写猜的标题。**
> §11.7.1 记录了违反这条规矩的后果。

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

> **Amended by §11.6.2(c) and §11.7.4.** §11.6.2(c) requires this list to say what
> Elmokadem 2024 (hierarchical deep compartment modelling, in Julia) does and does not
> cover, rather than implying the space is empty. §11.7.4 adds **`NeoPKPD`**, registered
> since this section was written, and re-establishes the claim by **enumerating the
> General registry** rather than by failing to find things — a stronger form of the same
> argument. **The claim survives; the evidence and the wording changed.**

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
| *Dynamic Graph Neural Networks for Physiological Based Pharmacokinetic Modeling: A Novel Data Driven Approach to Drug Concentration Prediction*, arXiv:2510.22096 **[S]** — title corrected in §11.7.1 | GNN over the compartment graph, largely data-driven | We keep the ODE and conserve mass; they learn the dynamics |
| *PBPK-iPINNs: Inverse PINNs for PBPK Brain Models*, arXiv:2509.12666 **[S]** (§11.7.2) | PINN-based inverse parameter estimation | Single-subject; no population hierarchy, no ensemble |
| *PINNs for Chemotherapy PK: ... Exposing Parameter Identifiability*, arXiv:2606.12658 **[S]** (§11.7.2) | PINN + identifiability | **Their PINN only matches nonlinear least squares on the identifiable problem** — see §11.7.2 |
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

> **Both (ii) and (iii) have since been narrowed — do not quote the paragraph above
> unamended.** §11.6.2(d) narrows (ii) from "GPU + differentiable + PK" to *the
> population-ensemble layout and the mixed forward/adjoint gradient policy over $N$
> individuals*, citing arXiv:2411.19882 as prior art. §11.7.3(a) narrows (iii) from
> identifiability-aware hybrid modelling in general to *the mechanistic-content test under
> a population hierarchy*, because iNODE (arXiv:2608.13044, August 2026) now does
> Fisher-information-based, identifiability-aware architecture selection for neural ODEs.
> The prior art to name also changes: **Valderrama 2024** is the nearest published
> neural-closure-inside-a-PK-ODE precedent (§11.6.2(a)), not DeepPumas/DeepNLME.

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

### (e) arXiv:2602.06837 **[U] — title was wrong, corrected in §11.7.1**

Surfaced next to the hybrid-neural-ODE identifiability literature; not verified beyond its
existence. Potentially relevant to [06](06-identifiability.md) as an optimisation-side
approach to the same degeneracy problem. **Verify before citing.**

> **Superseded by §11.7.1.** This entry was recorded under an invented title,
> *"Sharpness-aware hybrid model learning for architecture-agnostic parameter estimation"*.
> The paper is ***Learning Deep Hybrid Models with Sharpness-Aware Minimization***, by
> Naoya Takeishi **[S]**, and it is an **optimisation** paper, not an identifiability
> paper. Use it as an optimisation-side mitigation for R10.

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

> **Incomplete — see §11.7.5.** Everything below is correct, but it reads the six-month
> requirement as *scope prose*. Since **2026-03-15** it has been **gate 1 of four
> pre-review gates**, any one of which is a desk rejection, and the other three were not
> recorded here at all. One of them — *demonstrated research impact* — displaces the
> six-month clock as the binding constraint on this project.

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

# 11.7 Third sweep — 2026-09-02

Twenty-seven days after the repository went public and **seventeen days after the last
commit**. The sweep was triggered by that gap, not by the calendar: §T.3 requires a commit
every week, and the reason it does turns out to have hardened since it was written (§11.7.5).

**§11.7 amends §11.1–§11.6. Where they disagree, §11.7 wins.**

## 11.7.0 Method, and the limits of this sweep

Read this before trusting anything below.

This sweep was run from a network that permits a **search index** but blocks direct
retrieval of `arxiv.org`, publisher landing pages and `joss.readthedocs.io`. Titles,
authors and venues below therefore rest on search-index metadata, cross-checked across
independent result sets — **not** on an opened abstract page. That is genuinely weaker
than the first two sweeps, and pretending otherwise would defeat the purpose of the
markers. So a third one is introduced:

**[V]** = confirmed against a primary source that was actually opened ·
**[S]** = title/authors/venue consistent across independent search results, **landing page
not opened — re-check before it appears in a manuscript** ·
**[U]** = pointer only.

Two classes of finding in this sweep *are* **[V]**, because their primary sources are git
repositories and those were cloned and read directly:

- the JOSS requirements of §11.7.5, from `openjournals/joss` at commit `4966962`
  (2026-08-26), including the commit that introduced each rule;
- the Julia ecosystem facts of §11.7.4 and §11.7.6, from the General registry
  (`JuliaRegistries/General`, cloned 2026-09-02) and from upstream release tags.

> **中文讲解｜CN**
> **这一小节比后面的内容更重要，因为它决定了后面的内容能信到什么程度。**
>
> 本次检索所在的网络**能用搜索索引，但打不开 arxiv.org、出版商页面和 joss.readthedocs.io**。
> 也就是说：下面这些论文的标题/作者/出处来自搜索结果的元数据（且做了多组交叉验证），
> **但没有真的打开摘要页确认**。这比前两次扫描弱，所以**不能沿用 `[V]`**——
> 否则标记体系就废了。因此新增 **`[S]`**：检索元数据一致，但未开页核实，**进稿前必须重查**。
>
> 反过来，§11.7.4 / §11.7.5 / §11.7.6 里关于 JOSS 规则和 Julia 生态的结论**是真 `[V]`**：
> 它们的原始来源是 git 仓库，而 git 是通的——JOSS 文档仓库和 General 注册表都是**直接 clone 下来读的**，
> 连每条规则是哪个 commit、哪一天加进去的都能查到。
>
> **教训**：当核实手段本身受限时，正确做法是**降级标记并写明限制**，
> 而不是把弱证据说成强证据。前者只是暂时不能引用，后者是学术不端。

---

## 11.7.1 Two citations in §11.6.2 have the wrong title

Both were carried as **[U]**. Both are real papers; both are recorded under a title that
is not theirs, which is worse than a missing citation because it looks verified.

| Where | Recorded as | Actually **[S]** |
|---|---|---|
| §11.6.2(e) | *Sharpness-aware hybrid model learning for architecture-agnostic parameter estimation*, arXiv:2602.06837 | ***Learning Deep Hybrid Models with Sharpness-Aware Minimization***, Naoya Takeishi, arXiv:2602.06837 (cs.LG, stat.ML), Feb 2026 |
| §11.2 | *Dynamic Graph Neural Network for Data-Driven PBPK Modeling*, arXiv:2510.22096 | ***Dynamic Graph Neural Networks for Physiological Based Pharmacokinetic Modeling: A Novel Data Driven Approach to Drug Concentration Prediction***, arXiv:2510.22096 |

Takeishi's paper is **not** an identifiability paper. It is an optimisation paper: hybrid
models combining an ML component with a scientific model, trained with sharpness-aware
minimisation so that the fit lands in a flat basin rather than a sharp one. §11.6.2(e)
guessed "potentially relevant to [06](06-identifiability.md) as an optimisation-side
approach to the same degeneracy problem" — that guess was right, but for the wrong stated
reason. Keep it in §06 as an **optimisation-side mitigation for R10**, not as an
identifiability diagnostic.

> **中文讲解｜CN**
> **标题记错比漏引更危险**，因为它伪装成已核实。这两条都是从检索线索直接抄进文档的，
> 而 §11.6 明明把它们标成了 `[U]`——问题在于 `[U]` 的条目仍然带着一个**看起来像真的标题**。
>
> 以后的规矩：**`[U]` 条目只写标识符（arXiv 号 / DOI）加一句话描述，不要写猜的标题。**
>
> Takeishi 那篇的实际内容也和 §11.6 的猜测不同：它是**优化**论文（用 sharpness-aware
> minimization 让混合模型落在平坦极小值），不是可辨识性论文。
> 它在 [06](06-identifiability.md) 里的正确位置是 **R10 的优化侧缓解手段**，不是诊断工具。

---

## 11.7.2 Status upgrades

| Entry | Was | Now | Detail |
|---|---|---|---|
| arXiv:2509.12666 | **[U]** | **[S]** | *PBPK-iPINNs: Inverse Physics-Informed Neural Networks for Physiologically Based Pharmacokinetic Brain Models* — Wickramasinghe, Weerasinghe, Ranaweera, Hapuhinna. Permeability-limited **four-compartment brain** PBPK; estimates drug- or patient-specific parameters. Confirms the §11.2 reading: single-subject, no population layer. |
| arXiv:2606.12658 | **[U]** | **[S]** | *Physics-Informed Neural Networks for Chemotherapy Pharmacokinetics: Benchmarking the Clinical Estimator and Exposing Parameter Identifiability* — Bisht, Agarwal. **Read the result, not just the title:** on the linear two-compartment problem nonlinear least squares is near-optimal and the PINN only matches it; the interesting finding is that the Michaelis–Menten two-compartment model is **non-identifiable from plasma alone**, and the PINN signals this by converging to $k_{12} \to 0$. |
| Drug Discovery Today review | **[U]** | **[S]** | *Machine-learning-enabled modeling of pharmacokinetics and pharmacodynamics*, Drug Discovery Today, 2026-03-17, ScienceDirect S1359644626000504. Usable as a framing citation alongside Losada et al. 2024. |

The Bisht & Agarwal result deserves more than a row in a table. A PINN that reports
non-identifiability by collapsing a rate constant to zero is doing, by accident, what
[06](06-identifiability.md) proposes to do deliberately — and their honest finding that
**the mechanistic-ML method does not beat least squares on the identifiable problem** is
exactly the comparison a reviewer will demand of us. Put a classical estimator in the
baseline set and report it even when it wins.

> **中文讲解｜CN**
> 第二行请读结论而不是标题：**在可辨识的线性二房室问题上，PINN 并没有赢过普通的非线性最小二乘。**
> 真正有价值的发现是：Michaelis–Menten 二房室模型**仅凭血浆数据不可辨识**，
> 而 PINN 会以"$k_{12}$ 收敛到 0"的方式把这件事暴露出来。
>
> 这对我们有两层意义：
> 1. [06](06-identifiability.md) 想**主动**做的诊断，别人**被动**已经观察到了——先例要引；
> 2. **基线里必须放经典估计器，而且输了也要如实报告。**
>    审稿人一定会问"你这套机制学习比最小二乘强在哪"，事先没有这个对比就会很被动。

---

## 11.7.3 New since the second sweep — one of them matters a lot

### (a) iNODE — identifiability-aware neural ODEs, arXiv:2608.13044, August 2026 **[S] — READ FIRST**

*Identifiability-aware neural ordinary differential equations for parsimonious and reliable
dynamic modelling.*

This is the closest thing to contribution (iii) that has appeared since the plan was
written, and it appeared **during the seventeen-day gap in this repository's commit
history**. From the abstract: neural components are embedded as **explicit analytic
functions inside the governing equations**, which enables direct sensitivity analysis,
**Fisher-information-based confidence intervals**, and **identifiability-aware architecture
selection**; candidate architectures are generated **under data-support constraints**,
jointly calibrated, and ranked by predictive accuracy, parsimony and parameter
identifiability. Reported outcome: more compact architectures, reduced parameter
uncertainty, better extrapolation.

Compare that list against [06](06-identifiability.md): empirical support density, Fisher
information, profile likelihood, ablation. **The overlap is substantial and it is not a
coincidence — it is the same problem being solved at the same time.**

What survives, stated precisely rather than defensively:

- iNODE selects an architecture **for one system**; our (ii) is a **phase diagram over
  population size, sampling density and noise** — a characterisation of *when* recovery is
  possible, not a procedure for one dataset.
- iNODE has no **population/NLME hierarchy**, so its Fisher information is over a single
  parameter vector, not over fixed effects with $\eta$-shrinkage.
- iNODE ranks architectures by identifiability; **Test D asks a different question** — not
  "which network is best identified" but "does the mechanistic skeleton contribute
  anything at all". A model can be well-identified and still be a disguised neural ODE.

What does **not** survive: any wording implying that identifiability-aware design of neural
ODEs is unaddressed. §11.4's claim (iii) must be narrowed the way claim (ii) was narrowed
in §11.6.2(d) — the novel object is the **mechanistic-content test under a population
hierarchy**, not identifiability-aware hybrid modelling in general.

**This paper must be read before [06](06-identifiability.md) is implemented.** If its
architecture-ranking procedure is sound, adopting it and citing it is strictly better than
reinventing a weaker version, and it frees effort for the population layer, which is
genuinely ours.

### (b) Uni-PK, JCIM 2026 **[S]**

*Toward Generalizable Data-Driven Pharmacokinetics with Interpretable Neural ODEs*, Cui,
Ji, Guo et al., *Journal of Chemical Information and Modeling* 66(5):2640–2650,
2026-03-09, doi:10.1021/acs.jcim.5c02924.

Neural ODEs embedded in a mechanistically grounded PK structure, driven by **molecular
representations** plus individual covariates, predicting the concentration trajectory
end-to-end; evaluated on rat and human data across routes of administration.

Same hybridization point as ours (network inside the RHS) but the input is **chemical
structure**, and the goal is cross-drug generalisation rather than within-drug mechanism
recovery. It is not a competitor for (ii) or (iii), and it is a useful citation for the
claim that a network inside a PK RHS is now an established construct rather than a novelty.

### (c) Physiologically Informed Deep Learning, arXiv:2602.18472 **[S]**

*A Multi-Scale Framework for Next-Generation PBPK Modeling*, Liu, Qiu, Wang, 2026-02-09.
Three components: foundation **PBPK Transformers** treating PK forecasting as sequence
modelling; **physiologically constrained diffusion models** generating virtual patient
populations under a physics-informed loss; and **Neural Allometry**, a GNN + neural-ODE
hybrid for interspecies extrapolation.

Note the second component: **generating a virtual population under physiological
constraints** is adjacent to our twin-study generator in
[07](07-validation-protocol.md). Different means (a diffusion model against a soft physics
loss, versus sampling a hierarchical model with hard flow-continuity constraints), and
ours is the one that supports a ground-truth recovery experiment — but the comparison will
be raised, so [07](07-validation-protocol.md) should say why a generative virtual
population cannot serve as a twin study.

### (d) Also logged, lower priority **[S]**

| Work | Why it is here |
|---|---|
| *Learning functional components of PDEs from data using neural networks*, arXiv:2602.13174 | Functional recovery of an unknown term in a PDE — the PDE-side sibling of a UDE closure; relevant to [08](08-cfd-correspondence.md) |
| *Integrating Mechanistic and Data-Driven Models for Neurological Disorders through Differentiable Programming*, arXiv:2606.06094 | Another differentiable-programming hybrid; another domain |
| *Leveraging Neural ODEs for Population Pharmacokinetics of Dalbavancin in Sparse Clinical Data*, PMC12192077 | Neural ODE **with** a population layer on **sparse clinical** data — the sparsity regime of our phase diagram, on real data |
| *A machine learning approach to population pharmacokinetic modelling automation*, Communications Medicine, doi:10.1038/s43856-025-01054-8 | Automation of PopPK model building; adjacent, not competing |
| *Improving Population Pharmacokinetic Modelling with Artificial Patients using Generative AI*, Pharmacol Res Perspect 2026, doi:10.1002/prp2.70241 | Same virtual-population theme as (c) |
| *Opportunities for machine learning and AI in PBPK modeling*, PMC12573771 | Review; framing citation for a PBPK audience |

> **中文讲解｜CN**
> **(a) 是本次扫描唯一真正影响计划的发现，请认真读完。**
>
> iNODE 把"可辨识性"直接做进了神经 ODE 的设计流程：神经项写成显式解析函数嵌进方程，
> 于是可以做灵敏度分析、**基于 Fisher 信息的置信区间**、以及**面向可辨识性的架构选择**，
> 候选架构在**数据支撑约束**下生成，再按预测精度、简约性、参数可辨识性排序。
>
> 把这串东西和 [06](06-identifiability.md) 的清单对一下——**重合度非常高**。
> 这不是巧合，是同一个问题在同一时间被不同的人做。
>
> **重要的是怎么反应。** 不要去论证"我们还是不一样"，要精确说清剩下什么：
> 1. iNODE 是**给一个系统选一个架构**；我们 (ii) 是**在群体规模 × 采样密度 × 噪声上画相图**，
>    回答的是"什么条件下能恢复"，不是"这份数据该用哪个网络"；
> 2. iNODE **没有群体/NLME 层级**，它的 Fisher 信息是单个参数向量上的，
>    没有固定效应、没有 $\eta$-shrinkage；
> 3. **Test D 问的是另一个问题**：不是"哪个网络辨识得最好"，而是"机理骨架到底有没有贡献"。
>    一个模型完全可能**辨识得很好，同时是个伪装的神经 ODE**。
>
> 但 §11.4 的第 (iii) 条**必须收窄**，就像 §11.6.2(d) 收窄第 (ii) 条那样：
> 新颖的是**群体层级下的机理含量检验**，不是"可辨识性感知的混合建模"本身。
>
> **还有一个更实际的判断**：如果 iNODE 的架构排序方法是靠谱的，
> **直接采用并引用它，比自己重造一个更弱的版本好得多**，省下的力气应该投到群体层——那才是我们独有的。
> 学术上不吃亏，工程上省半年。
>
> ⚠️ 最后注意一件事：**这篇是在本仓库停更的那十七天里出现的。**
> 快速领域里，停更不只是 JOSS 的合规问题，也是信息滞后的问题。

---

## 11.7.4 Ecosystem re-check — the gap claim survives, with a new neighbour

§11.1(4) itself warns that a claim established "by absence" has a shelf life. It was
re-checked on **2026-09-02 against the General registry directly** (cloned; registry HEAD
2026-09-02), not against a search engine. **[V]**

**Everything matching `pbpk|pharmac|pkpd|nlme|physiolog|popPK|torsten|nonmem|clinical` in
the registry was enumerated.** The pharmacometrics-relevant results:

| Package | Latest registered | Assessment |
|---|---|---|
| `NoLimits` | **0.2.7** | Registered and actively versioned. §11.1(3) stands; the interoperability path of §11.5 is with a live package, not a preprint. |
| **`NeoPKPD`** | **0.1.0** — *new, not in any previous sweep* | See below. |

**`NeoPKPD`** (`shramish2057/NeoPKPD`, MIT, Zenodo DOI 10.5281/zenodo.18215969) is a
Julia + Python PK/PD platform: one/two/three-compartment and TMDD models, NLME estimation
by FOCE-I / SAEM / Laplacian / Bayesian, NCA, trial simulation, VPC, NONMEM and Monolix
model import, CDISC/SDTM data import, 21 CFR Part 11 compliance features.

It was inspected in the clone rather than judged from its README:

- **No PBPK.** The string `pbpk` does not occur anywhere in its sources or docs.
- **No GPU.** No `CUDA`, no `DiffEqGPU` in its dependencies.
- **No neural closure.** No `Lux`, no `Flux`, no `SciMLSensitivity`; AD is `ForwardDiff` /
  `ReverseDiff` / `Enzyme` for estimation, not for learning a term inside the RHS.

**The §11.1(4) gap claim therefore survives, and is now better evidenced than when it was
made** — the enumeration is reproducible and the disqualifying properties are specific
rather than impressionistic. But two things must change:

1. The **README "Not in scope"** pointer and the **§13.2 state-of-the-field paragraph**
   must name `NeoPKPD` alongside NoLimits.jl and Pumas. A JOSS reviewer drawn from the
   Julia pharmacometrics community will know it, and a state-of-the-field paragraph that
   omits a registered Julia NLME package published this year reads as a sweep that was not
   done.
2. R11 in [09](09-implementation-roadmap.md) ("a competing package closes the gap") should
   be re-scored. It did not fire, but the arrival of a broad Julia PK/PD platform within a
   month of going public is evidence that the space is being actively filled.

> **中文讲解｜CN**
> **这次是把 General 注册表整个 clone 下来枚举的，不是搜索"有没有 Julia PBPK 包"。**
> 差别在于：搜索得到的是"我没找到"，枚举得到的是"注册表里符合条件的包是这些，逐个看过"。
> **"由检索不到确立的空白"和"由枚举确立的空白"，在审稿人眼里完全不是一个东西。**
>
> 新出现的 `NeoPKPD` 是个功能很全的 Julia PK/PD 平台（NLME 估计、NCA、试验模拟、
> NONMEM/Monolix 导入、合规功能），但**没有 PBPK、没有 GPU、没有神经闭合**——
> 这三条是在 clone 下来的源码里查的，不是看 README 猜的。所以我们的位置还在。
>
> **但必须主动把它写进 README 的"不在范围内"和 §13.2 的 state-of-the-field 段落。**
> 理由很实际：JOSS 审稿人很可能就是 Julia 药代圈的人，
> **漏掉一个今年刚注册的同生态包，会被判定为"文献工作没做"**，比承认它存在的代价大得多。

---

## 11.7.5 JOSS changed its rules, and the plan is measuring the wrong constraint

Verified **[V]** against `openjournals/joss`, cloned 2026-09-02 at commit `4966962`
(2026-08-26). Because it is a git repository, each rule can be dated by the commit that
introduced it:

| Rule | Introduced | Commit |
|---|---|---|
| AI usage policy (interim) | **2025-09-16** | `a03374a` |
| AI usage policy (current wording) | **2025-12-07** | `3724001` |
| Scope/eligibility rewrite | 2026-01-05 | `a4090f5` |
| **Pre-review screening criteria — four desk-rejection gates** | **2026-03-15** | `57b370c` (Arfon Smith, *"Updating docs to reflect new scope gates for EiCs"*) |
| Further revisions | 2026-06-24, 2026-07-13 | `8d9827c`, `3bdbe7d` |

The 2026-08-07 check in §11.6.3(c) read the six-month sentence correctly but recorded it as
prose about *scope*. It is not prose. Since 2026-03-15 it is **gate 1 of four hard gates**,
and *"a submission that fails any one of these will receive a desk rejection."* The other
three were not recorded at all.

**Gate 1 — Sufficient public development history.** *"The repository must have been public
for more than six months prior to submission, with active development spanning that
period. A repository made public immediately before submission, or one showing development
concentrated into a few days or weeks, will not be accepted. **We run automated checks on
commit distribution — a repo dump is not a history.**"*

That last sentence is new relative to what §11.6.3(c) recorded, and it is not rhetoric —
it describes a mechanical check. This repository's current distribution: nine commits, of
which **six fall on 2026-08-06 and 2026-08-07**, then one on 08-13, one on 08-16, and
nothing since. That is, right now, a two-day burst followed by a thinning tail. It is
early enough to fix by simply continuing; it is exactly what the check is designed to find.

**Gate 2 — Demonstrated research impact. This is the binding constraint, and the plan does
not model it.** *"There **must** be evidence that the software is being used for research —
at minimum by the developers themselves, and ideally by others… **Aspirational statements
about future use are not sufficient; JOSS will not publish papers that are meant to
advertise software that is not yet being used in research.**"* The current wording adds
that adoption in a currently private workflow is acceptable **if demonstrated to the
editorial team**.

[13 §13.4](13-publication-strategy.md) says *"the 6-month rule is the binding constraint on
JOSS. Nothing else you do can compress it."* **That is no longer true.** The six-month
clock expires on 2027-02-06 and runs by itself. Gate 2 does not run by itself: on the
current schedule the package is registered at $T_0 + 6$–7 months and submitted immediately,
with the twin study as its only use — and a twin study run by the author to produce the
software's own paper is the weakest reading of "used for research", certainly not
"published papers, external adopters or integrations".

The fix is a scheduling one, and it is cheap if made now and expensive if made later:
**the arXiv preprint of the method (already in §13.4 at $T_0+1$–2 as a priority-securing
move) is also the Gate 2 evidence**, provided it *uses* the package and *cites* it. That
converts an optional nicety into a submission prerequisite. A Phase-3 phase-diagram result
posted as a preprint that cites `PerfusionUDE.jl` satisfies *"references in published
papers or preprints"* directly.

**Gate 3 — Good open source practices.** For single-author projects, *multiple* indicators
must be present: meaningful commit history over time, tagged releases or a changelog, tests
and CI, clear documentation, a CONTRIBUTING file, stated support or governance
expectations. This project already has changelog, CI, docs, CONTRIBUTING and a maintenance
statement. **Gate 3 is close to satisfied and is the cheapest gate to finish** — the
missing indicator is a tagged release beyond `v0.1.0`, i.e. §T.3's second rule.

**Gate 4 — Iterative development over time.** *"The development history must show ongoing
iteration, not a single burst of commits. We look for evidence that the software has been
refined through use and feedback over time."* Gate 4 is Gate 1 seen from the other side and
it is what §T.3's weekly-commit rule was already protecting.

**On the AI usage policy:** [13 §13.5](13-publication-strategy.md) anticipated this and is
substantially correct, but its suggested wording is missing one required element. The
policy requires *"the tools/models used **(and versions)** and **where** they were used
(code, paper text, docs)"*, the nature and scope of assistance, and an explicit assertion
that human authors reviewed, edited and validated all AI-assisted output **and made the
core design decisions**. The §13.5 draft names the tool but not versions, does not
enumerate where, and does not contain the core-design-decisions assertion. It also warns
that the "all references verified" clause may only be written if true — with this sweep's
**[S]** entries on the books, **it is not currently true**, and §13.5's own warning now has
teeth.

> **中文讲解｜CN**
> **这一节是本次"有效性更新"最重要的产出，因为它推翻了计划里一句被当成定论的话。**
>
> §11.6.3(c) 在 2026-08-07 读到了"公开超过六个月"，但把它当成了**范围说明**。
> 它不是说明。自 **2026-03-15** 起（能查到是哪个 commit、谁提交的），
> 它是**四道硬性初审门槛的第一道**，而原文写明：**任何一道不过，直接拒稿。**
> 另外三道，计划里一条都没有。
>
> **门槛 1** 新增了一句：**"我们对提交分布做自动检查——仓库倾倒不是历史。"**
> 本仓库现在的分布是：9 个提交，其中 **6 个集中在 8 月 6–7 日两天**，
> 然后 8-13 一个、8-16 一个，之后停了。**这正是那个自动检查要抓的形状。**
> 好消息是现在还早，继续正常提交就能修好；坏消息是它事后补不了。
>
> **门槛 2 才是真正卡住我们的那道，而计划完全没有建模它。**
> 原文：**"必须有证据表明软件正在被用于研究……对未来用途的展望不算数；
> JOSS 不发表用于宣传尚未被实际使用的软件的论文。"**
>
> 而 [13 §13.4](13-publication-strategy.md) 写着"六个月是 JOSS 的硬约束，
> 任何努力都压缩不了它"——**这句话现在是错的**。六个月会自己走完（2027-02-06），
> 门槛 2 不会自己走完。按现在的排期，$T_0+6$~7 个月注册完就投，
> 软件唯一的"使用记录"是作者自己为了写这篇软件论文跑的孪生实验——
> 这是"被用于研究"最弱的一种读法。
>
> **解法很便宜，但必须现在改**：§13.4 里那个"Phase 1 之后挂 arXiv 预印本"
> 原本只是"确立优先权的好习惯"，现在它**同时是门槛 2 的证据**——
> 前提是那篇预印本**真的用了这个包并且引用了它**。
> 一篇引用了 `PerfusionUDE.jl` 的相图预印本，直接满足"预印本中的引用"这一条。
> **一件事同时解决两个问题，就把它从"可选"改成"前置条件"。**
>
> **门槛 3（开源实践）我们其实快满足了**——CHANGELOG、CI、文档、CONTRIBUTING、
> 维护声明都有了，缺的是 `v0.1.0` 之后的 tag，也就是 §T.3 的第二条规则。**这是最便宜的一道门。**
>
> **关于 AI 披露**：§13.5 提前想到了这件事，方向是对的，但**建议措辞漏了要素**。
> 政策要求写明"工具/模型**及版本**"、"**用在哪里**（代码/正文/文档）"、
> 协助的性质与范围，以及"人类作者审阅、编辑、验证了所有 AI 产出**并做出了核心设计决策**"。
> 现在的草稿只写了工具名。
>
> 还有一句要认真对待：§13.5 自己写了"'所有引用均已核实'这句只有做到了才能写"。
> **本次扫描新增了一批 `[S]` 条目，所以现在这句话不能写。** 它自己的警告开始生效了。

---

## 11.7.6 Software validity — three findings outside the literature

Checked **[V]** against upstream git tags and the General registry on 2026-09-02.

**(a) Two compat bounds in `Project.toml` exclude the current release of their package.**

| Dependency | Bound | Latest released | Effect |
|---|---|---|---|
| `CUDA` | `"5"` | **6.3.1** | The GPU extension cannot load with a current CUDA.jl |
| `SymbolicRegression` | `"1"` | **2.2.0** | The symbolic-recovery extension cannot load with a current SymbolicRegression.jl |

Both are weak dependencies, so the base package still installs and tests — which is
precisely why this would have gone unnoticed until Phase 2 or Phase 3, i.e. until the
extension was needed. The remaining eleven bounds were checked and are current.

This is [09 R1](09-implementation-roadmap.md) ("Enzyme/CUDA/Lux version incompatibility")
arriving early and from the boring direction: not an AD conflict, just a major-version bump
that a hand-written bound did not follow.

**(b) Every third-party GitHub Action in CI is behind by two or three majors.**

`actions/checkout` v4 → **v7** · `actions/upload-artifact` v4 → **v7** ·
`codecov/codecov-action` v4 → **v7** · `julia-actions/setup-julia` v2 → **v3** ·
`julia-actions/cache` v2 → **v3**. The `julia-actions/julia-buildpkg`,
`julia-runtest` and `julia-processcoverage` actions are still on v1, which is current.

`codecov/codecov-action@v4` has not been touched upstream since **2024-10-01** — three
majors and nearly two years of runner deprecations. `setup-julia@v3` runs on `node24`;
its `version` input is unchanged, and it now accepts `lts`, `pre`, `min-minor` and
`min-patch` in addition to a version string. `codecov-action@v7` still takes `files` and
`token`, so that step needs only a version bump.

`min-minor` / `min-patch` are worth noting against the `v0.1.0` known limitation
*"dependency compat bounds have not been tested against their lower bounds"* — a `min`
entry in the CI matrix tests the declared Julia floor directly.

**(c) The reference against which "current" was judged.** Julia's latest release is
**1.12.7**, with a `release-1.13` branch open upstream. The CI matrix (`1.10` and `1`) is
therefore still correct: `1.10` is the declared floor and `1` tracks the latest stable.

> **中文讲解｜CN**
> **(a) 是本次唯一会真正让代码跑不起来的问题，而且它藏得很好。**
> `CUDA = "5"` 但 CUDA.jl 已经到 6.3.1，`SymbolicRegression = "1"` 但已经到 2.2.0。
> 因为这两个都是 **weak dependency**，基础包照常安装、CI 照常全绿——
> **要等到 Phase 2 上 GPU、Phase 3 做符号回归时才会炸。**
>
> 这就是 [09 R1](09-implementation-roadmap.md) 提前到来，而且是从最无聊的方向来的：
> 不是 AD 冲突，只是**手写的版本上界没跟上大版本升级**。
> 教训：**上界写死在一个主版本上，等于给自己埋了一个延迟半年爆炸的雷。**
> 另外十一条边界都查过了，是当前的。
>
> **(b)** CI 里所有第三方 Action 都落后两到三个大版本，其中 `codecov-action@v4`
> **上游从 2024-10-01 起就没动过**。GitHub runner 会逐步淘汰旧 Node 运行时，
> 这类落后**不是风格问题，是会突然变红的**。
> 顺带一提：`setup-julia@v3` 支持 `min-minor`/`min-patch`，
> 正好对应 `v0.1.0` 里那条"兼容性下界从未测试过"的已知限制——矩阵里加一项就能测。

---

## 11.7.7 Amended checklist

Supersedes the corresponding lines of §11.6.4.

**Blocking, before anything else:**

- [ ] **Resume weekly commits.** Gate 1 and Gate 4 are checked automatically against commit
      distribution, and the current shape is a two-day burst plus a thinning tail.
- [x] Fix the `CUDA` and `SymbolicRegression` compat bounds — done in this pass.
- [x] Bump the CI action majors — done in this pass.

**Before [06](06-identifiability.md) is implemented:**

- [ ] **Read iNODE (arXiv:2608.13044).** The adopt-or-differ decision is now recorded as
      required in [06 §6.7](06-identifiability.md); the reading itself is still to do.
- [x] **Narrow §11.4 claim (iii)** to *the mechanistic-content test under a population
      hierarchy* — done (amendment note under §11.4).
- [x] Move Takeishi (arXiv:2602.06837) into [06 §6.7](06-identifiability.md) as an
      **optimisation-side mitigation for R10**, under its real title — done.
- [x] **Give Test D a statistic, a pre-registered threshold and a named failure
      response** (open since §11.6.3(b)) — done, [06 §6.0](06-identifiability.md):
      $R = 10$ seeds, $2\sigma_{\mathrm{run}}$, in-sample precondition, four-step ordered
      response. Still to do: freeze it in code as `TestDRule` before the first Phase-1 fit.
- [x] Reconcile the [07 §7.3](07-validation-protocol.md) baselines with Valderrama 2025
      and Bisht & Agarwal — done: B2/B3 map onto their PopPK/ML arms; B0 is the classical
      estimator the UDE should approach, not beat, and that expectation is now written down
      before any result exists.
- [x] Add the parameter-at-bound signature (Bisht & Agarwal) as diagnostic (e) in §6.4 —
      recorded in [06 §6.7](06-identifiability.md) and in the [07 §7.6](07-validation-protocol.md) gate.

**Publication strategy:**

- [x] **Re-plan around Gate 2, not the six-month clock** — done: the §T.3 schedule and
      the [13 §13.4](13-publication-strategy.md) timeline now carry the preprint as a
      month-4 milestone that uses and cites the package, and JOSS submission requires both
      the date and the preprint.
- [x] Record the four pre-review gates in [13 §13.2](13-publication-strategy.md) as
      desk-rejection gates rather than scope prose — done in this pass.
- [x] Complete the §13.5 AI disclosure wording: **tool versions**, **where** it was used,
      and the **core-design-decisions** assertion — done in this pass, and mirrored into
      `paper/paper.md`.
- [x] Remove "all references verified" from the disclosure while any **[S]** or **[U]**
      entry remains — done. **Do not restore it until every entry is [V].**
- [ ] Fill in the AI-disclosure `TODO`s in `paper/paper.md`: model versions, and the scope
      of assistance for source code and paper text. Record these **as work happens**.
- [ ] Finish Gate 3: tag `v0.2.0` when the mechanistic model passes its tests.

**Positioning:**

- [x] Name **`NeoPKPD`** in the README "Not in scope" pointer, the §13.2
      state-of-the-field paragraph and `paper/paper.md` — done in this pass.
- [x] Say in [07 §7.2](07-validation-protocol.md) why a generatively synthesised virtual
      population (arXiv:2602.18472) cannot substitute for a ground-truth twin study — done.

**Method:**

- [ ] **Never write a bibliographic field you did not read.** `[U]` entries carry an
      identifier and a one-line description only — never a guessed title. The same applies
      to author fields: where a sweep confirmed surnames, record surnames and mark the
      given names `[U]`. Two wrong titles in §11.6.2 came from breaking the first half of
      this rule; `paper.bib` now marks partial author lists explicitly rather than
      completing them plausibly.
- [ ] Re-verify every **[S]** entry from an opened primary source before it enters a
      manuscript.
- [ ] Next sweep: **establish the ecosystem gap by enumerating the General registry**, not
      by searching. Keep CPT:PSP, Clinical and Translational Science, JPKPD and Clinical
      Pharmacokinetics on the journal list, and add **JCIM** — Uni-PK was published there.

---

**Next:** [12 — Package Design](12-package-design.md)
