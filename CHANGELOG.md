# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). While the
version is `0.x`, minor version bumps may contain breaking changes.

## [Unreleased]

### Added
- `ReferenceIndividual` and `OrganReference`: reference physiology in which every value
  carries a mandatory `source` string, with accessors `tissue`, `blood_flow`,
  `liver_inflow`, `flow_continuity_residual` and `total_volume`. Unit tests assert
  Σq = 1 over perfused tissues, ΣV ≈ body weight, and that no `source` is empty.
  **The values themselves are the illustrative table from design doc §2.7 and are not yet
  verified against ICRP 89 / Brown et al. (1997)** — each `source` says so.
- Second literature sweep (design doc §11.6): five works the first sweep missed, five
  citations upgraded from pointer to verified, and three plan defects recorded.

### Changed
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
- Display equations in the design docs used `$$…$$`, which Documenter does not parse as
  math; all 60 converted to ```math fences. The docs build failed before this.
- The documentation CI job listed eight pages that do not exist yet, which is a hard error
  in Documenter regardless of `warnonly`.
- Dropped the `x64` architecture pin from the CI matrix: `macOS-latest` is Apple Silicon,
  so the pin tested an emulated build.

### Planned for v0.2.0
- Phase −0.5 (blocking): verify every reference physiology value against a primary source
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
