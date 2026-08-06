# PerfusionUDE.jl

[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://lorendw7.github.io/PerfusionUDE.jl/dev)
[![CI](https://github.com/lorendw7/PerfusionUDE.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/lorendw7/PerfusionUDE.jl/actions/workflows/CI.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**GPU-parallel universal differential equations for population PBPK inverse problems.**

*Data-driven closure of lumped-parameter transport networks, and large-scale parallel
parameter inversion.*

> **Status: pre-release.** The design documentation is complete and authoritative; the
> implementation is in progress. See the [roadmap](docs/src/design/09-implementation-roadmap.md).

---

## Statement of need

Physiologically-based pharmacokinetic (PBPK) models divide the body into organ compartments
coupled by blood perfusion. Mathematically this is a **lumped-parameter transport network** —
mass conservation on a directed graph with convective fluxes — the same object that appears
in CFD as a 0D flow network or a Windkessel boundary condition.

The network is trustworthy: organ volumes and blood flows come from anatomy. The
**constitutive laws inside it are not**: metabolic clearance, tissue binding and
carrier-mediated transport are represented by empirical algebraic relations
(Michaelis–Menten, constant partition coefficients) that frequently fail against observed
data and extrapolate badly. This is a closure problem, structurally identical to turbulence
closure in RANS.

Three capabilities are simultaneously missing from the open-source ecosystem:

1. **A differentiable PBPK layer.** No Julia package provides composable, tested
   transport-network construction with sourced reference physiology. What exists
   (`bioPBPK`, `BayesPBPK-tutorial`) are model collections and tutorials.
2. **GPU-parallel population ensembles with gradients.** Population inversion needs
   $10^3$–$10^4$ structurally identical ODE solves *and their gradients* per optimizer
   iteration. Ideal GPU work, but the ensemble layout, precision policy and
   forward/adjoint mixing are re-engineered from scratch in every project.
3. **Identifiability tooling for hybrid models.** A neural closure can silently absorb
   misspecified physiology; recent work shows some hybrid models are equivalent to plain
   neural ODEs and contribute no mechanistic knowledge at all. Routine tests for this are
   not packaged anywhere.

`PerfusionUDE.jl` addresses all three.

## What it provides

| Layer | Contents |
|---|---|
| **Domain** | PBPK topologies (full and minimal), sourced reference physiology with provenance, allometric scaling, dosing, nondimensionalization |
| **Closure** | Declarative structural constraints on neural terms: nonnegativity, $R(0)=0$, paired ± mass transfer, residual form with exact mechanistic initialisation |
| **Inference** | Joint-MAP estimator, GPU population ensembles, mixed forward/adjoint gradients, BLQ (M3) likelihood; interop with NoLimits.jl / Pumas backends |
| **Analysis** | Empirical support density, profile likelihood, Fisher information, $\eta$-shrinkage, ablation test, **mechanistic-content test**, symbolic recovery with refit verification, recoverability phase diagrams, VPC |

## Not in scope

Non-compartmental analysis, bioequivalence, trial simulation, NONMEM translation, GUI
modelling, or a general NLME estimation engine. For general NLME in Julia see
[NoLimits.jl](https://github.com/manuhuth/NoLimits.jl) or Pumas; for GUI-based PBPK see
PK-Sim/MoBi; for R workflows see nlmixr2, mrgsolve, rxode2.

## Installation

```julia
using Pkg
Pkg.add(url = "https://github.com/lorendw7/PerfusionUDE.jl")
```

CPU-only by default. GPU support loads through a package extension:

```julia
Pkg.add(["CUDA", "DiffEqGPU"])
```

## Documentation

Full documentation: **https://lorendw7.github.io/PerfusionUDE.jl**

The design and methodology documents are the specification for the whole project, written
in English with bilingual (EN/中文) teaching annotations:

| # | Document | Topic |
|---|---|---|
| 00 | [Glossary](docs/src/design/00-glossary.md) | Bilingual terminology; PK ↔ CFD dictionary |
| 01 | [Background](docs/src/design/01-background.md) | PBPK as a transport network; why empirical closures fail |
| 02 | [PBPK forward model](docs/src/design/02-pbpk-forward-model.md) | Governing equations, states, parameters, numerics |
| 03 | [UDE formulation](docs/src/design/03-ude-formulation.md) | Where the network goes and the constraints it must respect |
| 04 | [Population inverse problem](docs/src/design/04-population-inverse-problem.md) | Hierarchical model, objective, estimation strategies |
| 05 | [GPU strategy](docs/src/design/05-gpu-strategy.md) | Ensemble layouts, differentiation modes, precision, hazards |
| 06 | [Identifiability](docs/src/design/06-identifiability.md) | The central scientific risk and how to control it |
| 07 | [Validation protocol](docs/src/design/07-validation-protocol.md) | Synthetic twin study, baselines, metrics, real data |
| 08 | [CFD correspondence](docs/src/design/08-cfd-correspondence.md) | Formal mapping to closure modelling, adjoints, UQ, ROM |
| 09 | [Implementation roadmap](docs/src/design/09-implementation-roadmap.md) | Phases, gates, risk register, interface contracts |
| 10 | [References](docs/src/design/10-references.md) | Literature, software, public data sources |
| 11 | [Literature landscape](docs/src/design/11-literature-landscape.md) | 2026 competitive analysis and plan amendments |
| 12 | [Package design](docs/src/design/12-package-design.md) | Module layout, API, test strategy, JOSS checklist |
| 13 | [Publication strategy](docs/src/design/13-publication-strategy.md) | JOSS + PLOS Comp Biol targeting and timeline |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and the [Code of Conduct](CODE_OF_CONDUCT.md).
Bug reports, physiological reference data with provenance, and correctness issues are all
welcome. Correctness issues (wrong gradients, broken conservation, biased estimates) are
treated as highest priority.

## Citing

See [CITATION.cff](CITATION.cff).

## License

[MIT](LICENSE).
