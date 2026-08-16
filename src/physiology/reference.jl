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
# Data — ICRP Publication 89 reference adult male
#
# Every value below was read from ICRP Publication 89, *Basic Anatomical and
# Physiological Data for Use in Radiological Protection: Reference Values*,
# Annals of the ICRP 32(3–4), 2002.  The tables used are:
#
#   Table 2.8   masses of organs and tissues as a function of age (g)
#   Table 2.9   height, mass and surface area of the total body
#   Table 2.12  volume of blood plasma and red blood cells (ml)
#   Table 2.13  distribution of blood in the vascular system of adult man
#   Table 2.39  cardiac output          (= Section 7.5)
#   Table 2.40  regional blood flow rates in adults  (= Section 7.7.2)
#
# Two arithmetic identities in ICRP 89 were checked and hold exactly; they are
# what makes this table trustworthy rather than merely sourced:
#
#   * the male column of Table 2.40 sums to 100.00% of cardiac output, counting
#     the liver by its *arterial* share only;
#   * Table 2.40's stated liver total, 25.5%, equals hepatic artery 6.5% plus the
#     portal tributaries (stomach and oesophagus 1.0 + small intestine 10 + large
#     intestine 4.0 + pancreas 1.0 + spleen 3.0 = 19.0).
#
# Brown et al., *Physiological parameter values for PBPK models*, Toxicology and
# Industrial Health 13(4):407–484, 1997, is the other source named in the design
# document.  It is paywalled and was NOT obtained, so nothing here is attributed
# to it.  Where secondary literature quotes its human values they differ from
# ICRP 89 (e.g. liver 22.7% vs 25.5%, kidney 17.5% vs 19% of cardiac output), so
# the two sets must not be mixed.  This table is ICRP 89 throughout.
# ─────────────────────────────────────────────────────────────────────────────

const _ICRP89 = "ICRP Publication 89 (2002)"

# Volumes come from masses at an assumed tissue density of 1.00 kg/L, the usual
# PBPK convention.  Blood is the exception: Table 2.12 reports a volume directly.
_icrp_src(v, q) = "V: $_ICRP89 $v; q: $_ICRP89 $q"

# `rest` closes both balances: its q is 1 − Σq over the named tissues, and its V is
# BW − ΣV over everything else (taking tissue density as 1 kg/L).  Both are written
# out as literals rather than computed, so that flow_continuity_residual actually
# has something to catch if one of the other rows is edited.
#
# The residual is not a fudge factor — both halves of it are accounted for.
# q = 7.5% is exactly Table 2.40's bronchial tissue 2.5 + thyroid 1.5 + lymph
# nodes 1.7 + gonads 0.05 + adrenals 0.3 + urinary bladder 0.06 + all other 1.39.
# (Bronchial flow lands here because `lung` is modelled in series carrying the
# whole cardiac output, so it has no systemic nutritive supply of its own.)
# V = 4.51 L covers Table 2.8's small organs and luminal contents (≈1.4 kg) plus
# the 4% of body mass its footnote c leaves unlisted (≈2.9 kg), less the 0.3 L by
# which blood mass exceeds blood volume.
const _REST_NOTE = "residual compartment closing both balances against $_ICRP89 \
Tables 2.8, 2.9 and 2.40; q = 7.5% is that table's bronchial/thyroid/lymph/gonad/\
adrenal/bladder/other remainder, V = 4.51 L its unlisted 4% of body mass plus the \
small organs and luminal contents"

# The gut compartment lumps the portal-drained viscera other than the spleen.
# Both its V and its q are sums over the same set of ICRP rows — walls only, since
# luminal contents are not perfused tissue — which is why liver_inflow reproduces
# Table 2.40's stated 25.5% exactly.
const _GUT_NOTE = "V: $_ICRP89 Table 2.8 walls of oesophagus 40 + stomach 150 + \
small intestine 650 + right colon 150 + left colon 150 + rectosigmoid 70 + \
pancreas 140 = 1350 g (luminal contents excluded); q: Table 2.40 stomach and \
oesophagus 1.0 + small intestine 10 + large intestine 4.0 + pancreas 1.0 = 16.0%"

# Splitting the circulation into two mixing pools is a modelling decision ICRP 89
# does not make for us, so it is recorded as derived rather than quoted.  Table
# 2.13 is partitioned by which side of the lung each region sits on: everything
# between the lung outlet and the tissue inlet is arterial, everything between
# the tissue outlet and the lung inlet is venous.
#   arterial 28.0% = pulmonary veins 5.5 + pulmonary capillaries 2 + left heart 4.5
#                    + aorta and large arteries 6 + small arteries 10
#   venous   72.0% = pulmonary arteries 3 + right heart 4.5 + systemic capillaries 5
#                    + small veins 41.5 + large veins 18
# Tissue compartments carry Table 2.8's *tissue-only* masses, so all blood is in
# the two pools and none is double counted.
const _BLOOD_TOTAL = "total blood volume 5.3 L = $_ICRP89 Table 2.12 red cells \
2300 ml + plasma 3000 ml"

function _icrp89_adult_male()
    tissues = [
        #              name      V (L)  q (–)  drains_into  source
        OrganReference(:adipose, 14.5,  0.05,  :venous,
            _icrp_src("Table 2.8 'Separable adipose tissue, excluding yellow marrow' \
                  14 500 g — the entry without footnote a, i.e. the one that does \
                  not double count yellow marrow against the skeleton",
                 "Table 2.40 'Fat' 5.0%")),
        OrganReference(:muscle,  29.0,  0.17,  :venous,
            _icrp_src("Table 2.8 'Muscle, skeletal' 29 000 g",
                 "Table 2.40 'Skeletal muscle' 17%")),
        OrganReference(:skin,     3.3,  0.05,  :venous,
            _icrp_src("Table 2.8 'Skin' 3300 g, itemised in Table 2.27 as epidermis \
                  120 g + dermis 3180 g",
                 "Table 2.40 'Skin' 5.0%")),
        OrganReference(:bone,    10.5,  0.05,  :venous,
            _icrp_src("Table 2.8 'Total skeleton' 10 500 g = cortical 4400 + trabecular \
                  1100 + active marrow 1170 + inactive marrow 2480 + cartilage \
                  1100 + teeth 50 + miscellaneous 200",
                 "Table 2.40 'Skeleton' 5.0% = red marrow 3.0 + trabecular bone \
                  0.9 + cortical bone 0.6 + other skeleton 0.5")),
        OrganReference(:brain,    1.45, 0.12,  :venous,
            _icrp_src("Table 2.8 'Brain' 1450 g", "Table 2.40 'Brain' 12%")),
        OrganReference(:heart,    0.33, 0.04,  :venous,
            _icrp_src("Table 2.8 'Heart — tissue only' 330 g (not 'with blood' 840 g: \
                  blood is a separate compartment)",
                 "Table 2.40 'Coronary tissue' 4.0%")),
        OrganReference(:kidney,   0.31, 0.19,  :venous,
            _icrp_src("Table 2.8 'Kidneys (2)' 310 g", "Table 2.40 'Kidneys' 19%")),
        # Hepatic artery only; the gut and spleen add their flow on top (portal vein).
        OrganReference(:liver,    1.8,  0.065, :venous,
            _icrp_src("Table 2.8 'Liver' 1800 g",
                 "Table 2.40 'Liver' 6.5% (arterial); the same row's 25.5% (total) \
                  is reproduced by liver_inflow and asserted in the test suite")),
        OrganReference(:gut,      1.35, 0.16,  :liver,  _GUT_NOTE),
        OrganReference(:spleen,   0.15, 0.03,  :liver,
            _icrp_src("Table 2.8 'Spleen' 150 g", "Table 2.40 'Spleen' 3.0%")),
        OrganReference(:rest,     4.51, 0.075, :venous, _REST_NOTE),
    ]
    lung = OrganReference(:lung, 0.5, 1.0, :arterial,
        _icrp_src("Table 2.8 'Lung — tissue only' 500 g (not 'with blood' 1200 g)",
             "in series, so it carries the whole cardiac output by construction; \
              Table 2.40's bronchial nutritive supply of 2.5% is in `rest`"))
    venous = OrganReference(:venous, 3.82, 0.0, :lung,
        "$_BLOOD_TOTAL; venous share 72.0% DERIVED from Table 2.13 as pulmonary \
         arteries 3 + right heart 4.5 + systemic capillaries 5 + small veins 41.5 \
         + large veins 18 — an assignment ICRP 89 does not itself make")
    arterial = OrganReference(:arterial, 1.48, 0.0, :venous,
        "$_BLOOD_TOTAL; arterial share 28.0% DERIVED from Table 2.13 as pulmonary \
         veins 5.5 + pulmonary capillaries 2 + left heart 4.5 + aorta and large \
         arteries 6 + small arteries 10 — an assignment ICRP 89 does not itself make")

    return ReferenceIndividual(
        :icrp89_adult_male, 73.0, 390.0,
        tissues, lung, venous, arterial,
        "$_ICRP89 reference adult male: body mass 73 kg (Table 2.9), cardiac \
         output 6.5 l/min = 390 L/h (Table 2.39, Section 7.5 para 311)",
    )
end

"""
    reference_individual(label::Symbol) -> ReferenceIndividual

Return the reference physiology registered under `label`.

Currently available: `:icrp89_adult_male` — the ICRP Publication 89 reference
adult male, 73 kg, cardiac output 390 L/h.

```jldoctest
julia> ref = reference_individual(:icrp89_adult_male);

julia> ref.BW, ref.Q_CO
(73.0, 390.0)

julia> round(liver_inflow(ref) / ref.Q_CO; digits = 3)   # ICRP 89 Table 2.40: 25.5%
0.255
```
"""
function reference_individual(label::Symbol)
    label === :icrp89_adult_male && return _icrp89_adult_male()
    throw(ArgumentError("unknown reference individual $(repr(label)); available: :icrp89_adult_male"))
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
