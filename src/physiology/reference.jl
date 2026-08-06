# Reference physiology: the anatomical values a PBPK model is built on.
#
# Every number here carries a `source` string.  That is not decoration — it is the
# answer to "where did your hepatic blood flow come from?", which is the first
# question a reviewer asks.  See docs/src/design/02-pbpk-forward-model.md §2.7.

"""
    OrganReference

Reference physiology for one organ of a [`ReferenceIndividual`](@ref).

# Fields
- `name::Symbol` — organ identifier, e.g. `:liver`.
- `V::Float64` — tissue volume, litres.
- `q::Float64` — blood flow as a **fraction of cardiac output**, dimensionless.
  Stored as a fraction rather than L/h so that allometric scaling only has to
  rescale `Q_CO`; see `physiology/allometry.jl`.
- `drains_into::Symbol` — where the venous outflow goes: `:venous` for the systemic
  venous pool, `:liver` for the organs draining through the portal vein.
- `source::String` — provenance of `V` and `q`.

Blood flow in L/h is not stored; obtain it with [`blood_flow`](@ref), which
multiplies `q` by the individual's cardiac output.
"""
struct OrganReference
    name::Symbol
    V::Float64
    q::Float64
    drains_into::Symbol
    source::String
end

"""
    ReferenceIndividual

A complete set of reference physiological values for one individual.

Perfused tissues are held in `tissues`, whose flow fractions must sum to one —
that is the 0-D form of a mesh-continuity check, and it is asserted by
[`flow_continuity_residual`](@ref). The lung is stored separately because it sits
*in series* with the systemic circulation (it receives the whole cardiac output,
so `q == 1`), and the two blood pools are stored separately because they are
mixing volumes with no perfusion of their own.

Construct with [`reference_individual`](@ref).
"""
struct ReferenceIndividual
    label::Symbol
    BW::Float64            # body weight, kg
    Q_CO::Float64          # cardiac output, L/h
    tissues::Vector{OrganReference}
    lung::OrganReference
    venous::OrganReference
    arterial::OrganReference
    source::String
end

# ─────────────────────────────────────────────────────────────────────────────
# Data
#
# ⚠️  PROVENANCE WARNING — read before using these values in a publication.
#
# The numbers below are the illustrative table from
# docs/src/design/02-pbpk-forward-model.md §2.7.  That document states plainly
# that they are order-of-magnitude only and MUST be checked against the primary
# literature (ICRP Publication 89; Brown et al., *Physiological parameter values
# for PBPK models*, Toxicology and Industrial Health 13(4), 1997) before any
# result is reported.
#
# That verification has NOT been done.  Until it is, every `source` string below
# says so, and no citation is claimed that has not been checked.  Replacing these
# strings with real page/table references is a prerequisite for Phase 0 exit.
# ─────────────────────────────────────────────────────────────────────────────

const _ILLUSTRATIVE = "docs/src/design/02-pbpk-forward-model.md §2.7 — ILLUSTRATIVE, \
not yet verified against ICRP 89 / Brown et al. (1997)"

# `rest` closes both balances: its q is 1 − Σq over the named tissues, and its V is
# BW − ΣV over everything else (taking tissue density as 1 kg/L).  Both are written
# out as literals rather than computed, so that flow_continuity_residual actually
# has something to catch if one of the other rows is edited.
const _REST_NOTE = "residual compartment: q and V chosen to close the flow and mass \
balances of the §2.7 table"

function _human_adult_male_70kg()
    tissues = [
        #                 name       V (L)    q (–)   drains_into  source
        OrganReference(:adipose,     14.3,    0.05,   :venous,     _ILLUSTRATIVE),
        OrganReference(:muscle,      29.0,    0.17,   :venous,     _ILLUSTRATIVE),
        OrganReference(:skin,         3.4,    0.05,   :venous,     _ILLUSTRATIVE),
        OrganReference(:bone,        10.5,    0.05,   :venous,     _ILLUSTRATIVE),
        OrganReference(:brain,        1.45,   0.12,   :venous,     _ILLUSTRATIVE),
        OrganReference(:heart,        0.33,   0.04,   :venous,     _ILLUSTRATIVE),
        OrganReference(:kidney,       0.31,   0.19,   :venous,     _ILLUSTRATIVE),
        # Hepatic artery only; the gut and spleen add their flow on top (portal vein).
        OrganReference(:liver,        1.8,    0.065,  :venous,     _ILLUSTRATIVE),
        OrganReference(:gut,          1.65,   0.19,   :liver,      _ILLUSTRATIVE),
        OrganReference(:spleen,       0.19,   0.03,   :liver,      _ILLUSTRATIVE),
        OrganReference(:rest,         0.97,   0.045,  :venous,     _REST_NOTE),
    ]
    lung     = OrganReference(:lung,     0.5, 1.0, :arterial, _ILLUSTRATIVE)
    venous   = OrganReference(:venous,   3.9, 0.0, :lung,     _ILLUSTRATIVE)
    arterial = OrganReference(:arterial, 1.7, 0.0, :venous,   _ILLUSTRATIVE)

    return ReferenceIndividual(
        :human_adult_male_70kg, 70.0, 390.0,
        tissues, lung, venous, arterial, _ILLUSTRATIVE,
    )
end

"""
    reference_individual(label::Symbol) -> ReferenceIndividual

Return the reference physiology registered under `label`.

Currently available: `:human_adult_male_70kg`.

```jldoctest
julia> ref = reference_individual(:human_adult_male_70kg);

julia> ref.Q_CO
390.0
```
"""
function reference_individual(label::Symbol)
    label === :human_adult_male_70kg && return _human_adult_male_70kg()
    throw(ArgumentError("unknown reference individual $(repr(label)); available: :human_adult_male_70kg"))
end

# ─────────────────────────────────────────────────────────────────────────────
# Accessors
# ─────────────────────────────────────────────────────────────────────────────

"""
    tissue(ref::ReferenceIndividual, name::Symbol) -> OrganReference

Look up a perfused tissue by name. Throws `KeyError` if `name` is not a tissue
(the lung and the two blood pools are reached through the fields of the same name).
"""
function tissue(ref::ReferenceIndividual, name::Symbol)
    for t in ref.tissues
        t.name === name && return t
    end
    throw(KeyError(name))
end

"""
    blood_flow(ref::ReferenceIndividual, name::Symbol) -> Float64

Blood flow perfusing tissue `name`, in L/h: `q * Q_CO`.

Note that for the liver this is the **hepatic artery** contribution only. Total
liver inflow also includes the portal drainage of the gut and spleen — see
[`liver_inflow`](@ref).
"""
blood_flow(ref::ReferenceIndividual, name::Symbol) = tissue(ref, name).q * ref.Q_CO

"""
    liver_inflow(ref::ReferenceIndividual) -> Float64

Total blood flow entering the liver in L/h: hepatic artery plus everything that
drains into it through the portal vein.
"""
function liver_inflow(ref::ReferenceIndividual)
    q = tissue(ref, :liver).q
    for t in ref.tissues
        t.drains_into === :liver && (q += t.q)
    end
    return q * ref.Q_CO
end

"""
    flow_continuity_residual(ref::ReferenceIndividual) -> Float64

`sum(q) - 1` over the perfused tissues.

Blood is a closed loop: everything the heart pumps out must come back, so the
flow fractions have to sum to exactly one. This is the 0-D analogue of a
mesh-continuity check, and a non-zero residual means the reference table is
internally inconsistent — usually a transcription error or a missing compartment.
The lung is excluded because it sits in series and carries the whole output.
"""
flow_continuity_residual(ref::ReferenceIndividual) = sum(t.q for t in ref.tissues) - 1.0

"""
    total_volume(ref::ReferenceIndividual) -> Float64

Sum of all compartment volumes in litres, blood pools and lung included. Taking
tissue density as 1 kg/L this should come out close to the body weight; a large
gap means a compartment is missing or mis-scaled.
"""
function total_volume(ref::ReferenceIndividual)
    V = sum(t.V for t in ref.tissues)
    return V + ref.lung.V + ref.venous.V + ref.arterial.V
end

# ─────────────────────────────────────────────────────────────────────────────
# Display
# ─────────────────────────────────────────────────────────────────────────────

function Base.show(io::IO, o::OrganReference)
    print(io, "OrganReference(", o.name, ", V=", o.V, " L, q=", o.q, ")")
end

function Base.show(io::IO, ::MIME"text/plain", ref::ReferenceIndividual)
    println(io, "ReferenceIndividual ", ref.label)
    println(io, "  BW    = ", ref.BW, " kg")
    println(io, "  Q_CO  = ", ref.Q_CO, " L/h")
    println(io, "  ", length(ref.tissues), " perfused tissues, Σq - 1 = ",
            flow_continuity_residual(ref))
    print(io,   "  total volume = ", round(total_volume(ref); digits = 2), " L")
end
