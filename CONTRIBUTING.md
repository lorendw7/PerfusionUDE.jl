# Contributing to PerfusionUDE.jl

Thanks for your interest. This document covers how to report problems, how to propose
changes, and how to run the test suite — including the parts that need a GPU.

## Getting help / reporting a problem

- **Bug reports and feature requests:** open a
  [GitHub issue](https://github.com/lorendw7/PerfusionUDE.jl/issues).
  For bugs, please include the output of `versioninfo()`, your `Project.toml`/`Manifest.toml`
  (or `] status`), and a minimal reproducing script.
- **Questions and modelling discussion:** open a
  [GitHub Discussion](https://github.com/lorendw7/PerfusionUDE.jl/discussions).
- **Suspected incorrect scientific results** (wrong gradients, broken conservation, biased
  estimates): please open an issue labelled `correctness`. These are treated as the highest
  priority.

## Development setup

```bash
git clone https://github.com/lorendw7/PerfusionUDE.jl
cd PerfusionUDE.jl
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.test()'
```

The base package has **no GPU dependency**. CUDA, DiffEqGPU, SymbolicRegression and
StructuralIdentifiability are optional and loaded through package extensions; install them
only if you need those features.

## Running the tests

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

The suite is organised in tiers (see `docs/src/design/12-package-design.md`):

| Tier | Always runs | Notes |
|---|---|---|
| Unit | yes | topology, scaling, nondimensionalization |
| Physics | yes | conservation laws, closure constraints |
| Gradient | yes | finite-difference check against AD |
| Numerical | yes (CPU) | Float32/Float64 agreement |
| Statistical | yes | small twin recovery, fixed seed |
| GPU | **no** | set `PERFUSIONUDE_TEST_GPU=1` on a CUDA machine |

```bash
PERFUSIONUDE_TEST_GPU=1 julia --project=. -e 'using Pkg; Pkg.test()'
```

CI does not have a GPU, so GPU tests must be run manually before merging changes that
touch `src/ensemble/`. Please say in the PR description that you did.

## Pull requests

1. Open an issue first for anything larger than a bug fix, so the design can be discussed
   before you spend time on it.
2. Branch from `main`; keep the PR focused on one change.
3. Add or update tests. **Changes to the model right-hand side must keep the physics-tier
   tests passing, and changes to gradients must keep the finite-difference check passing.**
4. Update the relevant document under `docs/src/` if the change affects behaviour or
   design.
5. Run `julia --project=. -e 'using Pkg; Pkg.test()'` locally before pushing.
6. CI must be green.

## Code conventions

- Follow the [Blue style guide](https://github.com/JuliaDiff/BlueStyle).
- The model right-hand side must remain **allocation-free and `StaticArrays`-based**, so
  it stays compatible with GPU kernel compilation.
- Physical constants and reference physiological values must carry a **provenance string**
  citing their source. Unsourced numbers will not be merged.
- There is exactly one definition of the neural-closure input (`closure_input`). Analysis,
  plotting and the RHS all call it. Do not duplicate it.
- Paired transfer terms are computed once and applied twice with opposite sign, never
  written out twice.

## Adding a physiological dataset or model

Reference physiology contributions are welcome. Please include, for every value: the
source (with a DOI or ISBN), the population it describes, and the units. See
`src/physiology/reference.jl` for the expected format.

## Code of conduct

Participation is governed by the [Code of Conduct](CODE_OF_CONDUCT.md).

## Licensing

By contributing you agree that your contributions are licensed under the MIT License, as
in [LICENSE](LICENSE).
