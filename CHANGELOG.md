# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). While the
version is `0.x`, minor version bumps may contain breaking changes.

## [Unreleased]

### Added
- **Third literature and validity sweep, 2026-09-02** (design doc §11.7), triggered by a
  seventeen-day gap in the commit history rather than by the calendar. It re-checked the
  claims, the dependency bounds, the CI toolchain and the JOSS requirements, and introduced
  an **[S]** citation tier for references confirmed only from search-index metadata,
  because the network available to that sweep blocked the preprint and publisher sites
  themselves. Nothing previously marked **[V]** was downgraded; the new tier exists so that
  weaker evidence is not recorded as if it were stronger.
- `ReferenceIndividual` and `OrganReference`: reference physiology in which every value
  carries a mandatory `source` string, with accessors `tissue`, `blood_flow`,
  `liver_inflow`, `flow_continuity_residual` and `total_volume`. Unit tests assert
  Σq = 1 over perfused tissues, ΣV ≈ body weight, and that no `source` is empty.
- Second literature sweep (design doc §11.6): five works the first sweep missed, five
  citations upgraded from pointer to verified, and three plan defects recorded.
- The four **JOSS pre-review screening gates**, recorded in §13.2 as desk-rejection gates
  with their provenance. They were introduced upstream on 2026-03-15 and the 2026-08-07
  check read only the first of them, as scope prose rather than as a gate. Verified against
  the `openjournals/joss` repository at commit `4966962`, which dates each rule by the
  commit that added it.
- Risks **R9′** (commit distribution fails JOSS gates 1 and 4), **R12** (gate 2, research
  impact, unmet at submission) and **R13** (a weak dependency's compat bound silently
  excludes its current release).
- **§13.7 Authorship for a solo project**, verified against the JOSS authorship rule and
  reviewer guidelines: single authorship is permitted with no affiliation requirement;
  *"general supervision of a research group"* is explicitly insufficient for
  co-authorship, so a supervisor listed for the name alone violates the rule and invites
  the question reviewers are told to raise about short author lists; a second author helps
  only by doing something specific (methodology review, co-authoring the gate-2 preprint);
  a collaborator is genuinely required for Paper 2 and Phase 4, not for the JOSS paper.
  Also notes that arXiv endorsement is not authorship and should be checked before the
  preprint is ready.
- A dated **currency statement** in the README: positioning claims established by absence
  have a shelf life, and the reader should know when they were last checked.

### Changed
- **The research plan is repaired to match the third sweep, not merely annotated with it.**
  - **Test D has a decision rule** (design doc §6.0), closing the methodological hole open
    since §11.6.3(b): $R = 10$ seeds for UDE and B3 alike; the unit is the UDE's own
    seed-to-seed scatter $\sigma_{\mathrm{run}}$, fixed before B3 is examined; a pass
    requires comparable in-sample fit *and* a held-out-dose advantage of at least
    $2\sigma_{\mathrm{run}}$; an in-sample mismatch is *inconclusive*, not a pass; and the
    failure response is an ordered list (shrink $\mathbf{z}$ → tighten $\mathbf{S}$ →
    bounded multiplicative correction → report degeneracy as a result). The rule is to be
    frozen in code as `TestDRule` before the first Phase-1 fit.
  - **§06 gains a prior-art section (§6.7)** recording the decisions iNODE, Takeishi and
    Bisht & Agarwal force before §6.4 is implemented, and a new diagnostic (e): a parameter
    converging to its bound is a non-identifiability signature.
  - **§07** now says why a generative virtual population cannot replace the twin study
    (nothing to score recovery against), maps B2/B3 onto the PopPK/ML arms of Valderrama
    2025, and states in advance that the UDE should approach B0, not beat it.
  - **§09 opens with "Where the project stands, and what to do next"**, rewritten at every
    sweep: done, not done, and a week-by-week order of next actions starting with one
    commit of `topology.jl` this week. The §T.3 schedule and the §13.4 timeline are
    re-based on JOSS gate 2: a preprint that uses and cites the package is a month-4
    milestone and a submission prerequisite; `v0.2.0` closes gate 3.
- **The binding constraint on the JOSS submission is no longer the six-month clock.** §13.4
  said *"the 6-month rule is the binding constraint… nothing else you do can compress it"*;
  that is now false. The clock expires on 2027-02-06 and runs by itself, whereas **gate 2 —
  *"there must be evidence that the software is being used for research… aspirational
  statements about future use are not sufficient"*** — does not. The plan is re-based on it:
  the early arXiv preprint, previously an optional priority-securing move, is now a
  submission prerequisite and must *use and cite* the package.
- The **§11.4 novelty claim (iii)** is narrowed from identifiability-aware hybrid modelling
  in general to *the mechanistic-content test under a population hierarchy*, because iNODE
  (arXiv:2608.13044, August 2026) now performs Fisher-information-based,
  identifiability-aware architecture selection for neural ODEs — for a single system,
  without a population layer, and asking which network is best identified rather than
  whether the mechanistic skeleton contributes at all. Claim (ii) had already been narrowed
  by the second sweep; (iii) had not.
- The **§13.5 AI usage disclosure** wording now carries all three elements the JOSS policy
  requires: tool **versions**, **where** the tool was used, and the assertion that the human
  authors **made the core design decisions**. Its closing claim that all references were
  verified against primary sources was removed — with **[S]** entries on the books it would
  be false, and JOSS treats an inaccurate disclosure as an ethical breach.
- The **state-of-the-field paragraph** and the README now name `NeoPKPD`, a Julia PK/PD
  package registered since the last sweep, and state that the ecosystem gap was established
  by **enumerating** the General registry rather than by searching it. "We could not find
  one" and "we enumerated the registry" are not the same claim.
- CI third-party actions, all two or three majors behind: `actions/checkout` v4 → v7,
  `actions/upload-artifact` v4 → v7, `codecov/codecov-action` v4 → v7 (untouched upstream
  since 2024-10-01), `julia-actions/setup-julia` v2 → v3, `julia-actions/cache` v2 → v3.
  The `julia-actions/julia-*` actions remain on v1, which is current. Inputs were checked
  against the new majors before bumping; none changed.
- `paper/paper.md` is brought in line with all of the above: the statement of need and
  state-of-the-field section now name `NeoPKPD`, Valderrama et al. 2024 and Elmokadem et al.
  2024, carry a dated survey note explaining that the registry was enumerated rather than
  searched, and the research-impact section is marked as JOSS gate 2 rather than as a
  benchmark table. `paper/paper.bib` gains those references plus iNODE, and two entries the
  second sweep had already verified (`janssen2022deep`, `hybridnode2024identifiability`)
  were still carrying `TODO` authors and `[U]` markers, and are now filled in as far as
  the sweeps actually confirmed. Where only surnames were confirmed, only surnames are
  recorded and the given names stay marked `[U]`: a bibliography that guesses plausibly is
  the same failure mode as the invented titles fixed above.
- **Phase −0.5 complete: every reference physiology value is now verified against ICRP
  Publication 89 (2002) and cites the table it came from.** The reference individual is
  registered as `:icrp89_adult_male` (was `:human_adult_male_70kg`) and its body mass is
  73 kg, ICRP's reference adult male, not the round 70 kg of the illustrative table.
  Cardiac output 390 L/h is confirmed by Table 2.39 (6.5 l/min). Values ICRP 89 does not
  itself state — the venous/arterial split of the blood volume, the lumping of the portal
  viscera into `gut` — say `DERIVED` in their `source` and show the assignment, and a test
  asserts they do. Brown et al. (1997), the other source named in the design document, is
  paywalled and was not obtained, so nothing is attributed to it; where secondary
  literature quotes its human values they disagree with ICRP 89 (liver 22.7% vs 25.5%,
  kidney 17.5% vs 19% of cardiac output), so the two sets must not be mixed.
- Baseline **B4** (neural network on the covariate → parameter map) is no longer cut from
  the solo track — a hierarchical Julia implementation is now published, so the comparison
  is mandatory rather than optional.
- The statement of need narrows claim (ii) from GPU-parallel ensembles generally to the
  ensemble layout and mixed forward/adjoint gradient policy, and now names the prior art
  it sits on top of.
- Author metadata in `Project.toml`, `CITATION.cff`, `paper/paper.md` and `docs/make.jl`
  changed from `TODO` to the maintainer's GitHub handle; the placeholder ORCID
  `0000-0000-0000-0000` was commented out rather than left to resolve as a real identifier.

### Fixed
- **Two `[compat]` bounds excluded the current release of their dependency:** `CUDA = "5"`
  against a released CUDA.jl 6.3.1, and `SymbolicRegression = "1"` against a released 2.2.0.
  Both are weak dependencies, so the base package installed and CI stayed green — the
  failure would first have appeared in Phase 2 or Phase 3, when the extension was actually
  needed. Now `"5, 6"` and `"1, 2"`. The remaining eleven bounds were checked and are
  current. Re-checking every bound against upstream releases is added to the version-pinning
  procedure, because CI cannot cover code it never loads.
- **Two citations in §11.6.2 were recorded under titles that are not theirs.**
  arXiv:2602.06837 is *Learning Deep Hybrid Models with Sharpness-Aware Minimization*
  (Naoya Takeishi) — an **optimisation** paper, so it belongs in §06 as a mitigation for
  R10, not as an identifiability diagnostic; arXiv:2510.22096 is *Dynamic Graph Neural
  Networks for Physiological Based Pharmacokinetic Modeling: A Novel Data Driven Approach to
  Drug Concentration Prediction*. Both entries were marked `[U]`, but carried a plausible
  invented title, which is worse than a missing citation because it reads as verified. The
  rule is now explicit: **a `[U]` entry carries an identifier and a one-line description
  only.**
- **The README still described the reference physiology as unverified.** The ICRP 89
  verification landed in `5e34fb7`; the README paragraph written one commit earlier was
  never updated, so the repository's most-read page contradicted its own code and changelog.
- The §T.3 schedule still listed Phase −0.5 as pending work for months 0–1; it completed on
  2026-08-16 and is now marked as such, as is the `CHANGELOG.md` item under Phase −1.
- **Total hepatic blood flow was 28.5% of cardiac output instead of 25.5%, a 12%
  overestimate.** The gut was given ICRP 89's *portal total* of 19% while the spleen was
  also listed separately at 3%, so the spleen and pancreas were counted twice. The gut is
  now 16% — stomach and oesophagus 1.0 + small intestine 10 + large intestine 4.0 +
  pancreas 1.0 — and `liver_inflow` reproduces Table 2.40's independently stated 25.5%
  exactly, which is now a test. This is the flow that hepatic clearance, and therefore
  closure target A, is most sensitive to; nothing would have failed, the fitted curves
  would simply have been wrong.
- Three reference volumes were off against ICRP 89 Table 2.8: spleen 0.19 → 0.15 L, skin
  3.4 → 3.3 L, and adipose 14.3 → 14.5 L. The adipose row now uses "Separable adipose
  tissue, excluding yellow marrow", the entry without ICRP's footnote a, so that yellow
  marrow is not counted both here and in the skeleton.
- Display equations in the design docs used `$$…$$`, which Documenter does not parse as
  math; all 60 converted to ```math fences. The docs build failed before this.
- The documentation CI job listed eight pages that do not exist yet, which is a hard error
  in Documenter regardless of `warnonly`.
- Dropped the `x64` architecture pin from the CI matrix: `macOS-latest` is Apple Silicon,
  so the pin tested an emulated build.

### Planned for v0.2.0
- Minimal 5-compartment PBPK topology with flow-continuity assertions
- Allocation-free `StaticArrays` right-hand side
- Nondimensionalization layer
- Physics-tier tests: mass conservation, steady state, nonnegativity

---

## [0.1.0] — 2026-08-06

First public release. Establishes the package skeleton and the complete design
specification. **Implementations are stubs; this is not a usable release of the software.**

### Added
- Package scaffold: `Project.toml` with a CPU-only base, and CUDA/DiffEqGPU,
  SymbolicRegression and StructuralIdentifiability behind package extensions so the base
  package installs and tests without a GPU.
- MIT license, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `CITATION.cff`.
- Continuous integration across Julia 1.10 and 1 on Linux, Windows and macOS; Documenter
  setup; a workflow that builds the draft JOSS paper on every change.
- Test-suite skeleton organised in tiers (unit, physics, gradient, numerical, statistical,
  opt-in GPU).
- Design documentation (`docs/src/design/`, 00–13), in English with bilingual EN/中文
  teaching annotations: PBPK as a lumped-parameter transport network; the UDE closure
  formulation and its structural constraints; the hierarchical population inverse problem;
  GPU ensemble layouts and mixed-mode differentiation; identifiability; the validation
  protocol; the correspondence to CFD closure modelling and adjoint inverse problems; the
  implementation roadmap; the literature landscape as of 2026-08-06; package design; and
  publication strategy.
- Draft JOSS paper under `paper/`.

### Fixed
- Two hand-written dependency UUIDs were wrong (`Distributions`, `SymbolicRegression`),
  which broke resolution on CI. The dependency set is now resolved by `Pkg` against the
  General registry rather than written by hand, and compat bounds match what actually
  resolves.
- Added the three package extension modules declared in `[extensions]`; without those files
  the declarations were dangling.

### Known limitations
- No functionality is implemented yet.
- Dependency compat bounds have not been tested against their lower bounds.

[Unreleased]: https://github.com/lorendw7/PerfusionUDE.jl/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/lorendw7/PerfusionUDE.jl/releases/tag/v0.1.0
