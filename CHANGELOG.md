# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). While the
version is `0.x`, minor version bumps may contain breaking changes.

## [Unreleased]

### Planned for v0.2.0
- Reference physiology with provenance for every value (`ReferenceIndividual`)
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
