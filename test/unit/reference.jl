# Reference physiology invariants.
#
# These are cheap to run and catch the single most common failure mode in PBPK
# work: a transcription error in the parameter table. A wrong flow fraction does
# not crash anything — it silently produces a plausible-looking curve.

@testset "reference physiology" begin
    ref = reference_individual(:icrp89_adult_male)

    @testset "lookup" begin
        @test ref.label === :icrp89_adult_male
        @test tissue(ref, :liver).V == 1.8
        # The pancreas is lumped into :gut, not a compartment of its own.
        @test_throws KeyError tissue(ref, :pancreas)
        # The lung and blood pools are fields, not tissues.
        @test_throws KeyError tissue(ref, :lung)
        @test_throws ArgumentError reference_individual(:mouse)
    end

    @testset "agrees with ICRP 89 reference values" begin
        # Whole-body values: Table 2.9 (body mass) and Table 2.39 (cardiac output,
        # 6.5 l/min). These fix the individual the rest of the table describes.
        @test ref.BW == 73.0
        @test ref.Q_CO == 6.5 * 60

        # Organ masses, Table 2.8, adult male column, at 1.00 kg/L.
        for (name, V) in (:adipose => 14.5, :muscle => 29.0, :skin => 3.3,
                          :bone => 10.5, :brain => 1.45, :heart => 0.33,
                          :kidney => 0.31, :liver => 1.8, :spleen => 0.15)
            @test tissue(ref, name).V == V
        end
        @test ref.lung.V == 0.5
        # Table 2.12: red cells 2300 ml + plasma 3000 ml.
        @test ref.venous.V + ref.arterial.V ≈ 5.3

        # Blood flows, Table 2.40, male column.
        for (name, q) in (:adipose => 0.05, :muscle => 0.17, :skin => 0.05,
                          :bone => 0.05, :brain => 0.12, :heart => 0.04,
                          :kidney => 0.19, :liver => 0.065, :spleen => 0.03)
            @test tissue(ref, name).q == q
        end

        # The identity that pins the splanchnic bed down. Table 2.40 states the
        # liver's arterial share (6.5%) and its total (25.5%) independently, so
        # reproducing the total from the model's own portal topology is a real
        # check rather than a restatement. An earlier draft of this table gave the
        # gut the whole 19% portal flow *and* listed the spleen separately, which
        # double counted the spleen and pancreas and put 28.5% of cardiac output
        # through the liver — a 12% overestimate of the one flow that hepatic
        # clearance, and therefore the closure target, is most sensitive to.
        @test liver_inflow(ref) ≈ 0.255 * ref.Q_CO
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
        # Naming the publication is not optional either: a row added later
        # without a citation is exactly the failure this table exists to prevent.
        for o in (ref.tissues..., ref.lung, ref.venous, ref.arterial)
            @test !isempty(o.source)
            @test occursin("ICRP Publication 89", o.source)
        end
        @test occursin("ICRP Publication 89", ref.source)

        # Values ICRP 89 does not itself state must say so rather than hide
        # behind the citation of the table they were derived from.
        for o in (ref.venous, ref.arterial)
            @test occursin("DERIVED", o.source)
        end
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
