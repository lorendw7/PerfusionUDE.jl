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

### Hard requirements (confirmed 2026-08-06)

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
| **Public ≥ 6 months with active development spanning that period** | ⚠️ **Start the clock today** |
| Automated tests + CI | See [12 §12.4](12-package-design.md) |
| Documentation: install, example, API, community guidelines | See [12 §12.5](12-package-design.md) |
| `paper.md` + `paper.bib` | Drafted in `paper/` |
| Archived release with DOI | Zenodo, at acceptance |
| **AI usage disclosure** | §13.5 |
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
> open-source options include nlmixr2, mrgsolve, rxode2 and PKPDsim in R, and the recent
> NoLimits.jl in Julia. Neural-network-augmented mixed-effects modelling is available in
> the commercial DeepPumas. None of these expose a composable, differentiable PBPK
> transport-network layer with GPU-parallel population ensembles: the Julia PBPK resources
> that exist (`bioPBPK`, `BayesPBPK-tutorial`) are model collections and tutorials rather
> than packages, and PK-Sim is a GUI/XML modelling environment without a
> differentiable-programming path. PerfusionUDE.jl fills that gap and interoperates with
> NoLimits.jl for marginal-likelihood-correct inference rather than duplicating it.

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

| Time | Milestone | Publication action |
|---|---|---|
| $T_0$ | Repo public; docs committed; `v0.1.0` tag | **JOSS 6-month clock starts** |
| $T_0$ + 1–2 mo | Phase 0–1 complete (CPU UDE, $N=50$) | Regular releases; arXiv preprint of the *method* to establish priority |
| $T_0$ + 3–4 mo | Phase 2 complete (GPU, benchmarks) | Tutorials + CI mature |
| $T_0$ + 5–6 mo | Phase 3 running (twin sweep) | Draft `paper.md` |
| $T_0$ + 6–7 mo | Package registered, `v0.3.0`, docs complete | **Submit to JOSS** |
| $T_0$ + 8–12 mo | Phase 4 (real data, VEM, FOCE comparison) | JOSS review + revisions |
| $T_0$ + 12–15 mo | Full results assembled | Draft PLOS CB Methods manuscript |
| $T_0$ + 15–18 mo | — | **Submit to PLOS CB** |

Three scheduling notes:

1. **The 6-month rule is the binding constraint on JOSS.** Nothing else you do can
   compress it. Start the clock before writing another line of code.
2. **Post an arXiv preprint early** (after Phase 1). It establishes priority in a fast
   moving area — see [11 §11.2](11-literature-landscape.md) — and costs nothing.
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

JOSS requires an explicit statement. The documentation in this repository was drafted with
substantial assistance from a large language model (Claude, Anthropic). Disclose it
plainly; it does not affect eligibility, and omitting it would.

Suggested wording for `paper.md`:

> **AI usage disclosure.** Generative AI (Claude, Anthropic) was used to draft and edit
> portions of the project's design documentation and to assist with literature search.
> All software implementation, experimental design decisions, numerical results, and
> scientific claims are the authors' own; all AI-assisted text was reviewed and revised by
> the authors, and all cited references were verified against their primary sources.

Only state the last clause if it is true. Verify the references — see
[10-references.md](10-references.md) and the **[V]/[U]** markers in
[11](11-literature-landscape.md).

> **中文讲解｜CN**
> **这一条不要有任何侥幸心理。**
>
> JOSS 现在明确要求披露生成式 AI 的使用。本仓库的设计文档确实由 Claude 大量协助起草，
> 这**必须**写进 paper.md。如实披露完全不影响录用；不披露被发现则是学术不端。
>
> ⚠️ 但注意上面建议措辞的**最后一句**："所有引用文献均已对照原始来源核实"——
> **这句话只有在你真的做了核实之后才能写。**
>
> 目前 [10-references.md](10-references.md) 和 [11](11-literature-landscape.md) 里
> 标 **[U]** 的条目都还没核实。在写这句话之前，必须把它们全部核对完并改成 **[V]**。
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

**Back to:** [index](../index.md) · [11 — Literature Landscape](11-literature-landscape.md)
