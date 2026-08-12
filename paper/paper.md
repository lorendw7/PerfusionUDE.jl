---
title: 'PerfusionUDE.jl: GPU-parallel universal differential equations for population PBPK inverse problems'
tags:
  - Julia
  - pharmacokinetics
  - PBPK
  - scientific machine learning
  - universal differential equations
  - inverse problems
  - GPU computing
  - identifiability
authors:
  # TODO before submission: JOSS requires a real name, and an ORCID is expected.
  # `lorendw7` is a GitHub handle standing in until then.
  - name: lorendw7
    affiliation: 1
affiliations:
  - name: TODO Institution, Country  # "Independent researcher" is acceptable to JOSS
    index: 1
date: TODO
bibliography: paper.bib
---

<!--
  DRAFT. Do not submit until every TODO is resolved and every number in
  "Research impact" is an actually-measured value from a committed benchmark
  script. JOSS reviewers check claims. See docs/src/design/13-publication-strategy.md.
-->

# Summary

Physiologically-based pharmacokinetic (PBPK) models describe how a drug distributes
through the body by dividing it into organ compartments connected by blood flow. The
resulting system is a lumped-parameter transport network: mass is conserved on a directed
graph whose edges carry convective flux. The network structure and its flows are known
from physiology, but the *constitutive* terms — metabolic clearance, tissue binding,
carrier-mediated transport — are represented by empirical algebraic laws that often fail to
reproduce observed concentration–time data and extrapolate poorly beyond their calibration
range.

`PerfusionUDE.jl` lets modellers replace those uncertain terms with small neural networks
embedded directly in the ODE right-hand side — the universal differential equation (UDE)
formulation [@rackauckas2020universal] — while keeping conservation of mass and the
perfusion topology exact. Crucially, the learned closure is estimated *jointly* with
subject-specific physiological parameters across a whole population of individuals. That
inverse problem is an ensemble of structurally identical, parametrically distinct ODE
systems, which the package integrates on GPU via `DiffEqGPU.jl` [@utkarsh2024automated]
and differentiates end-to-end with `SciMLSensitivity.jl`.

The package also ships the diagnostics needed to decide whether a learned closure means
anything: empirical-support tracking, profile likelihood, Fisher information, $\eta$-shrinkage,
a network-ablation test, symbolic recovery with refit verification, and a
*mechanistic-content test* that checks whether the hybrid model is observationally
distinguishable from an unconstrained neural ODE.

# Statement of need

PBPK modelling and population pharmacokinetics are mature fields with mature tooling, but
three capabilities are missing from the open-source ecosystem simultaneously:

1. **A differentiable PBPK layer.** Building a PBPK model in Julia today means writing the
   right-hand side by hand, or lifting it from a model collection. There is no package
   providing composable, tested transport-network construction with sourced reference
   physiology.
2. **GPU-parallel population ensembles with gradients.** Population inverse problems
   require integrating and differentiating $10^3$–$10^4$ structurally identical ODE systems
   per optimizer iteration. This is an ideal GPU workload, but wiring it up correctly —
   ensemble layout, precision policy, mixed forward/adjoint differentiation — is
   substantial engineering that is currently re-done per project.
3. **Identifiability tooling for hybrid models.** A neural closure is a universal
   approximator and can silently absorb misspecified physiology. Recent work distinguishes
   *parametric* from *functional* identifiability for UDEs and shows that some hybrid
   models are equivalent to fully data-driven neural ODEs, contributing no mechanistic
   knowledge [@loman2025functional]. Practitioners need routine tests for this; none are
   packaged.

`PerfusionUDE.jl` targets pharmacometricians and systems-pharmacology modellers who want to
learn missing mechanism from population data without discarding physiology, and
methodologists studying inverse problems on lumped-parameter transport networks — a class
that also includes 0D hemodynamic models and reactor networks.

# State of the field

Population PK and PBPK modelling are served by NONMEM, Monolix, PK-Sim/MoBi and the
commercial `Pumas.jl` [@rackauckas2020pumas]; open-source options include `nlmixr2`,
`mrgsolve`, `rxode2` and `PKPDsim` in R, and the recent `NoLimits.jl` [@huth2026nolimits]
in Julia. Neural-network-augmented mixed-effects modelling is available commercially
through DeepPumas/DeepNLME, and variational expectation maximization has been demonstrated
for neural NLME models with over 15,000 population parameters [@tarek2026vem]. Hybrid and
deep-learning PBPK approaches are an active area [@losada2024bridging].

None of these expose a composable, differentiable PBPK transport-network layer with
GPU-parallel population ensembles. The Julia PBPK resources that exist — `bioPBPK` and the
`BayesPBPK-tutorial` accompanying @elmokadem2023bayesian — are model collections and
tutorials rather than packages, and PK-Sim is a GUI/XML modelling environment without a
differentiable-programming path. `PerfusionUDE.jl` fills that gap. It deliberately does not
reimplement general nonlinear mixed-effects estimation: it provides a joint-MAP estimator
suited to GPU execution, and interoperates with `NoLimits.jl` where a
marginal-likelihood-correct estimator is required.

Where existing hybrid approaches place the neural network on the covariate-to-parameter map
[@janssen2022deep], `PerfusionUDE.jl` places it inside the right-hand side. The two are
complementary: the former learns unknown covariate relationships, the latter can learn an
unknown *mechanism*.

*(State-of-the-field survey conducted TODO-DATE; re-verify before submission.)*

# Software design

The package is layered so that each concern can be tested and replaced independently:

- **Domain layer.** `PBPKTopology` encodes the compartment graph, including the portal
  vein and the series lung, and asserts flow continuity at construction.
  `ReferenceIndividual` stores physiological values with a provenance string for every
  number. Nondimensionalization is applied before any GPU execution, which is what makes
  `Float32` viable across the several decades of concentration a PK trajectory spans.
- **Closure layer.** Structural constraints are declarative rather than user-written:
  requesting `(:nonnegative, :zero_at_origin, :residual)` composes a `softplus` output
  transform, a multiplicative concentration factor enforcing $R(0)=0$, and a
  zero-initialised residual parameterisation that recovers the mechanistic model exactly at
  initialisation. Paired transfer terms are computed once and applied twice with opposite
  sign, so mass conservation is structural rather than learned.
- **Inference layer.** The default ensemble layout batches all individuals into a single
  vectorized system, which keeps reverse-mode adjoints available at the cost of a shared
  adaptive step size; a kernel-per-trajectory layout is available for forward solves. The
  design exploits an asymmetry specific to this problem: per-individual random effects are
  few (3–6) while the shared closure weights are many ($10^2$–$10^3$), motivating forward
  sensitivities for the former and adjoints for the latter.
- **Analysis layer.** Every closure plot is accompanied by the empirical support density,
  so extrapolation beyond the sampled concentration range is visible rather than implied.

Optional heavy dependencies (CUDA, `DiffEqGPU`, `SymbolicRegression`,
`StructuralIdentifiability`) are loaded through package extensions; the base package
installs and passes its full test suite on a CPU-only machine.

The test suite asserts conservation laws and closure constraints as first-class tests
alongside a finite-difference check of all gradients, rather than only comparing numerical
outputs.

# Research impact

<!-- TODO: replace every number below with a measured value from a committed script. -->

- TODO: measured speedup and breakeven population size, GPU versus multithreaded CPU, with
  hardware and software versions stated.
- TODO: recoverability result — the population size, sampling density and noise level at
  which a known hidden clearance mechanism is recovered in a synthetic-twin study.
- TODO: real-data case study and comparison against a published NLME analysis.
- TODO: any external adoption.

Reproduction scripts for all reported numbers are in `experiments/`.

# AI usage disclosure

Generative AI (Claude, Anthropic) was used to draft and edit portions of the project's
design documentation and to assist with literature search. All software implementation,
experimental design decisions, numerical results and scientific claims are the authors'
own; all AI-assisted text was reviewed and revised by the authors, and all cited references
were verified against their primary sources.

<!-- TODO: keep the final clause only if the reference verification has actually been
     completed. See docs/src/design/13-publication-strategy.md §13.5. -->

# Acknowledgements

TODO.

# References
