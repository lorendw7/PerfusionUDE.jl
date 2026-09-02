# 13 — Publication Strategy: JOSS + PLOS Computational Biology

Requirements below were confirmed from journal documentation on **2026-08-06**. Re-verify
before submitting; journal policies change.

---

> **Revised 2026-08-07 — track selection.** For a single developer without a
> pharmacometrics collaborator, **only Paper 1 (JOSS) is realistically achievable**; Paper 2
> requires real clinical data, a classical-NLME comparison, and domain review. See
> [09 §T.1](09-implementation-roadmap.md). Paper 2 stays documented here as the option to
> take up if the project attracts a collaborator — it should not drive the schedule.

---

## 13.1 The core recommendation: two papers, not one

The software contribution and the scientific contribution have different audiences,
different review criteria, and different timelines. Splitting them is not padding — it is
the correct mapping of content to venue.

| | **Paper 1 — JOSS** | **Paper 2 — PLOS Comp Biol** |
|---|---|---|
| Object | `PerfusionUDE.jl` the software | The recoverability study |
| Claim | "Here is an open, differentiable, GPU-parallel PBPK layer that did not exist" | "Here is when a physiologically-constrained closure is functionally identifiable from population PK data" |
| Article type | Software paper (~1000 words) | **Methods** or **Research** article — *not* Software (see §13.3) |
| Gating requirement | **Repo public ≥ 6 months with active development** | Phases 0–4 complete; real-data case study |
| Review focus | Documentation, tests, installability, statement of need | Novelty, rigour, biological insight |
| Realistic timing | ~6–9 months from repo going public | ~12–18 months |

Paper 1 is a prerequisite asset for Paper 2: a reviewer of Paper 2 who can install and run
the software takes the results more seriously, and JOSS acceptance gives you a citable,
DOI-bearing software artifact to reference.

> **中文讲解｜CN**
> **拆成两篇是本文档的核心建议，理由不是"多发一篇"，而是内容与期刊的匹配问题。**
>
> JOSS 评审的是**软件本身**：文档全不全、测试有没有、装得上装不上、
> 是否填补了真实空白。它**不评审科学结论**。
> PLOS Comp Biol 评审的是**科学贡献**：新颖性、严谨性、生物学洞见。
>
> 把两者塞进一篇，结果是两边都不讨好：
> JOSS 觉得科学内容超纲、PLOS 觉得软件描述冗余。
>
> 而且时间线完全不同：JOSS 卡在"仓库公开满 6 个月"，
> PLOS 卡在"Phase 0–4 全部完成 + 真实数据案例"。
> 拆开之后，JOSS 那篇可以在科学研究还在进行时就投出去，
> **而且它的录用会反过来增强 PLOS 那篇的可信度**（审稿人能装上、能跑）。

---

## 13.2 JOSS — requirements and how to satisfy them

### Pre-review screening gates (confirmed 2026-09-02 — **read this before the table**)

Since **2026-03-15** JOSS applies four *pre-review screening criteria* before a submission
enters review: *"a submission that fails any one of these will receive a desk rejection."*
Verified against the `openjournals/joss` repository at commit `4966962` (2026-08-26);
the gates were introduced by commit `57b370c`. See
[11 §11.7.5](11-literature-landscape.md) for the full provenance and for what this
supersedes.

| # | Gate | Where we stand |
|---|---|---|
| 1 | **Sufficient public development history** — public **more than** six months, *"active development spanning that period"*; *"we run automated checks on commit distribution — a repo dump is not a history"* | Clock started 2026-08-06. **The distribution, not the elapsed time, is the exposure** — see §T.3 |
| 2 | **Demonstrated research impact** — *"there must be evidence that the software is being used for research"*; *"aspirational statements about future use are not sufficient"* | ⚠️ **The binding constraint. Not modelled by the old timeline** — see below |
| 3 | **Good open source practices** — for a solo project, *multiple* indicators: commit history over time, tagged releases or changelog, tests and CI, docs, `CONTRIBUTING`, stated support expectations | Changelog ✅ CI ✅ docs ✅ `CONTRIBUTING` ✅ maintenance statement ✅ — **missing: a tagged release beyond `v0.1.0`** |
| 4 | **Iterative development over time** — *"ongoing iteration, not a single burst of commits"* | Gate 1 from the other side; §T.3's weekly-commit rule protects it |

**Gate 2 replaces the six-month clock as the binding constraint.** The clock expires on
2027-02-06 and runs by itself; Gate 2 does not. The remedy is already in the plan but
mis-classified: §13.4 lists an early arXiv preprint as a priority-securing nicety. **It is
now a submission prerequisite**, and it only counts if the preprint *uses* the package and
*cites* it — that is precisely JOSS's *"references in published papers or preprints"*.
Adoption inside a private workflow is also acceptable, but must be *demonstrated to the
editorial team*, which is harder than posting a preprint.

> **中文讲解｜CN**
> **自 2026-03-15 起，JOSS 在进入评审前先过四道门，任何一道不过就是直接拒稿（desk rejection）。**
> 这四道门是从 `openjournals/joss` 仓库里直接读出来的（commit `57b370c` 引入），
> 不是二手转述——出处见 [11 §11.7.5](11-literature-landscape.md)。
>
> **最要紧的是第 2 道门，而旧计划完全没有考虑它。**
> 原文：**"必须有证据表明软件正在被用于研究……对未来用途的展望不算数。"**
>
> 六个月的钟会自己走完（2027-02-06），**第 2 道门不会自己走完**。
> 好消息是解法已经在计划里了，只是**定位错了**：§13.4 把"早点挂 arXiv 预印本"
> 写成了"确立优先权的好习惯"。**它现在是投稿的前置条件**，
> 而且只有当那篇预印本**真的用了这个包并且引用了它**才算数。
>
> **第 3 道门我们已经快过了**——CHANGELOG、CI、文档、CONTRIBUTING、维护声明都有，
> 只差 `v0.1.0` 之后的一个 tag。**这是四道门里最便宜的一道，不要拖。**

### Hard requirements (confirmed 2026-08-06, re-checked 2026-09-02)

**Cost and eligibility.** JOSS is diamond open access: **no article processing charges, no
submission fees, no subscription**. It is run by volunteers and published by Open Journals
under NumFOCUS fiscal sponsorship. There is **no institutional-affiliation requirement and
no minimum number of authors** — the only authorship rule is that the submitting author be
a major contributor to the software. See [12 §12.6](12-package-design.md) for the extra
maturity indicators applied to single-author submissions.

| Requirement | Status / action |
|---|---|
| OSI-approved license as a `LICENSE` file | MIT, committed |
| Public repo, browsable & clonable without registration | GitHub, public |
| Public issue tracker | GitHub Issues enabled |
| **Public > 6 months with active development spanning that period** | Clock started 2026-08-06 → earliest submission **after** 2027-02-06. **Gate 1** above |
| Automated tests + CI | See [12 §12.4](12-package-design.md) |
| Documentation: install, example, API, community guidelines | See [12 §12.5](12-package-design.md) |
| `paper.md` + `paper.bib` | Drafted in `paper/` |
| Archived release with DOI | Zenodo, at acceptance |
| **AI usage disclosure** | §13.5 — policy added 2025-09-16, current wording 2025-12-07 |
| **Evidence the software is used for research** | ⚠️ **Gate 2** above — not satisfied by the twin study alone |
| Not a pre-trained model or a notebook collection | N/A — it is a package |

### Required `paper.md` sections (confirmed)

1. **Summary** — high-level functionality for a diverse, non-specialist audience.
2. **Statement of need** — the problem solved and the target audience.
3. **State of the field** — comparison to existing packages, with justification.
4. **Software design** — architecture and trade-offs.
5. **Research impact statement** — concrete evidence of use or benchmarks.
6. **AI usage disclosure.**
7. Authors, affiliations, key references, software archive link.

Do **not** put API documentation in the paper; that belongs in the docs.

### The state-of-the-field paragraph (draft)

> Population PBPK modelling is served by NONMEM, Monolix, Pumas.jl and PK-Sim/MoBi;
> open-source options include nlmixr2, mrgsolve, rxode2 and PKPDsim in R, and NoLimits.jl
> and NeoPKPD in Julia. Neural-network-augmented mixed-effects modelling is available in
> the commercial DeepPumas, and neural closures inside PK ODEs have been demonstrated for
> single-compartment models (Valderrama et al. 2024) and, on the covariate → parameter map,
> hierarchically in Julia (Elmokadem et al. 2024). None of these expose a composable,
> differentiable PBPK transport-network layer with GPU-parallel population ensembles: the
> Julia PBPK resources that exist (`bioPBPK`, `BayesPBPK-tutorial`) are model collections
> and tutorials rather than packages, NoLimits.jl and NeoPKPD are general NLME and PK/PD
> estimation packages with no organ-level transport layer, and PK-Sim is a GUI/XML
> modelling environment without a differentiable-programming path. PerfusionUDE.jl fills
> that gap and interoperates with NoLimits.jl for marginal-likelihood-correct inference
> rather than duplicating it.

*Basis for the enumeration: the Julia General registry was enumerated on 2026-09-02, not
searched — see [11 §11.7.4](11-literature-landscape.md). State the method and the date in
the manuscript; "we could not find one" and "we enumerated the registry" are not the same
claim.*

> **中文讲解｜CN**
> 上面这段是 **state of the field 的草稿**，写法上有三点值得学：
>
> 1. **先列全竞品**（商业的、R 的、Julia 的、神经网络的），不回避；
> 2. **再指出共同缺口**，而且缺口是具体的技术能力，不是"我们更好"；
> 3. **最后主动说明与最接近竞品的关系是互操作而非替代**——
>    JOSS 评审员很可能就是 Julia 生态里的人，甚至可能认识 NoLimits.jl 的作者。
>    这一句能把潜在的敌意变成善意。
>
> ⚠️ 投稿前务必重新检索一遍，确认这段里的事实仍然成立，并在文中注明检索日期。

### JOSS risk: "substantial scholarly effort"

JOSS rejects thin wrappers. Our defence, in order of strength:

1. The **constrained-closure layer** (structural physics constraints as declarative
   options) is genuine design work, not a wrapper.
2. The **GPU population-ensemble + mixed-mode gradient layer** is non-trivial engineering
   with measured benchmarks.
3. The **physics-tier test suite** asserting conservation laws.
4. The **recoverability tooling** (`recoverability_curve`, `mechanistic_content_test`) is
   a capability no other package offers.
5. Depth of design documentation.

> **中文讲解｜CN**
> "substantial scholarly effort"（实质性学术工作量）是 JOSS 最常见的拒稿理由，
> 针对的是"把几个现成包串起来"的薄封装。
>
> 我们的五条抗辩里，**第 1 和第 4 条最有力**：
> - 第 1 条：把物理约束做成声明式选项，是真正的设计工作（有取舍、有理由）；
> - 第 4 条：`recoverability_curve` 和 `mechanistic_content_test` 是**别处没有的能力**，
>   不是任何现成包的组合。
>
> 反过来说，如果最后包变成"薄薄一层调用 DiffEqGPU 和 Lux"，就会被这条卡住。
> **所以第 1 和第 4 层的实现一定要做扎实，它们是 JOSS 论文的立身之本。**

---

## 13.3 PLOS Computational Biology — pick the right article type

Confirmed requirements (2026-08-06):

**Software articles** must describe software that is *"widely adopted, or has the promise
of wide adoption"* and represents *"a significant advance in providing new biological
insights"*. OSI license required; archived software, documentation and test data must be
deposited as supplemental files (< 100 MB); **< 3,500 words**; sections: Title, Authors,
Abstract, Introduction, Design and Implementation, Results, Availability and Future
Directions.

**Methods articles** must describe *"outstanding methods of exceptional importance"* with
*"wide adoption or the promise of wide adoption"*, provide enough detail/data/software for
reproduction, and are submitted with a cover letter addressing: the major innovation
versus the current state, substantiality and relevance, the concrete method and its
intended users, the validation approach, and the availability strategy.

### Recommendation: submit as a **Methods** article, not Software

Honest reasoning:

- The PLOS CB **Software** bar — "widely adopted" and "new biological insights" — is
  designed for tools with an existing user base. A newly released package will struggle,
  and that is exactly the ground JOSS covers better.
- Our strongest result is not the code, it is the **recoverability characterization**: the
  phase diagram over $(N, n_{\mathrm{obs}}, \sigma)$, the mechanistic-content test, and
  the functional-identifiability analysis of PBPK closures. That is a *method* with a
  validation study.
- If the real-data case study yields a concrete pharmacological finding (a recovered
  clearance mechanism that a published model missed), upgrade the framing to a **Research**
  article, where "new biological insight" is the natural claim.

**Decision rule:** Methods article by default; Research article if the real-data case
produces a substantive pharmacological result; Software article only if the package has
demonstrable external adoption by submission time.

> **中文讲解｜CN**
> **这一节是诚实建议，可能和你原本的设想不同，请认真考虑。**
>
> PLOS Comp Biol 的 **Software** 类别要求"已被广泛采用或有广泛采用的前景"
> 且"提供新的生物学洞见"。一个刚发布的新包，很难通过这一条——
> 这不是质量问题，是类别匹配问题。而"新软件"这块地，**JOSS 覆盖得更好**。
>
> 我们真正强的结果不是代码，是**可恢复性刻画**：
> $(N, n_{\mathrm{obs}}, \sigma)$ 相图、机制含量检验、PBPK 闭合项的函数可辨识性分析。
> **这是一个"方法 + 验证研究"，正好对应 Methods 类别。**
>
> 决策规则：
> - **默认投 Methods**；
> - 如果真实数据案例真的发现了某个已发表模型漏掉的机制 → **升级为 Research**（生物学洞见成立）；
> - 只有当投稿时包已经有外部用户在用 → 才考虑 Software。
>
> 注意 Methods 类别要求**投稿信**回答五个问题（创新点、重要性、方法本身、验证、可获得性）。
> 建议在 Phase 3 结束时就把这五个问题的答案写下来——如果写不出来，说明工作还不够。

### PLOS CB paper skeleton (Methods)

| Section | Content |
|---|---|
| Introduction | PBPK closures are empirical and extrapolate poorly; UDEs promise data-driven closure; but *when is the closure recoverable?* — nobody has answered this |
| Methods | Constrained closure construction; hierarchical model; joint MAP + GPU ensemble; mixed-mode gradients; parametric vs functional identifiability framework (cite Loman & Baker 2025) |
| Results 1 | Twin study phase diagram over $(N, n_{\mathrm{obs}}, \sigma)$ |
| Results 2 | Baselines B0–B4; mechanistic-content test (Test D) |
| Results 3 | Symbolic recovery with refit verification |
| Results 4 | Real-data case study, VPC, comparison to published NLME |
| Results 5 | Computational scaling; honest breakeven $N$ |
| Discussion | Limitations: joint-MAP variance bias; support-set validity; plasma-only identifiability limits; H3 negative result |
| Availability | `PerfusionUDE.jl`, JOSS DOI, Zenodo archive, reproduction scripts |

**Include the negative results (H3, the failure regions of the phase diagram).** A methods
paper that maps its own failure boundary is more useful, and more publishable, than one
that reports only successes.

---

## 13.4 Timeline

Dates are relative to the repository going public — **call that $T_0$, and make it this
week.**

*Revised 2026-09-02 to be driven by JOSS gate 2 rather than by the six-month clock. $T_0$ =
2026-08-06. The same schedule, expressed in weeks with the immediate next step, is in
[09 — Where the project stands](09-implementation-roadmap.md).*

| Time | Milestone | Publication action | JOSS gate it serves |
|---|---|---|---|
| $T_0$ ✅ | Repo public; docs committed; `v0.1.0` tag | 6-month clock starts | 1 |
| $T_0$ + 1–2 mo | Phase 0 complete: mechanistic model passes its six tests | **Tag `v0.2.0`** | 3 (closes it) |
| $T_0$ + 2–3 mo | Structural-identifiability study ([06 §6.2](06-identifiability.md)) via the `StructuralIdentifiability` extension | **arXiv preprint v1** (decided 2026-09-02): which closure families are identifiable from plasma alone; uses and cites the package | **2 (begins)** |
| $T_0$ + 3–4 mo | Phase 1 complete (CPU UDE, $N=50$, Test D passed) | **Tag `v0.3.0`; preprint v2** with the twin-study result | 2 · 4 |
| $T_0$ + 4–5 mo | Phase 2 complete (GPU, benchmarks) | Tutorials + CI mature; regular tags | 3 · 4 |
| $T_0$ + 5–6 mo | Phase 3 running (twin sweep) | Preprint v2 with the phase diagram; draft `paper.md`; re-verify every **[S]**/**[U]** reference | 2 (strengthens) |
| $T_0$ + 6–7 mo | Package registered, docs complete | **Submit to JOSS — after 2027-02-06 *and* with a public preprint citing the package** | all four |
| $T_0$ + 8–12 mo | Phase 4 (real data, VEM, FOCE comparison) | JOSS review + revisions | — |
| $T_0$ + 12–15 mo | Full results assembled | Draft PLOS CB Methods manuscript | — |
| $T_0$ + 15–18 mo | — | **Submit to PLOS CB** | — |

If Phase 1 slips, **the preprint slips with it and so does the JOSS submission** — the
clock date does not move the submission forward. If Phase 1 lands early, submit the
preprint early; it does not have to wait for the GPU results.

Three scheduling notes:

1. ~~**The 6-month rule is the binding constraint on JOSS.**~~ **Superseded 2026-09-02.**
   The clock still cannot be compressed — it expires 2027-02-06 and submission must be
   *after* that date — but it now runs by itself. The binding constraint is **Gate 2,
   demonstrated research impact** (§13.2): the package must be *in use for research* at
   submission time, and aspirational statements do not count. Plan backwards from that,
   not from the calendar.
2. **Post an arXiv preprint early** (after Phase 1) — **now a submission prerequisite,
   not an optional nicety.** It establishes priority in a fast-moving area — see
   [11 §11.2](11-literature-landscape.md) and the August-2026 arrivals in
   [§11.7.3](11-literature-landscape.md) — *and* it is the Gate 2 evidence, provided it
   **uses the package and cites it**. A preprint about the method that does not cite the
   software satisfies neither purpose fully.
3. **Re-run the literature sweep one week before each submission** and record the date in
   the manuscript.

> **中文讲解｜CN**
> **三条时间线纪律，第 1 条最重要：**
>
> 1. **6 个月公开期是 JOSS 的硬约束，任何努力都压缩不了它。**
>    所以正确顺序是"**先公开仓库，再慢慢写代码**"，而不是"写好了再公开"。
>    现在仓库里只有文档也完全可以公开——文档提交同样是开发活动。
>    **每晚一周公开，JOSS 就晚一周能投。**
>
> 2. **Phase 1 结束就挂 arXiv 预印本。** 从 [11 §11.2](11-literature-landscape.md) 可以看到，
>    PBPK + 深度学习这个方向 2024–2026 在快速升温，随时可能有人做类似的事。
>    预印本成本几乎为零，但能确立优先权。**不要等论文完美了再挂。**
>
> 3. 每次投稿前一周重跑文献检索并在稿件里注明日期——
>    这既是自我保护（避免遗漏新竞品），也是专业性的体现。

---

## 13.5 AI usage disclosure

JOSS requires an explicit statement. The policy was added on **2025-09-16** and reached its
current wording on **2025-12-07** (verified 2026-09-02 against `openjournals/joss`; see
[11 §11.7.5](11-literature-landscape.md)). The documentation in this repository was drafted
with substantial assistance from a large language model (Claude, Anthropic). Disclose it
plainly; it does not affect eligibility, and omitting it would.

The policy requires **three** elements, and the disclosure is incomplete without all of
them:

1. **Tool use** — the tools/models used **and their versions**, and **where** they were
   used (code, paper text, docs).
2. **Nature and scope** of the assistance — code generation, refactoring, test
   scaffolding, copy-editing, drafting.
3. **Confirmation of review** — an assertion that the human authors reviewed, edited and
   validated all AI-assisted output **and made the core design decisions**.

Keep a running record of (1) as work proceeds; model versions change and cannot be
reconstructed a year later from memory.

Suggested wording for `paper.md` — fill in the bracketed parts from that record:

> **AI usage disclosure.** Generative AI (Claude, Anthropic; models [list the models and
> versions used]) was used in the preparation of this software and manuscript, as follows:
> **design documentation** — drafting and editing; **literature search** — candidate
> identification and metadata retrieval, with citation status tracked explicitly in the
> repository; **source code** — [state the scope: e.g. implementation drafting, test
> scaffolding, refactoring]; **paper text** — [state the scope]. The human authors
> reviewed, edited and validated all AI-assisted output and **made all core design
> decisions**, including the model formulation, the closure placement and its structural
> constraints, the identifiability tests and their acceptance criteria, and the validation
> protocol. All experimental design decisions, numerical results and scientific claims are
> the authors' own.

Note what this wording does **not** claim. The earlier draft ended with *"all cited
references were verified against their primary sources"*. **Do not write that sentence
until it is true.** The third sweep introduced a **[S]** tier for references confirmed
only from search-index metadata because the primary sources were unreachable
([11 §11.7.0](11-literature-landscape.md)); while any **[S]** or **[U]** entry remains in
[10-references.md](10-references.md) or [11](11-literature-landscape.md), that clause would
be false, and JOSS treats an inaccurate disclosure as an ethical breach, not a slip.

> **中文讲解｜CN**
> **这一条不要有任何侥幸心理。**
>
> JOSS 现在明确要求披露生成式 AI 的使用（政策 2025-09-16 加入，2025-12-07 定稿）。
> 本仓库的设计文档确实由 Claude 大量协助起草，这**必须**写进 paper.md。
> 如实披露完全不影响录用；不披露被发现则是学术不端。
>
> **原来的草稿漏了两个必需要素**，2026-09-02 核对官方政策后补上：
> **(1) 模型的"版本"和"用在哪里"（代码/正文/文档要分开说）**；
> **(2) "核心设计决策由人类作者做出"这句断言**——政策原文明确要求这一句。
> 建议**边做边记**模型版本，一年后回忆不出来。
>
> ⚠️ 关于最后那句"所有引用文献均已对照原始来源核实"：**新措辞里已经删掉了它。**
> 第三次扫描新增了 **[S]** 档（只有检索元数据、打不开原始页面，见
> [11 §11.7.0](11-literature-landscape.md)）。
> **只要 [10](10-references.md) 和 [11](11-literature-landscape.md) 里还有 [S] 或 [U]，
> 这句话就是假的。** JOSS 把披露不实当作学术不端处理，不是笔误。
>
> 这也是为什么那两份文档要用标记区分状态——它不是形式，是给你自己的待办清单。

---

## 13.6 Backup and adjacent venues

| Venue | When to use |
|---|---|
| **CPT: Pharmacometrics & Systems Pharmacology** | If the work reads better to a PK audience than a comp-bio one; strong existing literature on neural ODEs in PK |
| **Journal of Pharmacokinetics and Pharmacodynamics** | Methodological PK audience; good fit for the identifiability results |
| **PLOS ONE / Scientific Reports** | Fallback if PLOS CB rejects on impact grounds |
| **arXiv (q-bio.QM / stat.ME)** | Always, early, non-exclusive |
| **JuliaCon Proceedings** | Alternative software venue if JOSS timing does not work out |

If PLOS CB rejects on "insufficient biological insight" — a plausible outcome for a
methods-heavy paper — CPT:PSP is the better home, and the identifiability results will be
appreciated more by that readership.

> **中文讲解｜CN**
> **提前想好被拒之后去哪，可以避免被拒时的时间损失和情绪损失。**
>
> 最可能的拒稿理由是"生物学洞见不足"——对一篇偏方法学的论文，这很正常。
> 那种情况下 **CPT:PSP 是更合适的归宿**：
> 那里的读者本来就关心可辨识性、NLME 方法学、神经 ODE 在 PK 里的应用，
> 我们的结果在他们眼里价值更高。
>
> 另外 **JuliaCon Proceedings** 值得记住：如果 JOSS 的 6 个月期限导致时间安排不上，
> 它是一个可替代的软件论文出口，而且 Julia 社区的曝光度更高。

---

## 13.7 Authorship for a solo project

Verified 2026-09-02 against `openjournals/joss` (`docs/submitting.md` § Authorship,
`docs/review_criteria.md` § Authorship and § Community engagement). **[V]**

**What JOSS requires.** One rule only: *"You must be a major contributor to the software
you are submitting."* There is no minimum author count and no affiliation requirement;
`Independent researcher` is accepted.

**What JOSS forbids.** *"Purely financial (such as being named on an award) and
organizational (such as general supervision of a research group) contributions are not
considered sufficient for co-authorship of JOSS submissions, but active project direction
and other forms of non-code contributions are."* A supervisor listed for the name alone is
therefore not a safeguard; it is a question a reviewer is told to raise. Co-authors must
agree to be listed and accept accountability for the whole work.

**What reviewers are told to look for.** Two passages matter for a single-author
submission:

1. *"If the author list seems unexpectedly short given the scope of the work, it is
   appropriate to raise this."* The same paragraph contrasts *"a single developer working
   closely with a research group — where advisors, collaborators, or domain experts are
   co-authors"* with *"a solo project with no broader community"*.
2. *"For single-author projects, community engagement evidence in the paper is acceptable
   and may be the primary signal"* — publications using the software, adoption, or
   modification in response to use.

**Decision, recorded here so it is not re-litigated.**

| Question | Answer | Basis |
|---|---|---|
| Can the JOSS paper be single-authored? | **Yes.** | Rule 1; §12.6 maturity indicators; gates 1–4 in §13.2 |
| Should a supervisor be added for the name? | **No.** It violates the authorship rule and invites the exact question reviewers are primed to ask. | Forbidden-contributions clause |
| When would a second author help? | When they do something specific: review the identifiability methodology of [06](06-identifiability.md) or the pharmacometrics, or co-author the preprint that serves gate 2. That is a real author, and it directly answers reviewer passage 1. | Permitted-contributions clause; review passage 1 |
| Where is a collaborator actually required? | **Paper 2 (PLOS CB) and Phase 4**, not this paper: real clinical data, an nlmixr2/NONMEM comparison, and pharmacometric peer reading cannot be self-supplied. | §T.1, §13.3 |

**Preprint v1 is decided (2026-09-02): the structural-identifiability study of
[06 §6.2](06-identifiability.md)**, because it is the cheapest piece of genuine research on
the critical path that exercises the package. The Phase-1 twin study becomes preprint v2.

**One practical item that is not authorship: arXiv endorsement, and the rule changed in
January 2026.** arXiv requires *endorsement* before a first submission to an endorsement
domain. Until 2026-01-21 an e-mail address from a known academic institution was usually
enough on its own. **It no longer is** **[S]** (arXiv blog, *"Attention Authors: updated
endorsement policy"*, 2026-01-21, following a similar change for mathematics on
2025-12-10): automatic endorsement now needs an institutional address **and** prior
authorship on a paper already accepted in that domain. A first-time author therefore needs
the second path regardless of e-mail: a **personal endorsement from an established arXiv
author in the same domain** — for q-bio.QM that means someone with several q-bio
submissions in the last three months to five years; standing in another domain does not
transfer. An endorser is not a co-author and takes on no responsibility. Set up the
account and secure the endorsement **before** the preprint is written, not on the day.

**The endorsement-free route: bioRxiv.** bioRxiv has no endorsement system **[S]**: an
author registers, supplies an affiliation, and the manuscript is screened by volunteer
affiliates for scope and non-scientific content, not for quality. Preprint v1 (structural
identifiability of PBPK closure families) is squarely within its Systems Biology /
Pharmacology and Toxicology scope, and the closest precedent in this plan, the AML
DeepNLME + symbolic-regression paper of [11 §11.2](11-literature-landscape.md), is itself a
bioRxiv preprint. JOSS gate 2 says *"published papers or preprints"* without naming a
server. **Decision (2026-09-02): post preprint v1 to bioRxiv unless an arXiv endorser is
already in hand; pursue arXiv endorsement in parallel for the later, more methods-heavy
preprint v2, where stat.ME / q-bio.QM readership matters more.**

**Who at Kyushu University could review or endorse (checked 2026-09-02, names to be
confirmed on the laboratory pages, which this network could not open).** The Faculty of
Pharmaceutical Sciences has a 薬物動態学分野 (pharmacokinetics) and a 薬剤学分野
(pharmaceutics) laboratory; these are the domain readers for the PBPK physiology and the
clearance closure, but Japanese pharmaceutical-sciences groups rarely post to arXiv, so they
are unlikely to be *eligible arXiv endorsers* even when they are the right reviewers. The
Department of Biology's mathematical-biology laboratory (Satake; Iwasa, emeritus) and the
Institute of Mathematics for Industry are likelier arXiv authors, but eligibility is
per-domain and must be checked on an abstract page's "Which of these authors are
endorsers?" link. **A CFD supervisor is the right reviewer for [08](08-cfd-correspondence.md)**
and for the closure-modelling framing of [01](01-background.md) and [03](03-ude-formulation.md);
that is a substantive, specific contribution of the kind JOSS's authorship rule permits,
and it answers the "short author list" question honestly. A CFD supervisor's arXiv standing
is in the physics domain and does not endorse q-bio; do not choose a category to fit an
endorser.

**Japanese venues.** None of these substitute for a preprint (gate 2 wants a citable,
public document), but each puts the work in front of the people who would review it,
endorse it or adopt it:

| Venue | Fit | 2026–27 timing (checked 2026-09-02; re-check) |
|---|---|---|
| 日本薬物動態学会 (JSSX) 年会 | The pharmacometrics audience; PBPK sessions | 41st: 2026-11-16 → 19, Tsukuba; abstracts closed 2026-07-17. Attend to meet people; present at the 42nd (2027, abstracts ≈ July 2027) |
| 日本数理生物学会 (JSMB) 年会 | Identifiability and ODE modelling; the natural home for preprint v1's content | 2026: 09-08 → 10, Matsue, closed. Next: 2027, abstracts ≈ July |
| 日本計算工学会 計算工学講演会 (JSCES) | The CFD-correspondence angle ([08](08-cfd-correspondence.md)); the supervisor's community; proceedings are published | 32nd: 2027-06-07 → 09, Saitama; abstracts ≈ January 2027 |
| 日本機械学会 計算力学講演会 (CMD) | Same angle, mechanical-engineering audience; presenters must be JSME members | CMD2026: 09-14 → 16, Osaka, closed; CMD2027 abstracts ≈ mid-2027 |
| 日本応用数理学会 (JSIAM) 年会 | Applied-mathematics audience; SciML sessions | 2026 annual meeting is in **Fukuoka**; check dates, likely September |

The one that fits both the content and the calendar is **JSCES June 2027**: its abstract
deadline falls right after preprint v1 should exist, it is the supervisor's community, and
[08](08-cfd-correspondence.md) was written for exactly that audience.

> **中文讲解｜CN**
> **背书问题最简单的解法是 bioRxiv。** 它没有背书制度：注册、填单位、通过范围筛查即可，
> 不审质量。预印本 v1（PBPK 闭合项家族的结构可辨识性）完全在它的范围内，
> 而且计划里引用的 AML DeepNLME 那篇本来就是 bioRxiv 预印本。JOSS 门槛 2 只说"论文或预印本"，
> 不限定服务器。**决定：v1 挂 bioRxiv，除非手上已经有 arXiv 背书人；arXiv 背书并行去办，
> 留给更偏方法学的 v2。**
>
> **九州大学校内**：薬学研究院有薬物動態学分野和薬剤学分野，是 PBPK 生理和清除率闭合的对口审读者，
> 但日本药学口的组几乎不上 arXiv，所以他们大概率**不是合格的 arXiv 背书人**，即使是对的审读者。
> 理学部数理生物学研究室（佐竹；巌佐名誉教授）和 IMI 更可能有 arXiv 记录，但要按领域逐个查。
> 名字这边的网络打不开研究室页面，请你自己核对。
>
> **导师审 CFD 部分完全可以，而且正合适**：[08](08-cfd-correspondence.md) 和 [01](01-background.md)、
> [03](03-ude-formulation.md) 的闭合建模类比就是写给 CFD 读者的。这是 JOSS 允许的那种
> "具体的非代码贡献"，也是对"作者名单太短"最诚实的回答。但导师的 arXiv 资历在物理领域，
> **不能给 q-bio 背书，也不要为了凑背书人去改分类。**
>
> **日本国内会议**：都不能替代预印本（门槛 2 要的是可引用的公开文档），
> 但都是认识审读者、背书人和潜在用户的地方。2026 年的截止基本都过了；
> **日程和内容都合的是 2027 年 6 月的計算工学講演会**：摘要截止约 2027 年 1 月，
> 正好在预印本 v1 之后，又是导师所在的圈子，[08](08-cfd-correspondence.md) 就是为这个听众写的。

> **中文讲解｜CN**
> **结论先说：JOSS 这篇可以一个人署名，不需要挂名，而且纯挂名是违规的。**
>
> JOSS 唯一的作者要求是"提交者必须是软件的主要贡献者"。它明文规定：
> 纯经费贡献和"对课题组的一般性指导"**不足以**成为共同作者；
> "积极的项目指导和其他非代码贡献"**可以**。区别在于有没有做事，不在于身份。
>
> 但审稿人被提前提醒了两件事：一是作者名单相对工作规模"显得意外地短"时应当提出来，
> 二是单作者项目的"社区使用证据"可以是主要信号。所以单作者是允许的，但会被多看一眼。
>
> 最有用的回应不是加名字，而是**让一位老师做一件具体的事**：
> 审阅 [06](06-identifiability.md) 的可辨识性方法，或在门槛 2 的预印本上共同署名。
> 那是真作者，也正好回答审稿人的那个问题。
>
> 真正需要合作者的是**第二篇论文和 Phase 4**：真实临床数据、nlmixr2/NONMEM 对比、
> 药代同行审读，这三样一个人补不上。但它们不属于 JOSS 这一篇。
>
> 还有一件和署名无关的实际事：**arXiv 的背书规则 2026 年 1 月改了。**
> 以前用学校邮箱注册基本就自动过；**从 2026-01-21 起不行了**，自动背书要求
> "机构邮箱 **加上** 已经在该领域有被接收的论文"。首次投稿的人不管用什么邮箱，
> 都要走第二条路：**找一位在同一领域（如 q-bio）近五年内发过若干篇 arXiv 论文的人做背书人**，
> 别的领域的资历不算。背书不是署名，对方不承担任何责任。
> **账号和背书要在预印本写完之前办好**，别等到要挂的那天。

---

**Back to:** [index](../index.md) · [11 — Literature Landscape](11-literature-landscape.md)
