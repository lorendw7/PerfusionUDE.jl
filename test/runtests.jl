using PerfusionUDE
using Test

# ─────────────────────────────────────────────────────────────────────────────
# SCAFFOLD ONLY — test tiers per docs/src/design/12-package-design.md §12.4.
#
# Tier ordering is deliberate: physics and gradient correctness are checked
# before any statistical behaviour, because a failure there invalidates
# everything downstream.
#
# GPU tests are opt-in: CI runners have no CUDA device.
#   PERFUSIONUDE_TEST_GPU=1 julia --project=. -e 'using Pkg; Pkg.test()'
# ─────────────────────────────────────────────────────────────────────────────

const TEST_GPU = get(ENV, "PERFUSIONUDE_TEST_GPU", "0") == "1"

@testset "PerfusionUDE.jl" begin
    @testset "Unit" begin
        # include("unit/topology.jl")       # Σqᵢ = 1; graph well-formedness
        # include("unit/allometry.jl")      # BW scaling, covariate maps
        # include("unit/nondim.jl")         # round-trip identity
        # include("unit/observables.jl")    # plasma vs blood, R_b
        @test true  # placeholder
    end

    @testset "Physics" begin
        # include("physics/conservation.jl")   # mass conserved with elimination off
        # include("physics/steady_state.jl")   # C_ss = R₀ / CL under infusion
        # include("physics/nonnegativity.jl")
        # include("physics/closure_constraints.jl")  # R(0)=0, R≥0, paired ± sums to 0
        @test true
    end

    @testset "Gradient" begin
        # include("gradient/finite_difference.jl")   # AD vs central differences, N=4
        @test true
    end

    @testset "Numerical" begin
        # include("numerical/precision.jl")   # Float32 vs Float64 agreement
        @test true
    end

    @testset "Statistical" begin
        # include("statistical/twin_recovery.jl")   # fixed seed, generous tolerance
        @test true
    end

    if TEST_GPU
        @testset "GPU" begin
            # include("gpu/layout_agreement.jl")   # Layout A/B vs CPU reference
            @test true
        end
    else
        @info "Skipping GPU tests. Set PERFUSIONUDE_TEST_GPU=1 to enable."
    end
end
