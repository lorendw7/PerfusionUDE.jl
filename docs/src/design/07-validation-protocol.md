
# 07 — Validation Protocol

Two studies, in strict order. Do not start the second before the first passes its gates.

---

## Part I — The Synthetic Twin Experiment

### 7.1 Purpose

Answer one question with a verifiable ground truth:

> **Under what conditions can the UDE recover a hidden mechanism that the mechanistic
> model does not contain?**

Because we generate the data, we know the true $\{\boldsymbol{\eta}_j\}$, the true
$\boldsymbol{\Omega}$, and — crucially — the true hidden function. Every claim is
checkable.

> **中文讲解｜CN**
> 孪生实验（synthetic twin / digital twin experiment）的价值在于**有绝对真值**。
> 在真实数据上，你永远无法知道"学到的闭合项对不对"——因为没人知道真实机制长什么样。
> 只有在自己造的数据上，才能回答"能不能学回来、需要多少数据才能学回来"。
>
> 这与 CFD 里用 **DNS 数据检验湍流模型**是同一个套路：
> DNS 给出真值 → 用 DNS 数据训练/检验闭合模型 → 再上真实实验数据。
> 跳过孪生实验直接上真实数据，等于跳过 DNS 直接用风洞数据调模型，
> 出了问题你分不清是模型错了、数据错了、还是代码错了。

### 7.2 Ground-truth generator

**Structure.** Full perfusion-limited PBPK from [02](02-pbpk-forward-model.md), 12 tissues
+ 2 blood pools.

**Hidden mechanism.** The generator's hepatic elimination is *not* Michaelis–Menten. Use a
mechanism that a single MM term cannot represent. Candidates, in increasing difficulty:

| ID | Hidden mechanism | Why it is a good test |
|---|---|---|
| H1 | Two parallel MM terms (high-affinity/low-capacity + low-affinity/high-capacity) | Realistic (multiple CYP isoforms); a single MM fit will be systematically wrong at both ends |
| H2 | MM with saturable active hepatic uptake, so intracellular ≠ plasma free concentration | Produces an apparent $K_m$ that shifts with dose — the classic transporter signature |
| H3 | MM plus product inhibition by an unmodelled metabolite | Introduces a hysteresis the closure cannot see with concentration-only input — **an honest negative-result test** |

Run **H1 as the primary case**. H2 as the harder case. H3 deliberately as a case where the
Phase-1 input set is insufficient — reporting a *correctly detected failure* is a strong
scientific result.

**Why a generative virtual population cannot stand in for this generator (added
2026-09-02).** Physics-constrained diffusion models that synthesise "biologically compliant"
virtual patients now exist (arXiv:2602.18472, [11 §11.7.3(c)](11-literature-landscape.md)),
and a reviewer may ask why we do not use one. The answer is what the twin study measures:
$\mathrm{E}_{\mathrm{mech}}$ in §7.5 is an error *against a known hidden mechanism*. A
generative population has no hidden mechanism — it has a learned distribution over
trajectories — so there is nothing to score recovery against, and its "physiological
constraints" are soft penalties on a loss, not the hard flow-continuity and mass
conservation of [02](02-pbpk-forward-model.md). Such a population could serve as an
additional *held-out individuals* test in §7.5, never as the ground truth.

> **中文讲解｜CN**
> H3 的设计意图值得特别说明：**它是故意设计成"当前输入集学不到"的情况。**
>
> 隐藏机制是代谢产物的产物抑制，而 Phase 1 的网络只能看到当前浓度、看不到代谢产物历史，
> 所以它在信息上**不可能**学对（这会表现为迟滞现象：同一浓度下升相和降相的清除率不同）。
>
> 为什么要做一个注定失败的实验？因为**"方法能检测出自己失败了"本身就是重要结果。**
> 如果诊断工具（残差的时间结构、留出个体预测、覆盖度分析）能识别出
> "这里的失配不是噪声，而是缺了一个状态变量"，那说明这套方法是可信的。
> 一个只报告成功案例的方法学论文，说服力远低于同时报告"什么时候会失败、怎么发现失败"的论文。

**Population.** $N \in \{50, 200, 1000, 5000\}$ (sweep this — see §7.4). Sample:
- $\mathrm{BW}_j \sim$ lognormal, median 70 kg, CV 20%
- Organ volumes/flows: allometric from $\mathrm{BW}_j$ + 10% lognormal noise
- $\boldsymbol{\eta}_j \sim \mathcal{N}(0, \boldsymbol{\Omega}_{\mathrm{true}})$ with
  realistic CVs: $\mathrm{CL}$ 40%, $Q_{\mathrm{CO}}$ 15%, $K_p^{\mathrm{scale}}$ 25%
- Genotype covariate on $\mathrm{CL}$ (3 levels) to test covariate handling

**Study design.** Multiple dose levels (essential — see [06 §6.6](06-identifiability.md)):
3 dose groups spanning a 10× range, so the population collectively covers the nonlinear
concentration region.

**Sampling schedule.** Deliberately realistic and sparse:
- Rich: 12 samples/individual (like a Phase-I study)
- Sparse: 4 samples/individual at randomized times (like a Phase-III population study)
- Sweep this too.

**Corruption — all of it, from the start:**
- Combined error: $\sigma_{\mathrm{prop}} = 15\%$, $\sigma_{\mathrm{add}} = $ 5% of LOQ
- **BLQ censoring** at a realistic LOQ (see [04 §4.7](04-population-inverse-problem.md))
- Time-recording errors: ±5 min jitter on nominal sampling times
- 5% of individuals with a missing dose or a recording error (outliers)

> **中文讲解｜CN**
> **最关键的一条纪律：合成数据必须带上真实数据的全部"脏"特征，从第一天就带。**
>
> 常见的失败路径是：先在干净的合成数据上做出漂亮结果 → 兴高采烈上真实数据 → 全面崩溃 →
> 不知道是哪个环节的问题（噪声？BLQ？采样太稀？异常值？），只能一个个试，浪费几个月。
>
> 所以合成数据从一开始就要有：
> - 组合误差（比例 15% + 加性）
> - **BLQ 截断**（终末相数据被截掉，这对清除率估计影响极大）
> - 采样时间抖动（记录的是"名义时间"，实际采血差几分钟）
> - 5% 的异常个体（漏服药、记录错误）
>
> 这样一来，当你在合成数据上取得成功时，这个成功是**可以外推到真实数据的**。

### 7.3 Baselines (all four, mandatory)

| # | Baseline | What it isolates |
|---|---|---|
| B0 | **Oracle**: fit the true structural model, estimate its parameters | Upper bound on achievable accuracy — nothing can beat this |
| B1 | **Misspecified mechanistic**: single-MM PBPK, fitted | The status quo. What does the bias look like? |
| B2 | **Classical NLME**: same misspecified structure, FOCE-I via nlmixr2/Pumas | The tool a PK reviewer would use |
| B3 | **Pure black-box**: neural ODE with no mechanistic structure, same data | Isolates the value of the mechanistic prior |
| B4 | **Deep compartment model**: network on the *covariate → parameter* map, mechanistic ODE untouched | A different hybridization point — isolates the value of putting the network *inside* the RHS |
| — | **UDE (ours)** | |

Report all six on identical data, identical metrics.

**B4 added 2026-08-06.** Deep compartment models (CPT:PSP 2022) are an established hybrid
approach that learns an unknown *covariate relationship* while leaving the dynamics
mechanistic. A reviewer will ask why we instead put the network inside the right-hand side.
The answer — that theirs cannot discover an unknown *mechanism* — is much stronger if it is
demonstrated rather than asserted. Construct the twin data so the hidden mechanism is
genuinely dynamical (H1/H2 already are), and B4 should fail to recover it regardless of how
well it fits.

**B3 now also feeds Test D.** Beyond comparing performance, use the B3 fit for the
mechanistic-content test of [06 §6.0](06-identifiability.md), which since 2026-09-02 has a
pre-registered decision rule: $R = 10$ seeds each, and a pass requires the UDE to beat B3
on the held-out dose by more than $2\sigma_{\mathrm{run}}$ *with* comparable in-sample
fit. B3 must therefore be run with the same seed schedule as the UDE, not once.

**How this set maps onto the published comparisons (checked 2026-09-02).** Valderrama et
al. 2025 (CPT:PSP 14(4), doi:10.1002/psp4.13313) compare SciML against population PK and
classical ML on drug-concentration prediction; our B2 is their PopPK arm and B3 their ML
arm, so the three-way comparison a PK reviewer expects is already present and should be
labelled that way in the results. Two expectations to state *before* the results exist:

- **B0 is the classical estimator on the identifiable problem, and the UDE should
  approach it, not beat it.** Bisht & Agarwal (arXiv:2606.12658) found their PINN only
  matched nonlinear least squares where the problem was identifiable; the same will be
  true here, and it is not a weakness. Report the gap to B0 as the headline number, and
  never describe "close to B0" as a win over classical estimation.
- **The UDE's case rests on B1 and B4, not on B0.** B1 shows what misspecification costs;
  B4 shows that a covariate-map network cannot recover a dynamical mechanism. Those are the
  comparisons the method is for.

> **中文讲解｜CN**
> 新增的 **B4（deep compartment model）** 值得说明为什么重要。
>
> 它代表了另一种混合方式：**网络放在"协变量 → 参数"的映射上，ODE 本身保持机理不变。**
> 这是已发表的成熟做法，审稿人一定会问"你为什么把网络塞进 RHS 而不用这种"。
>
> 答案是"他们只能学未知的协变量关系，学不到未知的机制"——
> 但**说出来远不如做出来有说服力**。把 B4 加进基线，让它在孪生实验里
> 明明白白地恢复不出隐藏机制（即使拟合得不错），这个对比图比一段论证有力得多。
>
> 同时注意 **B3 现在有了双重用途**：既是性能基线，也是
> [06 §6.0](06-identifiability.md) 里 Test D 的对照对象。跑一次，两处用。

> **中文讲解｜CN**
> 四个基线各自回答一个不同的问题，缺一不可：
> - **B0 Oracle（用真实结构拟合）**：性能上界。如果你的 UDE 接近 B0，说明做到了极限；
>   如果差很远，说明还有提升空间。**没有 B0，你的结果就没有标尺。**
> - **B1 误设机理模型**：现状（status quo）。展示"不用 UDE 会错多少"，这是方法的动机。
> - **B2 经典 NLME（FOCE-I）**：药代动力学领域真正在用的工具。
>   PK 背景的审稿人只认这个对比。
> - **B3 纯黑箱 Neural ODE**：隔离出"机理先验值多少钱"。
>   如果 B3 和 UDE 差不多，那你的机理结构就没起作用，整个 UDE 立论受损；
>   预期是 B3 在插值上接近、在**外推**（新剂量、新体重）上远差于 UDE。
>
> **B3 尤其重要**：它是"为什么不直接上深度学习"这个质疑的直接回答。

### 7.4 The parameter sweep (this is the main result)

Vary and report recovery quality as a function of:

```math
N \in \{50, 200, 10^3, 5\times10^3\} \;\times\; n_{\mathrm{obs}/j} \in \{4, 8, 12\} \;\times\; \sigma_{\mathrm{prop}} \in \{5\%, 15\%, 30\%\}
```

The deliverable is a **phase diagram**: regions of $(N, n_{\mathrm{obs}}, \sigma)$ space
where the hidden mechanism is recovered, partially recovered, or not recovered.

> **中文讲解｜CN**
> **这张"相图"是本课题最有价值的产出，建议作为论文的核心图。**
>
> 它回答的是一个之前没人系统回答过的问题：
> > 需要多少个体、每人多少采样点、噪声多大以内，才能把一个隐藏机制学回来？
>
> 输出形式：在 $(N, n_{\mathrm{obs}}, \sigma)$ 空间里画出三个区域——
> **完全恢复 / 部分恢复 / 无法恢复**。
>
> 这类"方法适用边界"的定量刻画，比"我们在某个数据集上比别人好 5%"有价值得多，
> 也更难被后续工作推翻。而且它天然需要跑几百次完整拟合——
> **这本身就构成了 GPU 加速的必要性论证**，两条主线在这里汇合。

### 7.5 Metrics

**Mechanism recovery (the point of the study):**

```math
\mathrm{E}_{\mathrm{mech}} = \left(\frac{\int_{\mathcal{Z}} \big|\widehat{\mathrm{CL}}_{\mathrm{eff}}(z) - \mathrm{CL}^{\mathrm{true}}_{\mathrm{eff}}(z)\big|^2 \rho(z)\,dz}{\int_{\mathcal{Z}} \big|\mathrm{CL}^{\mathrm{true}}_{\mathrm{eff}}(z)\big|^2 \rho(z)\,dz}\right)^{1/2}
```

Weighted by the empirical support density $\rho$ — **never** report an unweighted error over
a range the data never visited.

**Parameter recovery:** bias and RMSE of $\hat{\boldsymbol{\theta}}_{\mathrm{pop}}$;
RMSE of $\hat{\boldsymbol{\eta}}_j$ vs. true; $\hat{\boldsymbol{\Omega}}$ vs.
$\boldsymbol{\Omega}_{\mathrm{true}}$ (this exposes the S1 variance bias from
[04 §4.3](04-population-inverse-problem.md)).

**Predictive:**
- Held-out individuals (20% never seen in training) — RMSE, and prediction-corrected VPC.
- **Held-out dose level** — train on doses {low, high}, predict {middle}. This is the real
  extrapolation test and where B3 (black-box) should fail.
- Held-out time horizon — train on $[0, T/2]$, predict $[T/2, T]$.

**Symbolic recovery:** does symbolic regression return the true functional form? Report
the Pareto front and whether the true expression appears on it.

**Computational:** wall-clock, GPU vs CPU, per [05 §5.7](05-gpu-strategy.md).

> **中文讲解｜CN**
> 两个指标设计要点：
>
> 1. **机制恢复误差必须用支撑密度 $\rho(z)$ 加权。**
>    如果不加权，你会在数据从未访问过的浓度区间上算误差——那里的曲线纯属外推，
>    误差大是必然的，报出来既不公平也没意义。加权后报告的才是"在数据说了话的地方，学得准不准"。
>
> 2. **"留出剂量水平"是最关键的预测检验。**
>    做法：用低剂量组和高剂量组训练，预测中剂量组。
>    这直接考验模型有没有学到真正的浓度依赖关系，而不是记住了某个剂量下的曲线形状。
>    **预期结果：UDE 表现良好，纯黑箱 B3 显著变差。** 如果这个预期没出现，
>    说明机理结构没有发挥作用，需要回头检查 UDE 的构造。
>
> 另外 $\hat{\boldsymbol{\Omega}}$ 与真值的对比一定要报——
> 它把 [04 §4.3](04-population-inverse-problem.md) 里承认的"联合 MAP 低估方差"这个偏差**定量化**了。
> 主动量化自己方法的已知缺陷，是加分项。

### 7.6 Go/no-go gate for Part I

Proceed to real data only if **all** hold:

- [ ] Finite-difference gradient check passes ($<10^{-4}$ relative).
- [ ] Mass conservation holds with elimination disabled.
- [ ] Float32 GPU matches Float64 CPU within stated tolerance.
- [ ] On the easiest setting ($N=5000$, 12 obs, 5% noise, H1): $\mathrm{E}_{\mathrm{mech}} < 10\%$.
- [ ] UDE beats B1 (misspecified) on held-out dose level, with a margin exceeding run-to-run variability.
- [ ] UDE beats B3 (black-box) on held-out dose level.
- [ ] UDE beats B4 (deep compartment model) on hidden-mechanism recovery.
- [ ] **Test D passes** under the pre-registered rule of [06 §6.0](06-identifiability.md):
      in-sample fits within $2\sigma_{\mathrm{run}}$, held-out-dose advantage
      $\Delta \ge 2\sigma_{\mathrm{run}}$, $R = 10$ seeds each. An *inconclusive* verdict
      does not pass.
- [ ] No estimated parameter sits within tolerance of its bound
      ([06 §6.7](06-identifiability.md), diagnostic (e)).
- [ ] $\eta$-shrinkage < 30% for the primary parameters.
- [ ] Network-ablation test: $\hat{\mathrm{CL}}_{\mathrm{pop}}$ shifts by < 20% when the network is enabled.

If the easiest setting fails, the problem is the method or the code — not the data. Fix it
before touching real data.

> **中文讲解｜CN**
> **这个 gate 的意义在于：不要带着未确认的 bug 去碰真实数据。**
>
> 真实数据有无穷多种解释失败的方式（数据质量、模型结构、生理复杂性……），
> 一旦在那里失败，你几乎不可能定位原因。而在合成数据上，失败只可能是方法或代码的问题，
> 定位成本低得多。
>
> 特别注意倒数第二、三条（shrinkage 和消融检验）：
> 它们不是"拟合好不好"的指标，而是"结果可不可信"的指标。
> **拟合很好但 shrinkage 40%、消融后清除率变一倍——这种结果是没有科学价值的，
> 即使 RMSE 很漂亮。** 宁可在这里卡住，也不要带着这样的结果往下走。

---

## Part II — Real-Data Study

### 7.7 The honest constraint

**Plasma-only sparse clinical data cannot identify a full 13-compartment PBPK model.**
This is a hard information-theoretic limit, not a computational one. Any proposal claiming
otherwise is wrong.

Three legitimate ways forward:

**(R1) Reduce the model.** Use a minimal/lumped PBPK (mPBPK): blood + liver + kidney +
"rapidly perfused" + "slowly perfused", 5–6 compartments. Retains the transport-network
structure and the mechanistic elimination site while matching the information content of
plasma data. **This is the recommended route.**

**(R2) Fix physiology from literature, estimate few scalars.** Keep the full PBPK but fix
all $V_i, Q_i, K_{p,i}$ at literature/predicted values; estimate only $\mathrm{CL}$-related
quantities, a global $K_p$ scaling, and $\boldsymbol{\phi}$.

**(R3) Use data with tissue measurements.** Preclinical (rat/mouse) PBPK datasets with
serial tissue sampling identify far more. Public datasets exist in the Open Systems
Pharmacology community. Costs cross-species relevance; gains identifiability.

> **中文讲解｜CN**
> **这一节必须诚实，且必须写进开题报告。**
>
> 硬约束：**只有稀疏血浆数据，无法辨识一个 13 房室的完整 PBPK 模型。**
> 这是信息论层面的限制，不是"算力不够"或"算法不好"。
> 任何声称"用 GPU 就能反演出全部生理参数"的说法都是错的，而且会被内行一眼看穿。
>
> 三条正当出路：
> - **R1 简化模型（推荐）**：用最小 PBPK（mPBPK，5–6 房室：血 + 肝 + 肾 + 快速灌注组织 + 慢速灌注组织）。
>   **它保留了输运网络结构和机理消除位点，但把参数量降到与血浆数据的信息量匹配。**
>   注意这不是"退而求其次"——**模型降阶本身就是 CFD 方法论的一部分（ROM）**，
>   可以正面地写成"信息量驱动的模型降阶"。
> - **R2 固定生理参数**：保留完整 PBPK，但所有 $V_i, Q_i, K_{p,i}$ 全部固定为文献值，
>   只估清除率相关量 + 一个全局 $K_p$ 缩放 + $\boldsymbol{\phi}$。
> - **R3 换有组织浓度的数据**：动物实验数据（大鼠/小鼠）常有多组织连续采样，可辨识性大幅提升，
>   代价是跨物种外推的相关性。
>
> **建议主线走 R1，把 R2 作为敏感性分析。** R3 视数据可得性作为补充。

### 7.8 Dataset selection criteria

A dataset is suitable only if it has:

1. **Multiple dose levels** (mandatory — the nonlinearity is invisible otherwise).
2. **Evidence of nonlinear PK** in the literature (dose-disproportional AUC, time-dependent
   clearance). Fitting a UDE to a linear drug is a null experiment.
3. **$N \ge 50$** individuals with covariates recorded.
4. **A published NLME analysis** to compare against.
5. **Public availability** and a clear license.

Candidates, with honest assessments:

| Drug | Pros | Cons |
|---|---|---|
| **Warfarin** (O'Reilly; in nlmixr2/Monolix) | Classic, public, well-analysed, has PK/PD | Essentially linear PK, 1-cmt structure, single dose → **weak UDE test** |
| **Theophylline** | Public, in every PK package | 12 subjects, single dose, linear → too small |
| **Decitabine** | Genuinely nonlinear (saturable cytidine-deaminase clearance), schedule-dependent | Data access harder; must check what is actually public |
| **Midazolam** | Rich PBPK literature, CYP3A4 probe, DDI studies give dose/inhibition variation | Data assembly from multiple publications |
| **Preclinical tissue-PK datasets (OSP community)** | Tissue concentrations → real PBPK identifiability | Animal, not human; heterogeneous sources |

**Recommendation:** run warfarin/theophylline first as a *plumbing test* (does the pipeline
run end-to-end on real, messy data?), and select a genuinely nonlinear drug for the
*scientific* case study. Verify data availability **before** committing.

> **中文讲解｜CN**
> ⚠️ **重要提醒：华法林数据集虽然是 PK 领域最经典的公开数据，但它的药代基本是线性的、
> 单剂量、单室结构——对 UDE 来说是一个"零实验"：没有非线性可学，方法的价值体现不出来。**
>
> 所以正确的用法分两步：
> 1. **华法林 / 茶碱 = 管道测试**：验证整条流程能不能在真实的、脏的数据上跑通
>    （数据格式、BLQ、缺失值、协变量），不指望有科学结论；
> 2. **真正的科学案例必须选一个已知有非线性 PK 的药**（剂量-AUC 不成比例、
>    清除率随时间变化）。地西他滨（decitabine）由于胞苷脱氨酶的饱和性清除是个不错的候选。
>
> **务必在投入之前先确认数据是否真的公开可得、许可证是否允许使用。**
> 这是最容易在项目中期才发现问题的环节，代价很高。
> 可以先去 [pk-db.com](https://pk-db.com) 和 Open Systems Pharmacology 的公开仓库查一遍。

### 7.9 Real-data analysis protocol

1. **Reproduce the published NLME analysis first.** If you cannot reproduce the reference
   result with the reference model, the data preparation is wrong. This step catches more
   bugs than any other.
2. Fit B1 (mechanistic mPBPK), then the UDE.
3. Full diagnostic suite from [06 §6.4](06-identifiability.md).
4. Prediction-corrected VPC for all models.
5. Held-out individuals AND held-out dose group.
6. Symbolic regression on the learned closure; compare against mechanisms proposed in the
   drug's literature.
7. Report computation time against the NLME reference tool.

> **中文讲解｜CN**
> **第 1 步是全流程性价比最高的一步，绝对不要跳过。**
>
> 先用文献里发表过的模型和方法（FOCE-I）重跑一遍已发表的分析，
> 看能不能复现出文献报告的参数值。如果复现不出来，问题几乎一定在**数据准备**——
> 单位换算、给药记录、时间基准、BLQ 处理、协变量编码。
>
> 这一步能抓出的 bug 比后面所有诊断加起来还多，而且成本很低。
> 跳过它直接上 UDE，一旦结果不对，你会去怀疑 UDE 方法本身，而实际问题可能只是
> 剂量单位写成了 mg 而不是 µmol。
>
> 第 6 步是真实数据研究的**科学落点**：把学到的闭合项还原成公式后，
> 去和该药物文献里已经提出过的机制假说对照。
> 如果学出来的形式与某个已知假说吻合 → 强有力的独立验证；
> 如果不吻合但拟合更好 → 一个值得进一步实验验证的新假说。
> **两种结果都是好结果**，这一点在设计研究时就要想清楚，避免只报"符合预期"的那一半。

---

## 7.10 Deliverables checklist

- [ ] Twin-study phase diagram (recovery vs $N$, $n_{\mathrm{obs}}$, $\sigma$)
- [ ] Learned vs. true closure plot, with support density $\rho(z)$ underneath
- [ ] Five-way baseline comparison table (Oracle / mechanistic / NLME / black-box / UDE)
- [ ] Held-out-dose extrapolation figure
- [ ] Identifiability diagnostics (profile likelihood, correlation matrix, shrinkage, ablation)
- [ ] Symbolic regression Pareto front, with refit verification
- [ ] GPU scaling benchmark with breakeven $N$
- [ ] Real-data case study with VPC and NLME comparison
- [ ] Explicit statement of failure modes found (including H3)

---

**Next:** [08 — CFD Correspondence](08-cfd-correspondence.md)
