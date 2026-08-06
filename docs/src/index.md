# PerfusionUDE.jl

*GPU-parallel universal differential equations for population PBPK inverse problems.*

!!! warning "Pre-release"
    This package is under active development. The API is not yet stable and the
    implementation is incomplete. The design documentation below is complete and is the
    authoritative specification of what is being built.

## What it does

Physiologically-based pharmacokinetic (PBPK) models split the body into organ compartments
coupled by blood perfusion — a lumped-parameter transport network. The network structure is
trustworthy; the constitutive laws inside it (metabolic clearance, tissue uptake) usually
are not.

`PerfusionUDE.jl` lets you:

1. **Build** a PBPK transport network from sourced reference physiology, with conservation
   and flow continuity checked at construction.
2. **Replace** an uncertain mechanism with a structurally-constrained neural closure inside
   the ODE right-hand side — nonnegative, zero at zero concentration, mass-conserving, and
   initialised to reproduce the mechanistic model exactly.
3. **Fit** that closure jointly with per-individual physiological parameters across a
   population of thousands of subjects, with the ensemble integrated and differentiated on
   GPU.
4. **Interrogate** the result: is the closure actually identifiable from these data? Where
   in concentration space is it supported? Does the mechanistic skeleton contribute
   anything, or is this a disguised neural ODE?

Step 4 is the part most hybrid-modelling workflows omit, and it is where most of this
package's distinctive functionality lives.

## Installation

```julia
using Pkg
Pkg.add(url = "https://github.com/lorendw7/PerfusionUDE.jl")
```

The base package is CPU-only and has no GPU dependency. To enable GPU ensembles:

```julia
Pkg.add(["CUDA", "DiffEqGPU"])
```

Symbolic recovery and structural identifiability analysis similarly load on demand:

```julia
Pkg.add(["SymbolicRegression", "StructuralIdentifiability"])
```

## Quick example

!!! note
    Not yet runnable — this is the target API. See
    [Design & methodology](design/12-package-design.md) for the full sketch.

```julia
using PerfusionUDE

model = PBPKModel(PBPKTopology(:minimal5), ReferenceIndividual(:human_adult_male))

closure = NeuralClosure(:hepatic_clearance;
                        inputs      = (:log_Cu_liver,),
                        constraints = (:nonnegative, :zero_at_origin, :residual),
                        arch        = (16, 16))

ude  = attach(model, closure)
data = PopulationData(observations; loq = 0.5, error_model = :combined)
fit  = fit(ude, data, JointMAP())

mechanistic_content_test(fit)      # is this actually a hybrid model?
recover_symbolic(fit; verify_by_refit = true)
```

## Where to go next

- **New to the package?** Start with the tutorials.
- **Want to know why it is built this way?** The
  [Design & methodology](design/00-glossary.md) section is a complete research and
  engineering specification, from the governing equations through to the publication plan.
- **Coming from CFD?** Read [the CFD correspondence](design/08-cfd-correspondence.md)
  first; PBPK is a 0D transport network and the closure problem is the turbulence-closure
  problem in different clothes.
- **Coming from pharmacometrics?** Read
  [the population inverse problem](design/04-population-inverse-problem.md) and
  [identifiability](design/06-identifiability.md).

## Scope

**In scope:** 0D perfusion- and permeability-limited PBPK networks; neural closure of
elimination and distribution terms; joint population inversion; GPU ensembles;
identifiability and recoverability analysis.

**Not in scope:** non-compartmental analysis, bioequivalence, clinical-trial simulation,
NONMEM control-stream translation, GUI modelling, or a general nonlinear mixed-effects
estimation engine. For general NLME in Julia see
[NoLimits.jl](https://github.com/manuhuth/NoLimits.jl) or Pumas; for GUI-based PBPK see
PK-Sim/MoBi; for R workflows see nlmixr2, mrgsolve and rxode2. `PerfusionUDE.jl`
interoperates with NoLimits.jl rather than duplicating it.

## Citing

See [`CITATION.cff`](https://github.com/lorendw7/PerfusionUDE.jl/blob/main/CITATION.cff).

## License

MIT.
