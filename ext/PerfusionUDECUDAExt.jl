"""
    PerfusionUDECUDAExt

Loaded automatically when both `CUDA` and `DiffEqGPU` are available. Provides the
GPU population-ensemble layouts described in `docs/src/design/05-gpu-strategy.md`.

SCAFFOLD — implementations pending.
"""
module PerfusionUDECUDAExt

using PerfusionUDE
using CUDA
using DiffEqGPU

# include("../src/ensemble/layout_a.jl")   # EnsembleGPUKernel, forward solves
# GPU methods for the Layout B batched RHS are added here.

end
