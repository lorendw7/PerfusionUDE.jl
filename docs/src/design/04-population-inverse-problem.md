# 04 — The Population Inverse Problem

## 4.1 Hierarchical statistical model

Three levels.

**Level 1 — Observation (residual error).** For individual $j$, observation $k$ at time
$t_{jk}$:

```math
y_{jk} \;=\; h\big(\mathbf{u}_j(t_{jk})\big)\,(1 + \varepsilon^{\mathrm{prop}}_{jk}) + \varepsilon^{\mathrm{add}}_{jk},
\qquad \varepsilon^{\mathrm{prop}} \sim \mathcal{N}(0,\sigma_p^2), \; \varepsilon^{\mathrm{add}} \sim \mathcal{N}(0,\sigma_a^2)
```

with $h(\mathbf{u}) = C_{\mathrm{ven}}/R_b$ the plasma concentration. In practice fit on
the log scale, which turns the combined error into approximately additive:

```math
\log y_{jk} = \log h(\mathbf{u}_j(t_{jk})) + \epsilon_{jk}, \qquad \epsilon_{jk} \sim \mathcal{N}(0, \sigma^2).
```

**Level 2 — Individual dynamics.**

```math
\frac{d\mathbf{u}_j}{dt} = f_{\mathrm{known}}(\mathbf{u}_j, \boldsymbol{\theta}_j, t) + \mathbf{S}\,\mathcal{N}_{\boldsymbol{\phi}}(\mathbf{z}), \qquad \mathbf{u}_j(0) = \mathbf{u}_0(D_j)
```

**Level 3 — Population.**

```math
\boldsymbol{\theta}_j = g(\boldsymbol{\theta}_{\mathrm{pop}}, \mathbf{x}_j)\odot \exp(\boldsymbol{\eta}_j), \qquad \boldsymbol{\eta}_j \sim \mathcal{N}(\mathbf{0}, \boldsymbol{\Omega}) .
```

Unknowns: $\boldsymbol{\Theta} = \big(\boldsymbol{\phi},\, \boldsymbol{\theta}_{\mathrm{pop}},\, \boldsymbol{\Omega},\, \sigma\big)$
plus the latent $\{\boldsymbol{\eta}_j\}_{j=1}^N$.

> **中文讲解｜CN**
> 三层结构是群体药代（population PK）的标准框架，也就是 **NLME（非线性混合效应模型）**。
> 用你熟悉的语言翻译一遍：
> - **第 3 层**：参数不是确定值，而是从一个分布里抽出来的 → 这就是 UQ 里的**随机参数场**；
> - **第 2 层**：每个参数样本对应一次确定性求解 → **UQ ensemble 的一次实现**；
> - **第 1 层**：观测 = 模型输出 + 噪声 → 数据同化的观测算子和观测误差协方差。
>
> 区别在于：UQ 通常是**正向**的（给定参数分布，求输出分布）；
> 这里是**反向**的（给定输出观测，反求参数分布 **和** 一个共享的闭合项）。
>
> 注意 $\boldsymbol{\eta}_j$ 是**隐变量**（latent），不是普通参数：
> 它有 $N$ 份、随数据量增长，且我们最终关心的是它的**分布** $\boldsymbol{\Omega}$ 而不是每个值。
> 这个区别决定了下面 4.3 节几种估计策略的分野。

---

## 4.2 The marginal likelihood and why it is hard

The statistically correct objective is the marginal likelihood, integrating out
$\boldsymbol{\eta}_j$:

```math
\mathcal{L}(\boldsymbol{\Theta}) = \prod_{j=1}^{N} \int p\big(\mathbf{y}_j \mid \boldsymbol{\eta}_j, \boldsymbol{\Theta}\big)\, p(\boldsymbol{\eta}_j \mid \boldsymbol{\Omega})\, d\boldsymbol{\eta}_j
```

Each integral is over $\mathbb{R}^{d_\eta}$ ($d_\eta \approx 3$–$6$) and has no closed
form, because $\mathbf{y}_j$ depends on $\boldsymbol{\eta}_j$ through an ODE solve. This
is precisely why the population-PK field developed FO, FOCE, Laplace, and SAEM.

---

## 4.3 Four estimation strategies

Choose deliberately; each has a different GPU profile.

### (S1) Joint MAP / penalized likelihood — **recommended for Phase 1–2**

Treat $\{\boldsymbol{\eta}_j\}$ as parameters and add their prior as a penalty:

```math
\min_{\boldsymbol{\phi},\,\boldsymbol{\theta}_{\mathrm{pop}},\,\{\boldsymbol{\eta}_j\}}
\; \sum_{j=1}^{N} \left[ \underbrace{\frac{1}{2\sigma^2}\sum_k \big(\log y_{jk} - \log h(\mathbf{u}_j(t_{jk}))\big)^2}_{\text{data misfit}} + \underbrace{\tfrac{1}{2}\boldsymbol{\eta}_j^\top \boldsymbol{\Omega}^{-1} \boldsymbol{\eta}_j}_{\text{Tikhonov toward population mean}} \right] + \mathcal{R}(\boldsymbol{\phi})
```

- **Pros:** one flat, fully differentiable objective; a single gradient step touches all
  $N$ individuals; maps perfectly onto GPU ensemble + AD. This is the whole reason the
  project works computationally.
- **Cons:** the estimator of $\boldsymbol{\Omega}$ is biased (it is a
  *maximum-a-posteriori* estimate of latent variables, not a marginal MLE — the classic
  "penalized likelihood underestimates variance components" problem). With
  $d_\eta \ll n_{\mathrm{obs},j}$ the bias is modest; with sparse data it is not.
- **Mitigation:** hold $\boldsymbol{\Omega}$ fixed at a plausible value during joint
  training, then re-estimate it in an outer loop (an EM-flavoured alternation), or apply a
  small-sample correction and report it honestly.

> **中文讲解｜CN**
> 这是**首选方案**，理由纯粹是计算上的：它把整个群体反问题写成了**一个平坦的、处处可微的目标函数**。
> 一次梯度步就同时更新所有个体的 $\boldsymbol{\eta}_j$ 和共享的 $\boldsymbol{\phi}$，
> 完美匹配 GPU ensemble + 自动微分。
>
> 注意括号里第二项 $\frac{1}{2}\boldsymbol{\eta}_j^\top\boldsymbol{\Omega}^{-1}\boldsymbol{\eta}_j$ 的性质：
> **它就是 Tikhonov 正则化**，只不过正则化矩阵有统计学解释（向群体均值收缩）。
> 反问题正则化和贝叶斯先验在这里是同一件事，这个对应关系值得在论文里点明。
>
> ⚠️ **必须诚实报告的缺陷**：这样估出来的 $\boldsymbol{\Omega}$ 是有偏的（系统性偏小）。
> 这是"惩罚似然低估方差分量"的经典问题。传统 NLME 用 FOCE/SAEM 正是为了绕开它。
> 缓解办法：训练时先固定 $\boldsymbol{\Omega}$，外层再交替更新（EM 味道的做法）。
> **千万不要假装这个问题不存在——审稿人一定会问。**

### (S2) Laplace-approximated marginal likelihood

Approximate each integral by a Laplace expansion around
$\hat{\boldsymbol{\eta}}_j = \arg\max$:

```math
-\log \mathcal{L} \approx \sum_j \left[ \ell_j(\hat{\boldsymbol{\eta}}_j) + \tfrac{1}{2}\log\det \mathbf{H}_j \right], \qquad \mathbf{H}_j = \nabla^2_{\boldsymbol{\eta}} \ell_j \big|_{\hat{\boldsymbol{\eta}}_j}
```

This is essentially FOCE. It removes most of the $\boldsymbol{\Omega}$ bias, at the cost of
an inner optimization per individual and a $\log\det$ of a $d_\eta \times d_\eta$ Hessian
— *differentiated through*, i.e. third derivatives of the ODE solution.

Feasible because $d_\eta$ is tiny (a $3\times3$ or $6\times6$ Hessian per individual,
computable by forward-over-forward AD entirely inside the per-individual GPU work). Plan
this as **Phase 4**, and use it to quantify the bias of (S1).

> **中文讲解｜CN**
> S2 本质上就是 NLME 领域的 **FOCE**。它比 S1 统计上更正确，但要付出的代价是：
> - 每个个体一个内层优化（求 $\hat{\boldsymbol{\eta}}_j$）；
> - 一个 $\log\det$ 的 Hessian 项，而且这一项还要**再被微分一次**（对 $\boldsymbol{\phi}$ 求梯度）
>   → 需要对 ODE 解求三阶导。
>
> 听起来吓人，但**在本项目里其实可行**，因为 $d_\eta$ 只有 3–6 维：
> Hessian 是 $3\times3$ 的小矩阵，用 forward-over-forward AD 在每个个体的 GPU 工作内部算完即可。
>
> 建议定位为 **Phase 4 的方法学升级**，且它有一个额外用途：
> **用 S2 的结果去定量 S1 的偏差有多大**——这本身就是一个可发表的方法学结论。

### (S3) Variational EM / amortized inference — **promoted to Phase 4 (revised 2026-08-06)**

Optimize a variational lower bound on the marginal likelihood, either with per-individual
variational parameters (VEM) or with an amortizing encoder
$q_{\boldsymbol{\psi}}(\boldsymbol{\eta}_j \mid \mathbf{y}_j, \mathbf{x}_j)$ mapping an
individual's observed profile directly to a posterior over $\boldsymbol{\eta}_j$.

- **Pros:** targets the *marginal* likelihood, so it does not inherit S1's variance-component
  bias; reverse-mode AD throughout; with amortization, new individuals are fitted by a
  single forward pass and the optimized-parameter count stops growing with $N$.
- **Cons:** amortization gap; an encoder must handle irregular, individual-specific
  sampling times (set-transformer or time-embedding architecture); another network to tune.

**Why the promotion.** Tarek & Afonso (2026, arXiv:2604.26160) demonstrate VEM with
flexible variational families and reverse-mode AD on a DeepNLME model with **15,410
population parameters and 16 random effects**. This removes the main objection — that VEM
at this scale was unproven for neural NLME — and makes it the natural
marginal-likelihood-correct upgrade path from S1. See
[11 §11.1(2)](11-literature-landscape.md).

Note the axis distinction: their scale is *parameter count*; ours is *number of
individuals $N$*. The two are complementary, not competing.

### (S4) Full Bayesian (NUTS / HMC)

Correct uncertainty quantification, but $O(N \cdot d_\eta)$ latent dimensions with an ODE
in the likelihood. Not feasible at $N=10^3$–$10^4$. **Use it as a gold-standard reference
on a small subset ($N \le 30$)** to validate the uncertainty estimates produced by (S1) or
(S2). That is a legitimate and cheap validation, and worth doing.

> **中文讲解｜CN**
> 四种策略的取舍建议：
>
> | 策略 | 用途 | 阶段 |
> |---|---|---|
> | S1 联合 MAP | **主力方案**，GPU 友好，全项目的计算基础 | Phase 1–3 |
> | S2 Laplace/FOCE | 方法学升级，用来量化 S1 的偏差 | Phase 4 |
> | **S3 变分 EM（VEM）** | **已提升**：边缘似然正确，有大规模成功先例，S1 的正统升级路径 | **Phase 4** |
> | S4 全贝叶斯 HMC | **不用于主实验**，只在 $N\le 30$ 的小子集上做金标准参照 | Phase 2 抽空做 |
>
> ⚠️ **S3 的地位在 2026-08-06 的文献检索后改变了。** 原来判断"偏离主线"，
> 是因为当时认为变分方法在神经 NLME 上的大规模可行性未经验证。
> Tarek & Afonso (2026) 已经在 15,410 个总体参数的 DeepNLME 模型上跑通了 VEM，
> 这个顾虑消失了。现在 S3 是 S1 最正统的升级方向：
> **它直接优化边缘似然，因此不继承 S1 低估方差分量的偏差。**
>
> S4 值得特别说明：不要试图在 $N=10^4$ 上跑 HMC，那是不可行的。
> 但**在 30 个个体上跑一次 HMC，用来检验 S1 给出的不确定性是否合理**，成本很低、说服力很强。
> 这是审稿人会喜欢的那种"我知道自己方法的近似在哪里，并且量化了它"。

---

## 4.4 The objective, assembled

Phase-1 concrete objective (all in log-space, nondimensionalized):

```math
J(\boldsymbol{\phi}, \boldsymbol{\theta}_{\mathrm{pop}}, \mathbf{H}) = \frac{1}{N}\sum_{j=1}^{N}\Big[ \underbrace{\tfrac{1}{2\sigma^2}\|\mathbf{r}_j\|^2}_{\text{misfit}} + \tfrac{1}{2}\boldsymbol{\eta}_j^\top \boldsymbol{\Omega}^{-1}\boldsymbol{\eta}_j \Big] + \lambda_2\|\boldsymbol{\phi}\|_2^2 + \lambda_1\|\boldsymbol{\phi}\|_1 + \lambda_s \mathcal{S}(\boldsymbol{\phi})
```

where $\mathbf{H} = [\boldsymbol{\eta}_1, \dots, \boldsymbol{\eta}_N] \in \mathbb{R}^{d_\eta \times N}$
is stored as a single dense matrix (a `CuMatrix` — column $j$ is individual $j$).

**Normalize by $N$.** Otherwise $\lambda$'s meaning changes when the population size
changes, and every hyperparameter must be re-tuned between the twin study and the real
study.

> **中文讲解｜CN**
> 两个实现层面的关键决定：
>
> 1. **$\mathbf{H} = [\boldsymbol{\eta}_1,\dots,\boldsymbol{\eta}_N]$ 存成一个稠密矩阵**
>    （$d_\eta \times N$，直接放在 GPU 上）。不要用 `Vector{Vector}`。
>    这样它是一块连续显存、可以整块做 AD、可以整块传给 ensemble 构造器。
>    这个数据布局决定了后面 GPU 实现的难易。
>
> 2. **目标函数要除以 $N$。** 否则 $\lambda_1,\lambda_2,\lambda_s$ 的含义随群体规模变化，
>    你在 $N=500$ 的孪生实验上调好的超参数，换到 $N=3000$ 的真实数据上全部作废。
>    这是很容易忽略、但会浪费掉一周时间的细节。

---

## 4.5 Optimization schedule

Naively minimizing $J$ from a random start fails. The reliable recipe:

**Stage 0 — Mechanistic warm start.**
Fix $\boldsymbol{\phi} = \mathbf{0}$ (residual form ⇒ pure mechanistic model). Fit
$\boldsymbol{\theta}_{\mathrm{pop}}$ and $\mathbf{H}$ only. Cheap, robust, and gives a
baseline fit quality to beat.

**Stage 1 — Multiple-shooting / interval growth.**
Fit on $t \in [0, T_1]$ with $T_1$ short, then progressively extend to the full horizon.
This is the standard cure for the exploding-gradient / chaotic-loss-landscape pathology of
long-horizon ODE fitting.

**Stage 2 — Alternating.**
Alternate a few epochs of $\mathbf{H}$-only updates with a few epochs of
$\boldsymbol{\phi}$-only updates before joint updates. This decouples the two very
differently-scaled parameter blocks.

**Stage 3 — Joint Adam, then joint L-BFGS.**
Adam ($\sim 10^3$ iterations) to get into the right basin; L-BFGS for the final
high-accuracy descent. This two-optimizer pattern is standard in SciML and materially
affects final accuracy.

**Stage 4 — $\boldsymbol{\Omega}$ update (outer loop).**
$\hat{\boldsymbol{\Omega}} \leftarrow \frac{1}{N}\sum_j \hat{\boldsymbol{\eta}}_j \hat{\boldsymbol{\eta}}_j^\top$
(with shrinkage correction), then return to Stage 3. Two or three outer iterations.

> **中文讲解｜CN**
> **这个训练日程表不是"建议"，是"必须"**。直接从随机初值联合最小化 $J$ 几乎必然失败。
>
> 每一阶段解决的具体病症：
>
> | 阶段 | 解决什么问题 |
> |---|---|
> | Stage 0 机理热启动 | 避免网络在生理参数还是乱的时候就开始"学"；同时给出必须超越的基线 |
> | Stage 1 区间递增 | 长时程 ODE 拟合的损失面极度非凸、梯度爆炸——先拟合短区间再逐步延长 |
> | Stage 2 交替优化 | $\boldsymbol{\eta}$ 和 $\boldsymbol{\phi}$ 尺度差异巨大，直接联合更新会互相干扰 |
> | Stage 3 Adam→L-BFGS | Adam 找盆地、L-BFGS 精细下降，SciML 里的标准搭配 |
> | Stage 4 外层更新 $\boldsymbol{\Omega}$ | 缓解 S1 的方差低估偏差 |
>
> Stage 1 特别值得展开：这就是**多重打靶法（multiple shooting）**的思想。
> 长时间积分的 ODE 拟合，损失函数关于参数是高度振荡的（初值的微小变化被指数放大）。
> 先在短区间上拟合、再逐步延长时间窗，等价于逐步引入这种非凸性。
> 这一招在轨道确定、气象数据同化里都是标准手段，属于你可以直接类比的已有经验。

---

## 4.6 Mini-batching over individuals

Because $\boldsymbol{\phi}$'s gradient is a sum over individuals,

```math
\nabla_{\boldsymbol{\phi}} J = \frac{1}{N}\sum_{j=1}^{N} \nabla_{\boldsymbol{\phi}} J_j,
```

it can be estimated from a mini-batch $\mathcal{B} \subset \{1,\dots,N\}$. But
$\nabla_{\boldsymbol{\eta}_j} J$ is **not** a sum — it involves only individual $j$.

Consequence: with mini-batching, $\boldsymbol{\phi}$ is updated every step while each
$\boldsymbol{\eta}_j$ is updated only when $j \in \mathcal{B}$. This is a *stale-parameter*
problem and it slows $\boldsymbol{\eta}$ convergence by a factor $N/|\mathcal{B}|$.

**Recommendation:** use full-batch. $N \le 10^4$ individuals × 16 states fits in GPU memory
easily, and full-batch is exactly what makes the GPU ensemble efficient. Only introduce
mini-batching if memory forces it — and if so, use large batches ($|\mathcal{B}| \ge 512$)
with a higher learning rate for $\mathbf{H}$ than for $\boldsymbol{\phi}$.

> **中文讲解｜CN**
> 这是一个容易踩的坑：**深度学习的本能反应是"上 mini-batch"，但在这里 mini-batch 是有害的。**
>
> 原因在于两类参数的梯度结构不同：
> - $\nabla_{\boldsymbol{\phi}} J$ 是**对所有个体求和**→ 可以用小批量无偏估计；
> - $\nabla_{\boldsymbol{\eta}_j} J$ **只涉及个体 $j$ 自己** → 个体 $j$ 不在这批里，它的参数就完全不更新。
>
> 于是 $\boldsymbol{\eta}$ 的收敛速度被拖慢 $N/|\mathcal{B}|$ 倍。
>
> 而且从 GPU 的角度看，**全批量恰恰是最优的**：$N=10^4$ 个体 × 16 个状态 ≈ 十几万个 Float32，
> 显存毫无压力，而 GPU 正是靠这个并行度吃满算力的。缩小 batch 反而浪费 GPU。
>
> **结论：默认全批量。** 只有显存真的不够时才分批，且要用大批量并给 $\mathbf{H}$ 更高的学习率。

---

## 4.7 Handling BLQ / censored observations

Real PK data contain observations **below the limit of quantification (BLQ)**, typically
in the terminal phase — exactly the region that is most informative about clearance
nonlinearity. Discarding them biases clearance estimates.

The standard treatment (Beal's "M3") replaces the Gaussian density with the censoring
probability for those points:

```math
\ell_{jk} = \log \Phi\!\left(\frac{\log \mathrm{LOQ} - \log h(\mathbf{u}_j(t_{jk}))}{\sigma}\right) \quad \text{if } y_{jk} \text{ is BLQ.}
```

This is smooth and differentiable — it costs nothing to include, and omitting it is a
known source of bias. Include it from the start in the real-data study; include it as a
*simulated* feature in the twin study so the twin study actually tests it.

> **中文讲解｜CN**
> BLQ（低于定量下限）在真实 PK 数据里普遍存在，通常出现在**终末相**——
> 而终末相恰恰是关于清除率非线性信息最丰富的区域。
>
> 常见的错误做法：直接把 BLQ 点删掉，或者用 LOQ/2 代替。
> 两者都会**系统性高估**终末浓度、低估清除率。
>
> 正确做法（NONMEM 里叫 **M3 方法**）：对 BLQ 点，似然贡献不是正态密度，
> 而是"该点落在 LOQ 以下"的概率 $\Phi(\cdot)$。这个式子光滑可微，加进目标函数几乎零成本。
>
> 特别建议：**在孪生实验里也要人为制造 BLQ**，否则你的方法在合成数据上表现完美、
> 一上真实数据就崩，而且你会不知道原因。孪生实验必须模拟真实数据的所有病理。

---

**Next:** [05 — GPU Strategy](05-gpu-strategy.md)
