# PerfusionUDE.jl

[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://lorendw7.github.io/PerfusionUDE.jl/dev)
[![CI](https://github.com/lorendw7/PerfusionUDE.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/lorendw7/PerfusionUDE.jl/actions/workflows/CI.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**GPU-parallel universal differential equations for population PBPK inverse problems.**

*Data-driven closure of lumped-parameter transport networks, and large-scale parallel
parameter inversion.*

> **Status: pre-release, not yet usable.** The design documentation is complete and
> authoritative; the implementation has just begun. The reference-physiology layer exists
> and its invariants are tested; **its numerical values are the illustrative table from the
> design docs and have not yet been verified against ICRP 89 / Brown et al. (1997)** — every
> `source` field says so. Nothing else in the API is implemented. See the
> [roadmap](docs/src/design/09-implementation-roadmap.md).

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
   (`bioPBPK`, `BayesPBPK-tutorial`) are model collections and tutorials; the closest
   packaged work — hierarchical deep compartment modelling
   ([Elmokadem et al. 2024](https://doi.org/10.1111/cts.70045)) — attaches the network to
   the covariate → parameter map rather than to the transport equations, and represents no
   organ physiology.
2. **A population-ensemble layer with usable gradients.** Differentiable GPU ODE solving
   already exists ([DiffEqGPU.jl](https://doi.org/10.1016/j.cma.2023.116591); also
   [arXiv:2411.19882](https://arxiv.org/abs/2411.19882), benchmarked on PK compartment
   models). What is re-engineered from scratch in every project is the layer *above* it:
   the ensemble memory layout, the precision policy, and the mixed forward/adjoint gradient
   policy required when $10^3$–$10^4$ individuals share one global closure while each
   carries a handful of private physiological parameters.
3. **Identifiability tooling for hybrid models.** A neural closure can silently absorb
   misspecified physiology; [Loman & Baker (2025)](https://arxiv.org/abs/2510.14140) show
   that some universal differential equations are fitting-equivalent to plain neural ODEs
   and contribute no mechanistic knowledge at all. Routine tests for this are not packaged
   anywhere.

Neural closures inside PK ODEs are not new — see
[Valderrama et al. 2024](https://doi.org/10.1002/psp4.13054) for the nearest published
precedent, and [Janssen et al. 2022](https://doi.org/10.1002/psp4.12808) for the
covariate-map alternative. What `PerfusionUDE.jl` adds is the organ-level transport
network, the population scale, and the identifiability machinery to tell a genuine hybrid
model from a disguised black box.

## What it provides

| Layer | Contents |
|---|---|
| **Domain** | PBPK topologies (full and minimal), reference physiology in which every value carries a mandatory provenance string, allometric scaling, dosing, nondimensionalization |
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

## Contributing and support

See [CONTRIBUTING.md](CONTRIBUTING.md) and the [Code of Conduct](CODE_OF_CONDUCT.md).
Bug reports, physiological reference data with provenance, and correctness issues are all
welcome. Correctness issues (wrong gradients, broken conservation, biased estimates) are
treated as highest priority.

- **Bugs / feature requests:** [Issues](https://github.com/lorendw7/PerfusionUDE.jl/issues)
- **Questions / modelling discussion:** [Discussions](https://github.com/lorendw7/PerfusionUDE.jl/discussions)
- **Maintenance status, response times and governance:**
  [CONTRIBUTING.md § Maintenance and support](CONTRIBUTING.md#maintenance-and-support)
- **What has changed:** [CHANGELOG.md](CHANGELOG.md)

## Citing

See [CITATION.cff](CITATION.cff).

## License

[MIT](LICENSE).
