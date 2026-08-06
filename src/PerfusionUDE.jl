"""
    PerfusionUDE

GPU-parallel universal differential equations for population PBPK inverse problems.

The package is organised in four layers (see `docs/src/design/12-package-design.md`):

  1. **Domain**    — PBPK transport network, reference physiology, allometry, dosing.
  2. **Closure**   — structurally-constrained neural terms inside the ODE right-hand side.
  3. **Inference** — joint-MAP estimator, GPU population ensembles, mixed-mode gradients.
  4. **Analysis**  — identifiability, recoverability, symbolic recovery, diagnostics.

GPU support (`CUDA`, `DiffEqGPU`), symbolic recovery (`SymbolicRegression`) and structural
identifiability (`StructuralIdentifiability`) are optional and load through package
extensions; the base package runs on CPU only.
"""
module PerfusionUDE

# ─────────────────────────────────────────────────────────────────────────────
# SCAFFOLD ONLY.
#
# This file defines the module and the intended include/export structure.
# Implementations are written by the project author — see the interface contract
# in docs/src/design/09-implementation-roadmap.md and the API sketch in
# docs/src/design/12-package-design.md.
#
# Uncomment each include as the corresponding file is written, and add its
# exports below. Keep the layer ordering: physiology → model → closure →
# ensemble → inference → analysis.
# ─────────────────────────────────────────────────────────────────────────────

# --- L1 Domain ---------------------------------------------------------------
# include("physiology/reference.jl")
# include("physiology/allometry.jl")
# include("physiology/populations.jl")
# include("model/topology.jl")
# include("model/nondim.jl")
# include("model/rhs.jl")
# include("model/dosing.jl")
# include("model/observables.jl")

# --- L2 Closure --------------------------------------------------------------
# include("closure/inputs.jl")        # closure_input: the ONLY definition of z
# include("closure/constraints.jl")
# include("closure/networks.jl")

# --- L3 Inference ------------------------------------------------------------
# include("ensemble/batching.jl")
# include("ensemble/layout_b.jl")
# include("inference/objective.jl")
# include("inference/gradients.jl")
# include("inference/schedule.jl")
# include("inference/backends.jl")

# --- L4 Analysis -------------------------------------------------------------
# include("analysis/support.jl")
# include("analysis/identifiability.jl")
# include("analysis/symbolic.jl")
# include("analysis/diagnostics.jl")

# export ReferenceIndividual, PBPKTopology, PBPKModel, VirtualPopulation,
#        DosingRegimen, simulate,
#        NeuralClosure, attach,
#        PopulationData, JointMAP, fit,
#        support_density, profile_likelihood, fisher_information, shrinkage,
#        ablation_test, mechanistic_content_test, recover_symbolic, vpc,
#        recoverability_curve

end # module
