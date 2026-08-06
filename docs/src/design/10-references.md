# 10 — References & Data Sources

> ⚠️ **Verify every citation before use.** The entries below are pointers by
> author/topic/venue to guide literature search. Volume, page, and year details must be
> confirmed against the original source before appearing in a thesis or paper. Do not
> copy this list into a bibliography unchecked.

> **中文讲解｜CN**
> ⚠️ **本文件是"文献检索线索表"，不是可以直接引用的参考文献列表。**
>
> 下面每一条都需要你自己去 Google Scholar / PubMed / 期刊官网核对作者、年份、卷期页。
> 不要直接复制到论文的参考文献里——引用错误在开题和送审时是很扣分的低级失误，
> 而且一旦被发现，会让人怀疑你其他部分的严谨性。
>
> 建议做法：建一个 Zotero/JabRef 库，每读一篇就录入一条**经过核对的** BibTeX，
> 而不是最后统一补。

---

## 0. Confirmed during the 2026-08-06 sweep

These four were verified (title, authors, venue) and are safe to cite once you have read
them. The machine-readable forms live in [`paper/paper.bib`](../../../paper/paper.bib),
where every entry carries a `[V]`/`[U]` marker. See
[11-literature-landscape.md](11-literature-landscape.md) for what each one means for the
plan.

- **Utkarsh, Churavy, Ma, Besard, Srisuma, Gymnich, Gerlach, Edelman, Barbastathis,
  Braatz, Rackauckas (2024).** *Automated translation and accelerated solving of
  differential equations on multiple GPU platforms.* Computer Methods in Applied Mechanics
  and Engineering **419**:116591. arXiv:2304.06835. — the `DiffEqGPU.jl` paper.
- **Loman & Baker (2025).** *Functional and parametric identifiability for universal
  differential equations applied to chemical reaction networks.* arXiv:2510.14140.
- **Tarek & Afonso (2026).** *Fitting Large Nonlinear Mixed Effects Models Using
  Variational Expectation Maximization.* arXiv:2604.26160.
- **Huth, Arruda, Schmid, Gusinow, Wieland, Peiter, Hasenauer (2026).** *NoLimits.jl:
  Flexible and Composable Nonlinear Mixed-Effects Modeling in Julia.* arXiv:2606.24427.

Venue and DOI confirmed, author lists still to complete:
- **Elmokadem et al. (2023).** *Bayesian PBPK modeling using R/Stan/Torsten and
  Julia/SciML/Turing.jl.* CPT:PSP, doi:10.1002/psp4.12926.
- **Losada et al. (2024).** *Bridging pharmacology and neural networks: A deep dive into
  neural ordinary differential equations.* CPT:PSP, doi:10.1002/psp4.13149.

> **中文讲解｜CN**
> 这四条是本次检索中**确认过标题、作者、出处**的，可以放心引用（读完之后）。
> 其余各节仍然只是检索线索。
>
> 机读版本在 [`paper/paper.bib`](../../../paper/paper.bib)，每条都带 `[V]`/`[U]` 标记，
> **投稿前必须把所有 `[U]` 清干净**。

---

## 1. Universal Differential Equations & SciML

| Topic | Where to look |
|---|---|
| The UDE framework | Rackauckas et al., *Universal Differential Equations for Scientific Machine Learning* (arXiv preprint; widely cited) |
| Neural ODEs | Chen, Rubanova, Bettencourt, Duvenaud, *Neural Ordinary Differential Equations*, NeurIPS 2018 |
| Adjoint sensitivity for ODEs, method comparison | `SciMLSensitivity.jl` documentation; Rackauckas et al. on `DiffEqFlux` |
| GPU ensemble ODE solving | Utkarsh, Rackauckas et al., on `DiffEqGPU.jl` — kernel-based ODE solvers for massively parallel trajectory ensembles |
| Symbolic recovery from learned terms | Cranmer et al. on symbolic regression for physics; `SymbolicRegression.jl` / PySR documentation |
| Structural identifiability by differential algebra | Hong, Ovchinnikov, Pogudin, Yap — `StructuralIdentifiability.jl` and the SIAN method |
| Multiple shooting for ODE fitting | Bock & Plitt (classical); modern treatments in the SciML training literature |

## 2. Neural networks in pharmacometrics

| Topic | Where to look |
|---|---|
| Neural-network-augmented NLME | Pumas-AI **DeepPumas** technical material and associated publications — **the closest prior art; read this carefully and position against it explicitly** |
| Scientific ML in pharmacometrics (reviews) | *CPT: Pharmacometrics & Systems Pharmacology* (CPT:PSP) and *Journal of Pharmacokinetics and Pharmacodynamics* (JPKPD) have recent review articles |
| Neural-ODE PK models | Search "neural ODE pharmacokinetics" in CPT:PSP / JPKPD, 2021– |

> **中文讲解｜CN**
> **DeepPumas 这一条必须认真读，它是最接近的前人工作。**
> 开题时如果被问到"Pumas 已经做了神经网络+NLME，你还做什么"，
> 你需要能具体说出差异（见 [01 §1.6](01-background.md)）：
> GPU 上的大规模联合梯度反演、可恢复性的定量刻画、与 CFD 方法论的桥接。
> **不能只说"他们是商业产品我是开源"——那不是学术贡献。**

## 3. PBPK modelling

| Topic | Where to look |
|---|---|
| PBPK textbook treatment | Jones & Rowland-Yeo, *Basic Concepts in PBPK Modeling* (CPT:PSP tutorial series) |
| Reference physiological parameters | ICRP Publication 89 (reference anatomical/physiological values); Brown et al., *Physiological parameter values for PBPK models*, Toxicology and Industrial Health, 1997 |
| Tissue partition coefficient prediction | Rodgers & Rowland; Poulin & Theil — mechanistic $K_p$ prediction methods |
| Minimal / lumped PBPK | Cao & Jusko on minimal PBPK (mPBPK) models |
| Permeability- vs perfusion-limited models | Standard PBPK texts; also the Krogh cylinder and axial-dispersion literature for the underlying PDE reduction |
| Open-source PBPK models and software | **Open Systems Pharmacology (OSP)** suite — PK-Sim/MoBi, open source, with a public repository of qualified published models |

## 4. Population PK / NLME methodology

| Topic | Where to look |
|---|---|
| NLME estimation methods (FO, FOCE, Laplace) | Wang, *Derivation of various NONMEM estimation methods*, JPKPD, 2007 |
| SAEM | Kuhn & Lavielle; Monolix methodological documentation |
| BLQ handling (M1–M7 methods) | Beal, *Ways to fit a PK model with some data below the quantification limit*, JPKPD, 2001 |
| Shrinkage diagnostics | Savic & Karlsson on $\eta$-shrinkage and $\epsilon$-shrinkage |
| Prediction-corrected VPC | Bergstrand et al. on pcVPC |
| Open-source NLME software | `nlmixr2` (R), NONMEM (commercial), Monolix (commercial), `Pumas.jl` (commercial) |

## 5. CFD-side methodology (for the framing)

| Topic | Where to look |
|---|---|
| Field inversion and machine learning for turbulence closure | Duraisamy, Iaccarino, Xiao, *Turbulence Modeling in the Age of Data*, Annual Review of Fluid Mechanics, 2019 |
| Data-driven Reynolds-stress closure with invariance constraints | Ling, Kurzawski, Templeton (tensor-basis neural network) |
| Unsteady adjoint & checkpointing | Griewank & Walther on `revolve` / optimal checkpointing |
| Long-horizon / chaotic sensitivity | Wang, Hu, Blonigan on least-squares shadowing |
| 0D–3D coupled hemodynamics, Windkessel boundary conditions | Vignon-Clementel, Figueroa, Taylor et al. on outflow boundary conditions for 3D blood flow |
| Data assimilation, 4D-Var, background error covariance | Standard DA texts (e.g. Asch, Bocquet & Nodet) |
| Model-order reduction | Benner, Gugercin, Willcox survey on projection-based model reduction |

> **中文讲解｜CN**
> 第 5 节是**用来支撑 [08-cfd-correspondence.md](08-cfd-correspondence.md) 的论证**，
> 在开题报告里同样重要——它证明你不是在牵强类比，而是在两个都有成熟文献的领域之间建立联系。
>
> 其中 Duraisamy 等人的年鉴综述（*Turbulence Modeling in the Age of Data*）
> 特别值得精读：它系统梳理了"数据驱动闭合"的方法论、约束设计和有效性边界，
> 这些内容几乎可以逐条映射到本项目上（见 [08 §8.2](08-cfd-correspondence.md) 的表格）。

---

## 6. Public data sources — **verify availability and license before committing**

| Source | Content | Caveats |
|---|---|---|
| **PK-DB** (`pk-db.com`) | Curated open pharmacokinetics database with individual-level data where available | Check per-study whether individual (not just aggregate) data are present |
| **Open Systems Pharmacology** GitHub organization | Qualified published PBPK models (PK-Sim/MoBi project files), often with the digitized data used to build them | Model files are the main asset; raw individual data availability varies |
| `nlmixr2data` / `PKPDdatasets` (R packages) | Warfarin, theophylline, and other classic teaching datasets | Small, mostly single-dose, mostly linear PK — **plumbing tests only** |
| NONMEM / Monolix example datasets | Standard benchmark datasets | Licensing depends on the software distribution |
| Project Data Sphere | De-identified oncology clinical trial data | Requires registration and data-use agreement; long lead time |
| Digitized literature profiles | Mean concentration–time curves extracted from figures | **Aggregate only** — cannot support individual-level random effects; usable only for structural-model checks |

**Dataset selection criteria** are in [07 §7.8](07-validation-protocol.md). The binding
requirements are: multiple dose levels, documented nonlinearity, $N \ge 50$ with
individual-level records, and a published NLME analysis to compare against.

> **中文讲解｜CN**
> 表格最后一行是一个常见陷阱，务必注意：
>
> **从文献图里数字化提取的浓度-时间曲线通常是"平均曲线"，不是个体数据。**
> 平均曲线**无法**用来估计个体间变异 $\boldsymbol{\Omega}$，也无法做群体反问题——
> 因为非线性模型的"平均个体的响应" ≠ "个体响应的平均"。
> 这类数据只能用于检查结构模型是否合理，不能作为本项目的主数据源。
>
> **行动建议：在 Phase 1 期间（不是 Phase 4）就把 PK-DB 和 OSP 仓库过一遍，
> 确认至少有一个满足 [07 §7.8](07-validation-protocol.md) 全部四条硬性标准的数据集。**
> 如果找不到，就要及早调整方案——比如转向动物组织数据，或把研究重心
> 完全放在孪生实验的相图上（这依然是一个完整的方法学工作）。

---

## 7. Software

| Package | Role | Note |
|---|---|---|
| `OrdinaryDiffEq.jl` | ODE solvers | — |
| `DiffEqGPU.jl` | GPU ensembles (Layouts A and B) | Layout A requires kernel-compatible RHS |
| `CUDA.jl` | GPU arrays and kernels | — |
| `Lux.jl` | Neural networks | Explicit parameters; preferred over implicit-parameter frameworks for SciML/GPU |
| `ComponentArrays.jl` | Named flat parameter vectors | Essential for the joint $(\boldsymbol{\phi}, \mathbf{H}, \boldsymbol{\theta}_{\mathrm{pop}})$ vector |
| `SciMLSensitivity.jl` | Adjoint/forward sensitivity, `sensealg` selection | — |
| `Enzyme.jl` | VJPs | Fast but version-fragile; keep a fallback chain |
| `Optimization.jl` (+ `OptimizationOptimisers`, `OptimizationOptimJL`) | Adam, L-BFGS | — |
| `ModelingToolkit.jl` | Symbolic model construction, structural simplification | Optional; useful for generating the RHS and Jacobian |
| `StructuralIdentifiability.jl` | Structural identifiability analysis | Run before choosing $\boldsymbol{\eta}$ |
| `SymbolicRegression.jl` | Recover a formula from the learned closure | — |
| `StaticArrays.jl` | Allocation-free small vectors | Use from Phase 0 |
| `BenchmarkTools.jl` | Timing | Report whether compilation is included |
| `nlmixr2` (R) | Classical NLME baseline (B2) | Cross-language comparison |

---

## 8. Reading order for getting started

1. Jones & Rowland-Yeo PBPK tutorial → understand the forward model.
2. Rackauckas et al. UDE paper → understand the framework.
3. Duraisamy et al. turbulence-data review → understand the closure-modelling framing.
4. `DiffEqGPU.jl` paper + documentation → understand the two ensemble layouts.
5. Wang (2007) on NONMEM estimation methods → understand what FOCE actually does and why
   joint MAP is an approximation.
6. Beal (2001) on BLQ → understand a data pathology that will otherwise bite you.
7. DeepPumas material → know the closest prior art before writing the proposal.

> **中文讲解｜CN**
> 建议的阅读顺序背后的逻辑：
> - 1–2 建立"正向模型 + 方法框架"的基础；
> - 3 建立"为什么这个课题和 CFD 是一回事"的论证；
> - 4 建立 GPU 实现的技术判断；
> - 5–6 是**药代动力学领域的专业细节**，不读会在方法上犯内行一眼看穿的错误；
> - 7 是竞品分析，写开题报告之前必须完成。
>
> 其中 5 和 6 最容易被跳过（因为看起来"只是统计细节"），但恰恰是这两条决定了
> 你的工作在药代动力学审稿人眼里是"专业的"还是"外行做的"。

---

**Next:** [11 — Literature Landscape](11-literature-landscape.md) ·
**Back to:** [index](../index.md)
