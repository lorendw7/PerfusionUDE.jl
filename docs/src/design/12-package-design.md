# 12 — Package Design: PerfusionUDE.jl

How the research code becomes a package that survives JOSS review.

---

## 12.1 Scope, narrowed

Per [11 §11.1(3)](11-literature-landscape.md), the package occupies four layers and
deliberately does **not** try to be a general NLME framework.

```
┌──────────────────────────────────────────────────────────────┐
│  L4  Analysis      identifiability · recoverability ·        │
│                    symbolic recovery · diagnostics · VPC      │
├──────────────────────────────────────────────────────────────┤
│  L3  Inference     joint-MAP estimator · mixed-mode grads ·  │
│                    GPU population ensemble                    │
│                    ↔ interop: NoLimits.jl / Pumas backends    │
├──────────────────────────────────────────────────────────────┤
│  L2  Closure       constrained neural terms: nonnegativity,  │
│                    R(0)=0, paired ± transfer, residual form   │
├──────────────────────────────────────────────────────────────┤
│  L1  Domain        PBPK transport network · reference        │
│                    physiology · allometry · dosing · nondim   │
└──────────────────────────────────────────────────────────────┘
              built on: OrdinaryDiffEq · DiffEqGPU · Lux ·
                        SciMLSensitivity · ComponentArrays
```

**Explicit non-goals.** No NCA, no bioequivalence, no trial simulation, no GUI, no model
translation from NONMEM control streams, no general NLME estimation engine. Each of those
is served by an existing tool, and each would dilute the JOSS statement of need.

> **中文讲解｜CN**
> **JOSS 评审最看重的不是功能多，而是"边界清晰 + 该做的做到位"。**
>
> 一个做十件事但每件都半成品的包，评审结论是 major revisions；
> 一个只做四层但每层都有文档、测试、示例的包，直接 accept。
>
> 所以"非目标"清单和"目标"清单一样重要，而且要**写进 README 和 paper.md**。
> 明确说"NCA 请用 X，通用 NLME 请用 NoLimits.jl/Pumas，PBPK 建模 GUI 请用 PK-Sim"，
> 这不会显得能力不足，反而显得专业、诚实、生态友好。

---

## 12.2 Module layout

```
src/
├─ PerfusionUDE.jl            # module, exports, includes
├─ physiology/
│  ├─ reference.jl            # ReferenceIndividual, sourced values + provenance
│  ├─ allometry.jl            # BW/BSA scaling, covariate → parameter maps
│  └─ populations.jl          # virtual population sampling
├─ model/
│  ├─ topology.jl             # PBPKTopology: the directed graph + continuity checks
│  ├─ rhs.jl                  # mechanistic RHS (StaticArrays, allocation-free)
│  ├─ nondim.jl               # nondimensionalization / redimensionalization
│  ├─ dosing.jl               # IV bolus / infusion / oral; callbacks
│  └─ observables.jl          # h(u), plasma vs blood, R_b handling
├─ closure/
│  ├─ constraints.jl          # softplus, ×C factor, residual form, paired ± transfer
│  ├─ inputs.jl               # closure_input — THE single definition of z
│  └─ networks.jl             # Lux model constructors, initialization
├─ ensemble/
│  ├─ layout_b.jl             # batched CuArray RHS (default)
│  ├─ layout_a.jl             # EnsembleGPUKernel path (forward, optional)
│  └─ batching.jl             # H matrix packing, stiffness-sorted ordering
├─ inference/
│  ├─ objective.jl            # misfit + Ω⁻¹ penalty + R(φ); BLQ / M3
│  ├─ gradients.jl            # sensealg dispatch; mixed forward/adjoint
│  ├─ schedule.jl             # Stage 0–4 optimization schedule
│  └─ backends.jl             # NoLimits.jl / Pumas interop (package extensions)
└─ analysis/
   ├─ support.jl              # empirical support density ρ(z)
   ├─ identifiability.jl      # profile likelihood, FIM, shrinkage, ablation, Test D
   ├─ symbolic.jl             # symbolic recovery + refit verification
   └─ diagnostics.jl          # VPC, pcVPC, residuals, conservation checks
```

Optional heavy dependencies (`CUDA`, `SymbolicRegression`, `StructuralIdentifiability`,
`NoLimits`) go behind **package extensions** (`ext/`), so the base package installs and
tests on a CPU-only machine. **A JOSS reviewer will not have a GPU.** This single decision
determines whether your review goes smoothly.

> **中文讲解｜CN**
> **最后一段是本文档最重要的工程决定：JOSS 评审员多半没有 GPU。**
>
> 如果你的包 `using PerfusionUDE` 就要求 CUDA、装不上就报错，评审会立刻卡住，
> 而且这是"功能无法验证"，属于必须修的问题。
>
> 正确做法：用 Julia 的 **package extensions**（`ext/` + `Project.toml` 的 `[weakdeps]`），
> 让 `CUDA`、`SymbolicRegression`、`StructuralIdentifiability`、`NoLimits` 都是可选依赖。
> 基础包在纯 CPU 机器上能装、能跑、能过全部测试；
> 装了 CUDA 之后 GPU 路径自动启用。
>
> 附带好处：这也让 CI 变简单（GitHub Actions 免费 runner 没有 GPU），
> 而 **CI 绿灯是 JOSS 评审的硬性检查项**。

---

## 12.3 Public API sketch

Signatures only — you write the implementations.

```julia
# ─── L1 Domain ────────────────────────────────────────────────────────────
ReferenceIndividual(:human_adult_male)          # sourced, with provenance strings
PBPKTopology(:full13) / PBPKTopology(:minimal5) # named topologies
PBPKModel(topology, reference; nondim = true)
VirtualPopulation(n; covariate_distributions...)
DosingRegimen(:iv_bolus; dose, time)

simulate(model, individual, regimen; saveat)    -> solution

# ─── L2 Closure ───────────────────────────────────────────────────────────
NeuralClosure(target = :hepatic_clearance;
              inputs      = (:log_Cu_liver,),
              constraints = (:nonnegative, :zero_at_origin, :residual),
              arch        = (16, 16))
attach(model, closure)                          -> UDEModel

# ─── L3 Inference ─────────────────────────────────────────────────────────
PopulationData(observations; loq, error_model)
JointMAP(; sensealg, precision, schedule)       # the built-in estimator
fit(udemodel, data, JointMAP())                 -> PerfusionFit
fit(udemodel, data, NoLimitsBackend(...))       # via extension

# ─── L4 Analysis ──────────────────────────────────────────────────────────
support_density(fit)                            -> ρ(z)
profile_likelihood(fit, :CL; grid)
fisher_information(fit); shrinkage(fit)
ablation_test(fit)                              # φ = 0 vs φ free
mechanistic_content_test(fit)                   # Test D — vs unconstrained neural ODE
recover_symbolic(fit; verify_by_refit = true)
vpc(fit; n = 1000, prediction_corrected = true)
recoverability_curve(spec; N, n_obs, σ)         # the phase-diagram driver
```

Two API-level invariants, enforced by tests:

1. `closure_input` is the *only* definition of $\mathbf{z}$ — analysis, plotting, and the
   RHS all call it ([09](09-implementation-roadmap.md)).
2. Every paired $\pm$ transfer is computed once and applied twice with opposite sign.

> **中文讲解｜CN**
> API 设计上有一个值得注意的取舍：**`NeuralClosure` 用关键字声明约束
> （`:nonnegative, :zero_at_origin, :residual`），而不是让用户自己写变换。**
>
> 理由：[03 §3.2](03-ude-formulation.md) 里那三个约束因子是**物理正确性的保证**，
> 不应该依赖用户记得写。把它们做成声明式选项，既保证默认安全，
> 又让"施加了哪些约束"变成可以打印、可以写进论文方法学、可以被测试断言的元数据。
>
> `recoverability_curve` 是**整个包最有卖点的一个函数**：
> 它把 [07 §7.4](07-validation-protocol.md) 的相图研究变成一次函数调用。
> 别人要在自己的药物/模型上问"我的数据够不够学回这个机制"，
> 直接调它就行——**这是"可被广泛采用"的具体体现，写 statement of need 时要突出。**

---

## 12.4 Test strategy (JOSS reviewers check this first)

| Tier | What | Runs where |
|---|---|---|
| Unit | Flow continuity $\sum q_i = 1$; topology well-formedness; nondim round-trip; allometric scaling; BLQ likelihood at the LOQ boundary | CPU, CI, seconds |
| Physics | Mass conservation with elimination off; steady state $C^{ss}=R_0/\mathrm{CL}$; nonnegativity; closure constraints ($R(0)=0$, $R\ge0$, paired transfer sums to zero) | CPU, CI, seconds |
| Gradient | **Finite-difference check** vs AD, $N=4$, Float64 | CPU, CI, ~1 min |
| Numerical | Float32-vs-Float64 agreement on a 50-individual sample | CPU + GPU, CI(CPU) / manual(GPU) |
| Statistical | Recovery of known parameters on a tiny twin dataset, fixed seed, generous tolerance | CPU, CI, minutes |
| Regression | Golden-file comparison of a reference trajectory | CPU, CI |
| GPU | Layout A/B agreement with CPU | GPU runner or manual, documented |

The physics tier is the distinctive one, and worth calling out in the JOSS paper: **the
test suite asserts conservation laws, not just numerical outputs.** That is an unusual and
persuasive thing for a reviewer to see.

> **中文讲解｜CN**
> **"physics tier" 是这个测试策略的亮点，建议在 JOSS 论文里专门提一句。**
>
> 常规软件测试断言的是"输出等于期望值"；
> 这里断言的是"**守恒律成立**""**闭合项在零浓度处为零**""**成对传递项加和为零**"——
> 也就是把物理约束写成了可执行的检验。
>
> 评审员看到这个会有明显的正面印象：它说明作者理解自己在算什么，
> 而不是只会跑通流程。而且这类测试在重构时的保护力远强于普通的数值回归测试。
>
> 另外注意最后一行：**GPU 测试不能是 CI 的必过项**（免费 runner 没 GPU）。
> 正确做法是标记为可选/手动，并在 CONTRIBUTING.md 里写清楚如何在有 GPU 的机器上运行。
> 不要因为 GPU 测试跑不了就让 CI 变红——**CI 红灯在 JOSS 评审里是明确的减分项。**

---

## 12.5 Documentation (Documenter.jl)

The research documents you already have become the package's design documentation:

```
docs/src/
├─ index.md                  # landing: what it is, install, 10-line example
├─ tutorials/
│  ├─ 01-first-pbpk.md       # simulate one individual
│  ├─ 02-virtual-population.md
│  ├─ 03-fit-a-closure.md    # the flagship tutorial
│  └─ 04-gpu-scaling.md
├─ howto/
│  ├─ custom-topology.md
│  ├─ identifiability-workflow.md
│  └─ interop-nolimits.md
├─ design/                   # ← the 00–13 documents, verbatim
└─ api.md                    # autogenerated docstrings
```

This mapping is deliberate: it follows the Diátaxis split (tutorials / how-to / explanation
/ reference), and the `design/` explanation layer is far deeper than typical JOSS
submissions. Use that.

**Required by JOSS review:** statement of need in the README, installation instructions,
worked example usage, API documentation, and community guidelines (contributing, issue
reporting, support).

> **中文讲解｜CN**
> 把已经写好的 00–13 号研究文档直接作为包的 `design/` 解释层，是一箭双雕：
> 研究计划文档 = 软件设计文档，两边都不浪费。
>
> 结构上遵循 **Diátaxis 四分法**（教程 / 操作指南 / 解释 / 参考），
> 这是文档界公认的组织方式，评审员一眼能看出来。
>
> 其中 `tutorials/03-fit-a-closure.md` 是**旗舰教程**——
> 评审员多半只会认真跑这一个。它必须：
> - 能在**纯 CPU、几分钟内**跑完（不要求 GPU！）；
> - 从头到尾可复现（固定随机种子）；
> - 最后画出"学到的闭合项 vs 真实闭合项 + 支撑密度"那张图。
>
> **这张图跑出来的那一刻，评审员就理解了整个包的价值。** 优先把它做好。

---

## 12.6 Repository checklist (JOSS)

Requirements confirmed from the JOSS documentation during the 2026-08-06 sweep:

- [ ] **OSI-approved license as an actual `LICENSE` file** (not just a README mention)
- [ ] Public repository, browsable and clonable without registration
- [ ] Public issue tracker
- [ ] **Repository public for more than six months before submission, with active
      development spanning that period** ⚠️ see [13](13-publication-strategy.md)
- [ ] README with high-level overview + statement of need
- [ ] Installation instructions with automated dependency management (`Project.toml`)
- [ ] Example usage demonstrating real functionality
- [ ] API documentation
- [ ] Community guidelines: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, support channel
- [ ] Automated tests + continuous integration
- [ ] Evidence of iterative improvement (commit history, releases, code review)
- [ ] Archived release with a DOI (Zenodo) at acceptance
- [ ] `paper/paper.md` + `paper/paper.bib`
- [ ] **AI usage disclosure** in the paper

Two JOSS scope notes worth knowing: **pre-trained ML models and notebooks are explicitly
out of scope**, and purely financial or organizational contributions do not merit
authorship.

> **中文讲解｜CN**
> ⚠️ **加粗那条是全项目最紧迫的时间约束：仓库必须公开满 6 个月、且这期间有持续开发活动。**
>
> 这条不是形式主义——JOSS 明确说了是为了排除"临时拼凑一个仓库来发论文"的情况，
> 评审时会看 commit 历史。所以：
>
> > **今天就把仓库设为 public，然后保持规律提交。**
>
> 哪怕现在只有文档没有代码，也应该先公开。文档提交同样算开发活动，
> 而且能证明项目是逐步演进的。**这是本次对话之后你应该做的第一件事。**
>
> 另外注意"AI usage disclosure"：JOSS 现在要求明确声明是否使用了生成式 AI。
> 本项目的文档由 Claude 协助起草，**这必须如实写进 paper.md**，
> 不写是学术不端，写了完全不影响录用。具体措辞见 [13 §13.5](13-publication-strategy.md)。

---

## 12.7 Naming and metadata

- Package name `PerfusionUDE.jl` — descriptive, unregistered as far as the sweep found,
  and signals both the domain (perfusion network) and the method (UDE). Keep it.
- Register in the Julia General registry **before** JOSS submission; JOSS reviewers check
  installability.
- `CITATION.cff` in the repo root; update it with the JOSS DOI after acceptance.
- Semantic versioning; tag `v0.1.0` early and release regularly. A repo with a single
  `v1.0.0` tag on submission day reads badly.

---

**Next:** [13 — Publication Strategy](13-publication-strategy.md)
