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

# Where the project stands, and what to do next — 2026-09-02

This section is rewritten at every validity sweep. It is the only part of the roadmap
that is meant to go stale, and it says so.

## Done

- **Phase −1** — public since 2026-08-06, `v0.1.0`, changelog, `CONTRIBUTING`, CI, docs.
- **Phase −0.5** — every reference-physiology value verified against ICRP 89 (2026-08-16).
- **Three literature sweeps** and a plan reconciled with the JOSS rules as they are, not
  as they were in July ([11 §11.7](11-literature-landscape.md)).
- **Test D has a decision rule** ([06 §6.0](06-identifiability.md)) — the last item
  §T.4 below said could not be a stub.

## Not done

- **No model code exists.** `src/` contains the physiology layer and nothing else. The
  first line of Phase 0 has not been written.
- **The commit cadence broke once** (2026-08-16 → 09-02). JOSS gates 1 and 4 check commit
  distribution automatically.
- **No tagged release beyond `v0.1.0`** — the one gate-3 indicator still missing.
- **No evidence of research use** — gate 2, the binding constraint, and it cannot be
  satisfied by anything in this repository alone.

## Next actions, in order

| When | Do | Why this and not something else |
|---|---|---|
| **This week** | `topology.jl`: the 5-compartment minimal topology with flow continuity asserted at construction, plus its unit test. **One commit.** | Restarts the cadence with real code. Smallest Phase-0 unit that stands alone. |
| Weeks 2–5 | Rest of Phase 0: `StaticArrays` out-of-place RHS, nondimensionalization, the six numerical tests of [02 §2.9](02-pbpk-forward-model.md), stiffness characterization. **Tag `v0.2.0`.** | `v0.2.0` closes gate 3. Everything downstream depends on a forward model that conserves mass. |
| Weeks 6–9 | Closure layer with declarative constraints; twin generator H1. **`TestDRule` frozen in code before any fit is run.** | §T.4 item 1. Pre-registration only counts if it is committed before the results. |
| Weeks 10–16 | Phase 1: joint MAP at $N = 50$, finite-difference gradient check *first*, baselines B0/B1/B3/B4 with $R = 10$ seeds, **Test D**. **Tag `v0.3.0`.** | Decides whether the project works. Nothing GPU until this passes. |
| **Before Phase 1 fitting** | **arXiv preprint v1 — decided 2026-09-02: the structural-identifiability study of [06 §6.2](06-identifiability.md).** Which closure families (single MM, two MM, MM + saturable uptake; the H1/H2 families) are parametrically identifiable from plasma alone on the 5-compartment topology, computed with the `StructuralIdentifiability` extension. No optimisation, no GPU. Must state the package version used and cite its Zenodo DOI. | **This is the gate-2 evidence, and it is on the critical path anyway** (§6.2 says "do this first"). Extends Bisht & Agarwal's MM non-identifiability result to PBPK. Fallback if it stalls: an audit of published PBPK parameter tables with `liver_inflow`. |
| **After Phase 1** | **Preprint v2**: closure-recovery figure, Test D verdict, $N = 50$. | Strengthens gate 2; establishes priority on the UDE result. iNODE appeared during the last gap. |
| Then | Phase 2 (GPU), Phase 3 (sweep) → preprint v2 with the phase diagram. Package registration. | Gate 2 gets stronger; the JOSS paper gets its research-impact section. |
| **After 2027-02-06** *and* preprint public | Submit to JOSS. | Both conditions, not either. |

**Standing rules while doing the above:** commit every week; re-run the sweep and the
compat-bound check before every tag and every submission; log AI-tool versions as they are
used ([13 §13.5](13-publication-strategy.md)); read iNODE before writing §6.4 code
([06 §6.7](06-identifiability.md)).

> **中文讲解｜CN**
> **这一节每次有效性扫描都重写，是路线图里唯一"应该过时"的部分。**
>
> **已完成**：公开、`v0.1.0`、生理参数核对、三次文献扫描、Test D 判定规则。
> **未完成**：**一行模型代码都没有**；提交节奏断过一次；`v0.1.0` 之后没有 tag；
> 没有任何"被用于研究"的证据——而这是 JOSS 现在真正卡人的那道门。
>
> **下一步的顺序不是随便排的：**
> 1. **本周一个提交**：`topology.jl`（5 房室拓扑 + 构造时断言流量连续）。
>    这是 Phase 0 里最小的、能独立成立的单元，用真代码把节奏接上。
> 2. 五周内做完 Phase 0，**打 `v0.2.0`**——这一个 tag 就把门槛 3 关上了。
> 3. 闭合层 + 孪生生成器，**Test D 的规则先冻进代码再跑任何拟合**——事先登记的意思就是提交在结果之前。
> 4. Phase 1 在 CPU、$N=50$ 上把整套方法跑通，**打 `v0.3.0`**。
> 5. **Phase 1 一结束就挂 arXiv 预印本**，用这个包、引这个包。**小结果也行**——
>    它是门槛 2 的证据，不是论文的终稿。上次停更的十七天里冒出了 iNODE，这个领域不等人。
> 6. 之后 GPU、相图、预印本 v2、注册包。
> 7. **2027-02-06 之后 且 预印本已公开**，两个条件都满足才投 JOSS。
>
> 四条常备规则：每周提交；每次打 tag 或投稿前重跑扫描和兼容性边界检查；
> 边用边记 AI 工具版本；写 §6.4 代码前先读 iNODE。

---

# Two tracks

This document describes two versions of the same programme. **Read §T first and pick one
before reading anything else.** The phases further down are the full programme; the solo
track is a strict subset of them.

## §T.1 Which track

| | **Solo track (default)** | **Full programme** |
|---|---|---|
| Assumes | one part-time developer, self-study, no domain co-author | dedicated time, supervision, a pharmacometrics collaborator |
| Target | **JOSS** — a real, well-tested, well-documented package | JOSS **and** PLOS Comp Biol |
| Horizon | ~6–7 months part-time | 15–18 months |
| Model | minimal 5-compartment PBPK | full 13-compartment PBPK |
| Real clinical data | **no** | yes |
| Ends with | a package, the closure-recovery figure, Test D, a small phase diagram, a JOSS paper | all of that plus a validated real-data case study |

**The solo track is not a reduced-ambition version of the science — it is the version whose
bottleneck is engineering, which is where a software engineer has the advantage.** The
scientific claims it can support are narrower and correspondingly easier to defend.

> **中文讲解｜CN**
> **在读下面任何内容之前，先确定你走哪条轨道。**
>
> 完整版是按"有导师、有整块时间、有药代方向合作者"写的。作为一个人的自学侧项目，
> 按完整版走大概率会在中途停掉——不是能力问题，是这类项目的常见结局。
>
> **单人轨道不是"降低科学野心"，而是把瓶颈从领域知识挪到工程实现上**——
> 后者恰好是软件工程背景的优势区。它能支撑的科学主张更窄，但也因此更容易站得住。
>
> 真实临床数据研究需要：数据获取（周期长、可能要签数据使用协议）、
> 会用 nlmixr2/NONMEM 做对比、有药代同行审读。这几项靠个人努力补不上，需要合作者。
> **所以把它留给"如果项目做起来了、并且找到合作者"的将来**，不要让它驱动现在的排期。

## §T.2 What the solo track cuts

Everything below is deferred, not abandoned. Each cut removes a specific, identified risk.

| Full programme | Solo track | Why the cut is safe |
|---|---|---|
| 13-compartment PBPK | **5-compartment minimal PBPK** (blood, liver, kidney, rapidly perfused, slowly perfused) | Already justified as information-driven model reduction in [07 §7.7 R1](07-validation-protocol.md). Cuts the physiology-sourcing burden by ~70% |
| Closure targets A, B, C | **A only** (hepatic clearance) | B and C are extensions; A is the one that carries the argument |
| IV + infusion + oral + multiple dosing | **single IV bolus** (an initial condition) | Avoids GPU callbacks entirely — see [05 §5.6](05-gpu-strategy.md) |
| Ensemble layouts A and B | **Layout B only** | Removes kernel-compatibility and mixed-mode differentiation, the two hardest engineering items |
| Estimation strategies S1–S4 | **S1 joint MAP only** | S2/S3/S4 are statistical upgrades, not prerequisites |
| Baselines B0–B4 | **B0, B1, B3, B4** | B3 is retained because Test D needs it. B2 needs R/nlmixr2. **B4 was cut here until 2026-08-07; it is now mandatory** — see [11 §11.6.2(c)](11-literature-landscape.md), a hierarchical deep compartment model in Julia is published, so "why not put the network on the covariate map instead?" is no longer a hypothetical question |
| Hidden mechanisms H1, H2, H3 | **H1 only** | H1 (two parallel MM terms) already breaks the single-MM model |
| 3-D sweep $(N, n_\mathrm{obs}, \sigma)$ | **2-D sweep** $(N, \sigma)$, sampling density fixed | Runs drop from several hundred to a few dozen |
| Real-data case study | **deferred** | Needs a collaborator |

What survives is still a complete piece of work: a package, the learned-vs-true closure
figure with support density, the mechanistic-content test, a small recoverability phase
diagram, and a JOSS paper.

> **中文讲解｜CN**
> 注意每一条砍的都是**一个已识别的具体风险**，不是随便减量：
> - 砍到 5 房室 → 砍掉大量生理学查证工作（而且 [07 §7.7](07-validation-protocol.md) 已论证这是正当降阶）
> - 只做单次 IV bolus → **完全绕开 GPU callback**，这是 [05 §5.6](05-gpu-strategy.md) 里明确列出的坑
> - 只做布局 B → 砍掉 kernel 兼容性和混合模式微分，两个最难的工程项
> - 只做 S1 → 砍掉 FOCE/VEM/HMC 三套统计方法
>
> **保留 B3（纯黑箱 neural ODE）是刻意的**：Test D 需要它做对照，而 Test D 是
> [06 §6.0](06-identifiability.md) 里的及格线，不能省。

## §T.3 Solo-track schedule

Relative to $T_0$ = the day the repository went public (**2026-08-06**). Assumes part-time.

| Month | Work | Deliverable |
|---|---|---|
| 0–1 | Julia basics; Phase −1 complete; `physiology/` and `topology.jl`; ~~**Phase −0.5 (blocking)**~~ **✅ done 2026-08-16** | reference data structures with provenance ✅; **every reference value verified against ICRP 89** ✅; continuity assertions — `liver_inflow` and `flow_continuity_residual` tested ✅ |
| 1–2 | Phase 0 on the 5-compartment model | six numerical tests green; RHS allocation-free; **tag `v0.2.0`** (closes JOSS gate 3) |
| 2–3 | Closure layer + twin generator (H1); `TestDRule` frozen in code | constrained closure with declarative options |
| 3–4 | Phase 1: joint MAP on CPU, $N=50$; baselines with $R=10$ seeds | **finite-difference gradient check green; Test D passes under the §6.0 rule; tag `v0.3.0`** |
| 3 | **arXiv preprint v1** — structural identifiability of closure families on the 5-compartment topology (decided 2026-09-02); uses and cites the package | **JOSS gate-2 evidence begins**; on the §6.2 critical path |
| 4 | **Preprint v2** — Phase-1 twin study, Test D | gate 2 strengthened; priority on the UDE result |
| 4–5 | Phase 2: GPU Layout B | GPU matches CPU; breakeven $N$ measured |
| 5–6 | 2-D sweep; tutorials; API docs; CHANGELOG | the closure-recovery figure; a small phase diagram; **preprint v2** |
| 6–7 | Register the package; draft `paper.md`; re-verify every **[S]**/**[U]** reference | **JOSS submission — after 2027-02-06 *and* with the preprint public; neither alone suffices** |

The month-4 row is the change from the previous version of this table. The preprint was
an optional priority-securing move; since the JOSS gates of 2026-03-15 it is the evidence
that satisfies gate 2, and it is the only item in this schedule that no amount of work
inside the repository can substitute for. Pull it forward, not back.

Two rules that matter more than the schedule:

1. **Commit at least once a week, every week.** For a single-author submission JOSS looks
   for a meaningful commit history spanning the public period, precisely because there is
   no pull-request record to demonstrate process. This cannot be reconstructed afterwards.

   **This is now known to be mechanically enforced.** JOSS's pre-review gate 1 states:
   *"we run automated checks on commit distribution — a repo dump is not a history"*, and
   gate 4 rejects a history that is *"a single burst of commits"*
   ([13 §13.2](13-publication-strategy.md),
   [11 §11.7.5](11-literature-landscape.md)). The rule is not good practice with a
   plausible rationale; it is a check that runs.

   **Status on 2026-09-02:** nine commits, six of them on 2026-08-06 and 2026-08-07, then
   one on 08-13, one on 08-16, and a **seventeen-day gap**. That is the exact shape the
   check looks for. It is early enough to fix by simply resuming, and it is the reason
   this validity sweep was run at all.
2. **Tag a release whenever something works.** `v0.2.0` when the mechanistic model passes
   its tests, `v0.3.0` when the closure fits, and so on. Tagged releases plus a changelog
   are among the maturity indicators for solo projects — and a tagged release beyond
   `v0.1.0` is **the one indicator gate 3 is still missing**; everything else it asks a
   solo project for is already in the repository.

> **中文讲解｜CN**
> **下面两条比时间表本身重要得多：**
>
> 1. **每周至少一次有意义的提交，一周都不要断。**
>    单作者投稿时，JOSS 会特别看"公开期内是否有跨时间的持续提交历史"——
>    因为独作者没有 PR 记录可以证明开发流程是规范的。
>    **这一项事后无法补救**：攒三个月一次性推上去，历史上看得清清楚楚。
>
>    **2026-09-02 更新：这条现在确认是"机器查"的，不是"惯例"。**
>    JOSS 初审门槛 1 的原话是：**"我们对提交分布做自动检查——仓库倾倒不是历史"**，
>    门槛 4 直接拒绝"一次性集中提交"的历史。
>
>    **本仓库当前状态**：9 个提交，其中 6 个挤在 8-06/8-07 两天，
>    然后 8-13 一个、8-16 一个，**之后停了十七天**。
>    这正是那个检查要抓的形状。现在还早，恢复正常提交就能修好——
>    **这次有效性扫描本身就是因为这个停更触发的。**
>
> 2. **每当有东西能跑就打个 tag。**
>    机理模型测试全绿 → `v0.2.0`；闭合项能拟合了 → `v0.3.0`。
>    "有 tag 的发布 + CHANGELOG"是 JOSS 评估单人项目成熟度的指标之一——
>    而且这是**门槛 3 唯一还缺的那一项**：它对单作者项目要求的其他指标
>    （CI、文档、CONTRIBUTING、维护声明、CHANGELOG）仓库里都有了。
>
> 时间表本身可以滑，这两条不能。

## §T.4 The two things the solo track must not skimp on

JOSS's most common rejection reason is that a submission is a thin wrapper around existing
packages. For this project, two components carry the "substantial scholarly effort"
argument, and neither can be a stub at submission time:

1. **The declarative constrained-closure layer** — requesting
   `(:nonnegative, :zero_at_origin, :residual)` and getting a provably mass-conserving,
   correctly-initialised closure is genuine design work, not glue.
2. **`recoverability_curve` and `mechanistic_content_test`** — capabilities no other
   package offers.

Documentation quality will not compensate for these being empty.

> **中文讲解｜CN**
> 这两件是 **JOSS 论文的立身之本**，必须实现到位：
> 1. **声明式的约束闭合层**——用户写 `(:nonnegative, :zero_at_origin, :residual)`，
>    拿到的是一个可证明质量守恒、初始化正确的闭合项。这是真正的设计工作。
> 2. **`recoverability_curve` 和 `mechanistic_content_test`**——别的包没有的能力。
>
> **文档写得再好也补不上这两块是空的。** 排期时优先保证它们，其他都可以让。

---

# The full programme

The phases below are the complete plan. On the solo track, execute the same phases with the
scope of §T.2 and skip Phase 4 onward.

---

## Phase −1 — Go public ✅ done 2026-08-06

Not a research phase, but it gates the JOSS submission and costs almost nothing.

- [x] Repository public at https://github.com/lorendw7/PerfusionUDE.jl with `LICENSE`,
      `README.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `CITATION.cff`, CI and the
      design docs
- [x] Issues and Discussions enabled
- [x] Dependency UUIDs resolved by `Pkg` (two hand-written ones were wrong)
- [x] `v0.1.0` tagged and released
- [x] `CHANGELOG.md` and a stated maintenance/support commitment — solo-submission
      maturity indicators
- [ ] Weekly commit cadence established — **broken 2026-08-16 → 2026-09-02 (17 days);
      re-established 2026-09-02**
- [ ] A tagged release beyond `v0.1.0` — the one JOSS gate-3 indicator still missing

**The JOSS six-month public-development clock started 2026-08-06. Earliest submission:
after 2027-02-06** (JOSS requires *more than* six months, so that date is the boundary,
not a valid submission date).

**Reaching that date is no longer sufficient.** Since 2026-03-15 JOSS applies four
pre-review gates, and gate 2 requires *evidence that the software is being used for
research* — see [13 §13.2](13-publication-strategy.md), risk **R12**, and
[11 §11.7.5](11-literature-landscape.md). Phase −1 gates the clock; it does not gate the
submission.

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
>
> **2026-09-02 补充：光是等满六个月已经不够了。**
> JOSS 从 2026-03-15 起加了四道初审门槛，其中第 2 道要求
> **"有证据表明软件正在被用于研究"**（见 [13 §13.2](13-publication-strategy.md) 和风险 R12）。
> Phase −1 只启动了那个时钟，**它并不等于拿到了投稿资格**。

---

## Phase 0 — Mechanistic forward model (CPU only)

*Solo track: yes, on the 5-compartment model.*

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

*Solo track: yes. This is the phase that decides whether the project works.*

**Goal:** the whole method working end-to-end on CPU with $N = 50$.

Tasks:
1. `Lux.jl` network, residual form, zero-init ([03 §3.4](03-ude-formulation.md)).
2. Joint parameter vector as a `ComponentArray`.
3. Objective per [04 §4.4](04-population-inverse-problem.md), full-batch.
4. **Finite-difference gradient check** — build this before the optimizer.
5. Optimization schedule Stages 0–3 ([04 §4.5](04-population-inverse-problem.md)).
6. Twin data generator with mechanism H1, including all corruptions ([07 §7.2](07-validation-protocol.md)).
7. Baselines B0, B1, B3, B4.
8. **Test D — mechanistic-content test** under the pre-registered rule of
   [06 §6.0](06-identifiability.md): $R = 10$ seeds for UDE and B3 alike, $2\sigma_{\mathrm{run}}$
   threshold, in-sample precondition, and the ordered failure response. `TestDRule` must be
   committed before the first Phase-1 fit.

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

*Solo track: yes, Layout B only.*

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

*Solo track: reduced — 2-D sweep $(N,\sigma)$, mechanism H1, baselines B0/B1/B3.*

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

*Solo track: **deferred**. Needs a pharmacometrics collaborator — see §T.1.*

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

*Solo track: **deferred**.*

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
| R9 | JOSS 6-month public-repo clock not started | ~~Certain if delayed~~ **retired** | Medium | Repo public since 2026-08-06 | — |
| R9′ | **Commit distribution fails JOSS gate 1/4** — history reads as a burst plus gaps rather than sustained development | **High** | **High** | §T.3 rule 1, enforced weekly; tag releases as milestones land | Any 7-day period with no commit |
| R12 | **JOSS gate 2 (demonstrated research impact) unmet at submission** — the package is not *used* for research by anyone, including us | **High** | **High** | Make the Phase-1/Phase-3 arXiv preprint a prerequisite, and have it **use and cite** the package ([13 §13.2](13-publication-strategy.md)) | Reaching 2027-02-06 with no preprint or external use citing the package |
| R10 | UDE turns out to be observationally equivalent to a neural ODE | Medium | **Very high** | Test D in Phase 1; narrow $\mathbf{z}$, tighten placement and structural constraints | Test D fails |
| R11 | A competing package or paper closes the gap mid-project | Medium | Medium | Early arXiv preprint; re-run the literature sweep before each submission | New package/paper found in a sweep |
| R13 | **A weak dependency's compat bound silently excludes its current release** — the base package tests green because the extension is never loaded on CI | **Realised 2026-09-02** | Medium | Re-check every bound against upstream releases at each sweep; CI cannot catch this for weak deps | Any bound whose upper major is below the package's latest release |

**R11 has not fired but moved.** The third sweep found no package closing the gap, but
`NeoPKPD` (a broad Julia PK/PD platform) was registered within a month of this repository
going public, and iNODE (arXiv:2608.13044) appeared in August 2026 doing
identifiability-aware architecture selection for neural ODEs. Neither takes the niche; both
narrow the claims. See [11 §11.7.3](11-literature-landscape.md) and
[§11.7.4](11-literature-landscape.md).

**R13 already fired.** `CUDA = "5"` against a released CUDA.jl 6.3.1, and
`SymbolicRegression = "1"` against a released 2.2.0. Because both are weak dependencies,
CI stayed green — the failure would have surfaced in Phase 2 or Phase 3, when the
extension was first needed. Fixed in the same pass; the mechanism is what to remember.

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

**A pinning discipline is not a compat-bound discipline — and the second one has already
failed once.** A `[compat]` upper bound that names a single major (`CUDA = "5"`) does not
"pin" anything; it *excludes* every later major, and for a **weak** dependency it does so
invisibly, because the extension is never loaded on a CPU-only CI runner. On 2026-09-02
both extension bounds in this repository were found to exclude the current release of
their package ([11 §11.7.6](11-literature-landscape.md), R13). Add to the procedure:

5. **At every literature sweep, re-check each `[compat]` upper bound against the
   dependency's latest release**, weak dependencies first. This costs one `git ls-remote`
   per dependency and is the only check that covers code CI never exercises.

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
