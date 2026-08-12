using Documenter
using PerfusionUDE

DocMeta.setdocmeta!(PerfusionUDE, :DocTestSetup, :(using PerfusionUDE); recursive = true)

makedocs(;
    modules = [PerfusionUDE],
    sitename = "PerfusionUDE.jl",
    authors = "lorendw7",
    format = Documenter.HTML(;
        canonical = "https://lorendw7.github.io/PerfusionUDE.jl",
        mathengine = Documenter.KaTeX(),
        assets = String[],
    ),
    # Documenter errors out if `pages` names a file that does not exist, and
    # `warnonly` does not cover it — the nav tree is built before those checks
    # run.  So a page joins this list only once its file is written.
    pages = [
        "Home" => "index.md",
        # "Tutorials" => [
        #     "tutorials/01-first-pbpk.md",
        #     "tutorials/02-virtual-population.md",
        #     "tutorials/03-fit-a-closure.md",
        #     "tutorials/04-gpu-scaling.md",
        # ],
        # "How-to guides" => [
        #     "howto/custom-topology.md",
        #     "howto/identifiability-workflow.md",
        #     "howto/interop-nolimits.md",
        # ],
        "Design & methodology" => [
            "design/00-glossary.md",
            "design/01-background.md",
            "design/02-pbpk-forward-model.md",
            "design/03-ude-formulation.md",
            "design/04-population-inverse-problem.md",
            "design/05-gpu-strategy.md",
            "design/06-identifiability.md",
            "design/07-validation-protocol.md",
            "design/08-cfd-correspondence.md",
            "design/09-implementation-roadmap.md",
            "design/10-references.md",
            "design/11-literature-landscape.md",
            "design/12-package-design.md",
            "design/13-publication-strategy.md",
        ],
        # "API reference" => "api.md",
    ],
    # Flip to `false` once the docstrings are written, so that missing
    # cross-references and undocumented exports fail the build.
    warnonly = true,
)

deploydocs(; repo = "github.com/lorendw7/PerfusionUDE.jl", devbranch = "main")
