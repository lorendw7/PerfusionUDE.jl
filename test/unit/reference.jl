# Reference physiology invariants.
#
# These are cheap to run and catch the single most common failure mode in PBPK
# work: a transcription error in the parameter table. A wrong flow fraction does
# not crash anything — it silently produces a plausible-looking curve.

@testset "reference physiology" begin
    ref = reference_individual(:human_adult_male_70kg)

    @testset "lookup" begin
        @test ref.label === :human_adult_male_70kg
        @test tissue(ref, :liver).V == 1.8
        @test_throws KeyError tissue(ref, :pancreas)
        # The lung and blood pools are fields, not tissues.
        @test_throws KeyError tissue(ref, :lung)
        @test_throws ArgumentError reference_individual(:mouse)
    end

    @testset "flow continuity" begin
        # Σq = 1 over the perfused tissues: blood is a closed loop.
        @test flow_continuity_residual(ref) ≈ 0 atol = 1e-12
        # The lung is in series and carries the whole cardiac output.
        @test ref.lung.q == 1.0
        # Blood pools are mixing volumes, not perfused compartments.
        @test ref.venous.q == 0.0
        @test ref.arterial.q == 0.0
    end

    @testset "mass balance" begin
        # Tissue density ≈ 1 kg/L, so the volumes should account for the body weight.
        @test total_volume(ref) ≈ ref.BW atol = 1e-10
    end

    @testset "physical plausibility" begin
        for t in ref.tissues
            @test t.V > 0
            @test 0 < t.q ≤ 1
            @test t.drains_into in (:venous, :liver)
        end
        @test ref.Q_CO > 0
        @test ref.BW > 0
    end

    @testset "provenance is mandatory" begin
        # Every number must be answerable for. An empty source is a bug, not a
        # style problem — see docs/src/design/02-pbpk-forward-model.md §2.7.
        for t in ref.tissues
            @test !isempty(t.source)
        end
        for o in (ref.lung, ref.venous, ref.arterial)
            @test !isempty(o.source)
        end
        @test !isempty(ref.source)
    end

    @testset "derived flows" begin
        # blood_flow converts the stored fraction back to L/h.
        @test blood_flow(ref, :kidney) ≈ tissue(ref, :kidney).q * ref.Q_CO
        @test sum(blood_flow(ref, t.name) for t in ref.tissues) ≈ ref.Q_CO

        # Liver inflow = hepatic artery + portal drainage, so it must exceed the
        # hepatic-artery term alone and equal the sum of its three contributions.
        portal = [t for t in ref.tissues if t.drains_into === :liver]
        @test !isempty(portal)
        @test liver_inflow(ref) > blood_flow(ref, :liver)
        @test liver_inflow(ref) ≈
              blood_flow(ref, :liver) + sum(blood_flow(ref, t.name) for t in portal)
    end
end
