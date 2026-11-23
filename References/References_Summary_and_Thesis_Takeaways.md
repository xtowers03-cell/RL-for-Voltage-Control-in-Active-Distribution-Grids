# Literature Review & Reference Takeaways

**Thesis Topic:** Reinforcement Learning for Decentralized Voltage Regulation in the IEEE 13-Feeder Distribution Grid  

---

## [1] M. B. Abdul Mughni (Aug 2026) — *DVPP Control for Fast Voltage Control in Active Distribution*

### Why This Thesis Matters for Our Thesis
Direct DREAM/HTW predecessor on the exact modified IEEE 13-node feeder with 4 PV plants. Benchmarks 3 optimization/distributed voltage controllers alongside DVPP frequency control under P-priority, and explicitly proposes **Reinforcement Learning** in Chapter 8 (Future Work) to overcome linear sensitivity assumptions, non-convexity, and dual-multiplier windup.

### Key Takeaways for Thesis Design
1. **Grid & Bus Architecture (Ch. 3 & Table 1, pp. 21–26):**
   * Modified **4.16 kV** IEEE 13-node feeder with 4 PV plants connected via **4.16 kV / 480 V** transformers:
     * **4 Active PV Buses:** `Bus 634`, `Bus 672`, `Bus 675`, `Bus 680` (with ADPF frequency control: low-pass at 634/672, high-pass at 675/680; 200 V MPPT deloading reserve; **P-priority** mode).
     * **8 Passive Load Buses:** `Bus 611`, `Bus 632`, `Bus 645`, `Bus 646`, `Bus 652`, `Bus 671`, `Bus 684`, `Bus 692`.
   * Statutory bounds used in [1]: **$0.90\text{--}1.10\text{ p.u.}$** *(tightened to $0.95\text{--}1.05\text{ p.u.}$ in our thesis)*; reactive bounds in RLS: $\pm 5.5\text{ MVAR}$.
2. **Summary of the 3 Baseline Voltage Controllers (Ch. 4 & Ch. 6):**
   * **`LS_V` (Offline Least Squares + Centralized Convex Opt.):** Two-layer linear regression (204 offline runs) predicting passive bus voltages to compute $V_{\text{ref}}$ for local PI loops. *Best steady-state RMSE & fast execution*, but fragile to grid changes and ignores $Q$/$S_{\max}$ limits.
   * **`RLS_V` (Online Recursive Least Squares + Centralized Opt.):** Online Kalman/RLS sensitivity estimation wrt $Q$ (direct $Q_{\text{ref}}$ control with $Q_{\min}/Q_{\max}$ limits). *Most robust to parameter/topology changes*, but slowest settling time and requires continuous all-bus communication.
   * **`D_V` (Distributed Voltage Control via Dual Ascent / Ortmann & Bolognani [18]):** Minimizes $\frac{1}{2}q^T M q$ subject to active/passive voltage bounds and apparent power limits ($s_h = \sqrt{p_h^2 + q_h^2} \le s_{h,\max}$) using multi-timescale Lagrange multipliers ($\lambda$ local $V$, $\beta$ neighboring passive $V$, $\mu$ peer-to-peer $S_{\max}$). *Fastest settling time, lowest overshoot, minimal long-range communication, enforces $S_{\max}$*, but high iterative computation, relies on reactance matrices ($X_{hh}, X_{hk}$), and suffers from Lagrange saturation/windup recovery delay.
   * *(Also evaluates **Local Voltage Control** — independent PI tracking $1.0\text{ p.u.}$ locally — as a 4th comparison baseline.)*
3. **Test Scenarios, Sensitivity Findings & KPIs (Ch. 5 & Ch. 6):**
   * **Disturbances:** Simultaneous main-grid voltage steps (**0.7, 0.8, 1.2, and 1.3 p.u.**) and a **$-1.33\text{ MW}$** active power drop from $t = 10\text{--}25\text{ s}$.
   * **Sensitivity Analysis (Sec. 5.1):** Confirmed strong $V\text{--}P$ coupling without frequency control; once ADPF frequency control is active, $V\text{--}Q$ sensitivity dominates across nearly all buses.
   * **Benchmark KPIs (Sec. 6.2):** 12-bus steady-state voltage violation **RMSE** (at $t=24\text{ s}$), **% overshoot/undershoot**, and **settling time**.

---

## [2] H. Schulte, J. Brunner, M. Wypych (ISGT Europe 2026) — *Frequency Control of Low-inertia Power Grids via DVPP-based support from Distribution Networks: a IEEE 13-node Feeder Case Study*

### Why This Paper Matters for Our Thesis
This paper comes directly from Prof. Horst Schulte's group at HTW Berlin and defines the **exact modified IEEE 13-bus benchmark topology** and **plant-level inverter abstraction** used in their DVPP research line. While [2] controls *active power* ($\Delta p_i$) for transmission-level frequency support, our thesis adapts this distribution grid testbed to control *reactive power* ($Q_i$) for local voltage regulation.

### Key Takeaways for Thesis Design
1. **Exact Modified IEEE 13-Bus Grid Architecture (Section III-A & Fig. 1):**
   * **Nominal Feeder Voltage & Symmetrization:** Based on Kersting's IEEE 13-node feeder ($V_{\mathrm{rms}} = 4.16\text{ kV}$), **symmetrized** (line and load asymmetries removed) to eliminate negative-sequence and phase-imbalance complexity. *(Confirm with Mashhood [1] / Horst whether the voltage-control model keeps this symmetrization or uses an unbalanced/400 V adaptation).*
   * **Grid Interface (PCC):** Connected at **Bus 632** via a $132\text{ kV}/4.16\text{ kV}$ transformer to a dynamic equivalent transmission grid (swing equation model, Eq. 12 & Eq. 15).
   * **Four Distributed IBRs (3:1 PV-to-BESS ratio):** All connected through $4.16\text{ kV}/480\text{ V}$ step-down transformers:
     * **PV I** at **Bus 634** (branch 632 $\to$ 632b $\to$ 633 $\to$ 634)
     * **PV II** at **Bus 672** (branch 671 $\to$ 671b $\to$ 671c $\to$ 672)
     * **PV III** at **Bus 675** (branch 671 $\to$ 692a $\to$ 692b $\to$ 675)
     * **BESS** at **Bus 680** (branch 671 $\to$ 671a $\to$ 680)
   * **Existing Voltage Equipment:** Includes line impedances and shunt capacitors for baseline voltage compensation.
2. **Inverter Modeling Abstraction (Section III-A):**
   * The four IBRs are modeled at the grid level as **controlled negative loads** with adjustable power injections ($\Delta p_i$ active, $\Delta q_i = 0$ in [2]), ignoring inner switching and converter control loops.
   * This directly matches our Nov 13 supervisor meeting conclusion: *"The inverter control itself is not the topic. We consider the inverters as fully stable and only decide how much reactive power to provide alongside the reference active power."*
3. **Decentralized Coordination & Scalability Principles (Sections II-B & IV):**
   * Uses local device models coordinated via non-continuous / minimal communication channels (dashed red lines in Fig. 1) to meet global network objectives.
   * **Subcluster Scaling (Section IV-B, Eq. 27):** Demonstrates how to prevent polynomial/parameter explosion when scaling beyond $n_p = 4$ devices by grouping units into $n_c$ subclusters ($\sum m_i = 1/n_c$)—a helpful conceptual parallel when arguing for the scalability of our decentralized RL architecture.
   * **Resource-Aware Adaptation (Section IV-C, Fig. 2):** Uses a nonlinear saturation mapping $z_i = f_{z_i}(S_i)$ from solar irradiance $S_i$ to local participation limits. In our RL formulation, solar irradiance / active power $P_i$ similarly acts as a time-varying constraint bounding available reactive headroom $|Q_i| \le \sqrt{S_{\max, i}^2 - P_i^2}$.

---

## [3] X. Chen, G. Qu, Y. Tang, S. Low, N. Li (IEEE TSG 2022) — *Reinforcement Learning for Selective Key Applications in Power Systems: Recent Advances and Future Challenges*

### Why This Paper Matters for Our Thesis
This is the foundational survey on RL in power systems. **Section III-B (Voltage Control)**, **Table II**, and **Section IV (Safety, Scalability, Warm-Starts)** provide a direct blueprint for our MDP design, algorithm selection, constraint handling, and optimization-to-RL workflow.

### Key Takeaways for Thesis Design
1. **Fast-Timescale Inverter Volt-VAR MDP Formulation (Section III-B, Eqs. 21–22):**
   * Explicitly distinguishes slow discrete devices (OLTCs, capacitor banks; Eq. 20) from **fast continuous inverter-based DERs** (Eq. 21):
     * State: $s_{\mathrm{fast}} = ((v_i)_{i\in\mathcal{N}}, (P_{ij}, Q_{ij})_{ij\in\mathcal{E}})$
     * Action: $a_{\mathrm{fast}} = (p^{\mathrm{DER}}, q^{\mathrm{DER}}, q^{\mathrm{SVC}})$
   * **High $R/X$ Physics Warning (Footnote 9, p. 11):** In distribution grids, line resistance $R$ and reactance $X$ have comparable magnitudes, meaning standard $P$–$Q$ decoupling fails. Full AC power flow modeling is mandatory, and active power $P$ affects voltage significantly alongside $Q$.
   * **Exogenous Stochasticity (Eq. 22 & Remark 1.3):** Uncontrollable load demands $p^{\mathrm{ex}}, q^{\mathrm{ex}}$ and solar fluctuations make transitions non-time-homogeneous—justifying why model-free/adaptive RL complements fixed analytical controllers.
2. **Reward Design Patterns (Section III-B.2, Eq. 23):**
   * Standard quadratic voltage tracking penalty: $r(s, a) = -\sum_{i\in\mathcal{N}} (v_i - 1)^2$.
   * Alternative deadband formulation: positive reward (+1) inside acceptable bounds (e.g., $\pm 5\%$ / $0.95\text{--}1.05\text{ p.u.}$), negative penalty outside, augmented by reactive power effort or network losses.
3. **Why Policy-Based Actor-Critic + CTDE Beats Value-Based RL (Section II-E.4 & III-B.3):**
   * Value-based methods (DQN, LSPI) require discretizing continuous reactive power actions and generally rely on global states for greedy action selection ($\arg\max_a Q(s, a)$).
   * **Policy-based actor-critic methods (MADDPG, MASAC, MAPPO)** naturally output continuous $q_i^{\mathrm{DER}} = \pi_{i,\theta_i}(o_i^{\mathrm{DER}})$ using **Centralized Training, Decentralized Execution (CTDE)**: a centralized critic accesses full network voltages (including passive nodes) during offline training, while each inverter executes locally using only neighbor/local observations $o_i$.
4. **Warm-Starting RL from Optimization & Domain Knowledge (Sections IV-C.2 & IV-D.1):**
   * Directly supports our **end-of-year milestone** (understanding the problem from the optimization side and extracting a policy on a 1-agent base model before full deep RL):
   * Lists concrete warm-start strategies to drastically reduce sample complexity: (i) pre-training / imitation learning from an optimal power flow (OPF) or incumbent controller, (ii) encoding voltage sensitivity / domain structure into policy initialization, and (iii) hybrid serial/parallel integration of model-based and model-free control (citing [192], [195]).
5. **Evaluating Network Depth & Architecture Simplicity:**
   * Relevant to our meeting question (*"We need to see how deep the learning is"*): Table II shows that many successful Volt-VAR controllers use compact ANNs (or even linear/radial-basis policies like LSPI [90], which converged in ~30 s on the IEEE 13-bus feeder), alongside sensitivity-guided gradients (Sun et al. [84]) that avoid oversized critic networks.
6. **Constraint Handling & Safety Architectures (Section IV-A & Table II):**
   * Contrasts three mechanisms for apparent power and voltage limits: (i) reward penalties (soft), (ii) Constrained MDPs (Eq. 32: $\max_\pi J(\pi) \text{ s.t. } J^c(\pi) \le d$, e.g., Constrained SAC [93] which converged in $10^4$ samples with near-zero violations vs. $5\times 10^5$ for CPO), and (iii) safety projection layers on top of the actor (Kou et al. [87]).
   * Highlights **localized policies** exploiting fast-decaying spatial voltage sensitivities ([187], [188]) as the mathematical basis for our neighbor-only decentralized observation setup.
7. **Tooling & Benchmarks Mentioned (Section III-E):**
   * Python frameworks (`Gym-ANM`, `PowerGym` specifically for Volt-VAR distribution control, `Stable-Baselines`) vs. `MATLAB Reinforcement Learning Toolbox`.

---

## [4] R. A. Jacob, S. Paul, S. Chowdhury, Y. R. Gel, J. Zhang (Nature Comms 2024) — *Real-time outage management in active distribution networks using reinforcement learning over graphs*

### Why This Paper Matters for Our Thesis
Although focused on outage switching rather than continuous reactive power control, this paper directly tests on a **modified IEEE 13-bus network with grid-forming and grid-feeding DERs** and provides concrete templates for **neighbor-based state representations**, **voltage violation metrics**, and **benchmarking RL against exact convex optimization**.

### Key Takeaways for Thesis Design
1. **Graph & Neighbor-Based State Representation (Pages 4, 6 & Eqs. 5–6):**
   * Models the distribution feeder as a graph $\mathcal{G} = (\mathcal{N}, \mathcal{E})$ where each node $i$ holds local electrical features $\gamma_i = [P_d^i, Q_d^i, P_g^i, Q_g^i, V^i]$.
   * Through $L_e$ graph layers of polynomial degree $K$, each node aggregates information strictly from its **$L_e \times K$-hop neighborhood** (via powers of the graph Laplacian $\mathcal{L}^k$).
   * **Direct Thesis Link:** Provides a rigorous mathematical mechanism for our meeting goal (*"decentralized approach where the agent only knows the voltages of the neighbours"* and *"scalability is key"*), as parameter sharing across nodes makes the policy size independent of total grid bus count $|\mathcal{N}|$.
2. **Ready-to-Use Voltage Violation Metric (Section Results, Eqs. 2–4):**
   * Defines an explicit, normalized per-unit voltage violation metric across all buses and phases:
     $$V_{\mathrm{viol}} = \frac{\sum_{i\in\mathcal{N}} (\Delta V_{\max}^i + \Delta V_{\min}^i)}{3|\mathcal{N}|}$$
     where $\Delta V_{\max}^i = \max(0, V_j^i - \overline{V})$ and $\Delta V_{\min}^i = \max(0, \underline{V} - V_j^i)$.
   * Directly reusable as a standardized evaluation KPI (and reward penalty term) across all buses—especially passive unmeasured nodes.
3. **Optimization Benchmarking Methodology (Section Methods, Eqs. 11–23):**
   * Benchmarks RL policies (both MLP and Graph-RL) against an exact mathematical programming baseline: **Mixed-Integer Second-Order Conic Programming (MISOCP)** via three-phase DistFlow branch-flow equations (Eqs. 19–22).
   * Demonstrates **real-time inference advantage**: ~5 ms for RL on the 13-bus network vs. ~0.23–0.30 s for MISOCP (Table 1), while highlighting that naive MLPs frequently violate operational constraints compared to structure-aware policies.
   * For our thesis, a continuous **SOCP / AC-OPF** baseline provides the theoretical centralized upper bound to benchmark against our decentralized RL agent.
4. **Concrete Simulation Stack & PPO Hyperparameters on IEEE 13-Bus (Page 8, Page 15, Table 2):**
   * Uses Python (`OpenDSSDirect.py` + `NetworkX` + `Stable-Baselines3` PPO) for fast power-flow training (completing $2.0 \times 10^6$ steps cleanly on the 13-bus feeder), validating the "fast quasi-static Python environment for training + detailed validation" workflow.
   * Provides tested 13-bus PPO hyperparameters (Table 2: $N_{\mathrm{steps}} = 5\times 10^4$, $N_{\mathrm{batch}} = 2\times 10^4$, Adam, squared-exponential LR decay starting at $10^{-5}$ with $D_R=3$).

---

## [5] W. H. D. Chan, M. Montazeri, B. Nortmann, F. Bellizio, G. Sansavini (ISGT Europe 2026) — *Decentralized Safe Reinforcement Learning for Demand-Side Flexibility*

### Why This Paper Matters for Our Thesis
ETH Zürich / Empa paper demonstrating a **decentralized, privacy-preserving Safe RL architecture** combining locally trained **Soft Actor-Critic (SAC)** policies with a model-free **Communication-Enabled Adaptive Safety Filter (CE-ASF)** that guarantees hard collective constraint satisfaction while exchanging only minimal scalar intent signals across heterogeneous agents.

### Key Takeaways for Thesis Design
1. **Decentralized SAC + Model-Free Adaptive Safety Filter (`FLEX+ASF`, Sec. III-B/C, Eqs. 6–11):**
   * Each agent trains a local **SAC** policy using normalized states (including cyclical $\sin\theta_t, \cos\theta_t$, previous action $u_{i,t-1}$, and a safety reference $u_{i,t}^{\mathrm{safe}}$) with soft reward penalties (Eq. 8).
   * Because soft rewards alone still leave violations (`2.2%` vs. `24.6%` BAU), an **Adaptive Safety Filter** projects actor outputs onto a shrinking admissible corridor $[u_{i,t}^{\min}, u_{i,t}^{\max}]$ (Eqs. 10–11), guaranteeing **0% hard constraint violations**.
2. **Minimal-Communication Redistribution (`CE-ASF`, Sec. III-D, Eqs. 12–13):**
   * Agents never share local states, bounds, or internal dynamics; they only communicate **scalar deviation intents** ($m_{i,t}^\uparrow, m_{i,t}^\downarrow$, Eq. 12), which a proportional matching rule converts into zero-sum redistribution grants ($\sum_i E_{i,t}^{\mathrm{grant}} = 0$, Eq. 13).
   * Provides a strong conceptual parallel for decentralized inverters exchanging minimal headroom/saturation signals with neighbors without sharing private bus models.
3. **Sim-to-Real / Model-Mismatch Stress Testing (Sec. IV–V, Fig. 7):**
   * Tests robustness by perturbing dynamics parameters only at evaluation time ($\tilde{e}_i = \rho_i e_i, \rho_i \sim \mathcal{U}(0.8, 1.2)$). Under mismatch, non-coordinated `ASF` incurs severe secondary violations (`58.2` degree-hours), whereas `CE-ASF` cuts them by **48%** (`30.5` degree-hours) at identical cost while maintaining exact target compliance—a clean template for evaluating our Python-trained policy against Simulink/parameter mismatch.

---

## [6] Y. Wang, X. Zhang, Q. Hu (Southeast University, 2026) — *Curriculum-based Hybrid-Action Reinforcement Learning for Critical Load Restoration in Distribution Systems*

### Why This Paper Matters for Our Thesis
Although focused on islanded critical load restoration (CLR) rather than grid-connected decentralized Volt-VAR control, this paper evaluates on a **modified IEEE 13-bus unbalanced distribution system** under $[0.95, 1.05]\text{ p.u.}$ voltage limits and provides a concrete **two-stage curriculum learning + Behavior Cloning (BC) warm-start pipeline** that directly maps to our progressive modeling strategy (1-agent/simplified pre-training $\to$ full RL fine-tuning) and to potential future hybrid discrete–continuous extensions (e.g., OLTC/capacitor switching alongside continuous inverter $Q$ control).

### Key Takeaways for Thesis Design
1. **Two-Stage Curriculum Learning & Behavior Cloning (BC) Warm-Start (Section III-B, Eqs. 10–12 & Fig. 3):**
   * Breaks high-dimensional training difficulty by pre-training on a simplified continuous-only task (**Stage I**, fixing discrete load switches via a priority-based greedy rule in Eq. 10 and training with **Evolution Strategies (ES)**), then transferring knowledge across different action spaces via supervised **Behavior Cloning** ($\mathcal{L}_{\mathrm{BC}}(\phi) = \mathbb{E}[-\log \pi_\phi(\hat{a}_t^{II} \mid s_t)]$, Eq. 11), and finally fine-tuning the full task with **PPO** (**Stage II**, Eq. 12).
   * **Direct Thesis Link:** Validates our progressive warm-start roadmap (Phase 1 simplified/1-agent optimization or pre-training $\to$ BC initialization $\to$ Phase 2 full multi-agent RL fine-tuning), preventing random-initialization exploration collapse and poor local optima.
2. **Quadratic Deadband Voltage Penalty & DER Power-Factor Parameterization (Section II-A/B, Eqs. 3c, 4a–4b & Table I):**
   * Enforces statutory $[0.95, 1.05]\text{ p.u.}$ bus voltage bounds via the exact same quadratic deadband penalty as our reward formulation: $\vartheta_t = -\lambda_v \sum_j \left[\max(0, v_j^t - V_{\max})^2 + \max(0, V_{\min} - v_j^t)^2\right]$ (Eq. 3c).
   * Controls DER reactive support via continuous **power factor angles** $\alpha_g \in [0, \pi/4]$ (Table I) alongside active power dispatch, and encodes diurnal cyclicality via trigonometric time-of-day features $\Phi_t = [\sin(\text{hour}(t)\cdot 2\pi/24), \cos(\text{hour}(t)\cdot 2\pi/24)]$ (Eq. 1).
3. **Hybrid Action Policy & Dimension-Normalized PPO Updates (Section III-A, Eqs. 5–9):**
   * Introduces a unified **Bernoulli–Gaussian** policy (with `tanh`-compressed Bernoulli logits for numerical stability) and normalizes joint log-probabilities and KL divergence by action dimension ($\frac{1}{N_d}\sum_i \log p(b_i) + \frac{1}{N_c}\sum_j \log \mathcal{N}(c_j; \mu_j, \sigma_j^2)$, Eqs. 6–7) to avoid gradient imbalance between heterogeneous action groups.
   * **Thesis Relevance:** Provides a ready-to-use formulation if the thesis later incorporates **discrete voltage regulators** (e.g., OLTC taps or switched capacitors) alongside continuous PV inverter reactive power control.
4. **Out-of-Distribution Split & Forecast-Uncertainty Stress Testing (Section IV-A/B & Figs. 3–4):**
   * Uses a strict non-overlapping temporal split (July renewable profiles for training vs. August profiles for testing) and benchmarks Stage II convergence under **0%, 5%, and 10% forecast errors**, showing stable convergence and bounded performance degradation—a clean protocol to adopt for our unseen load/PV stress-testing benchmarks.
   * Notably builds on and cites both **[3]** (Chen et al., 2022) and **[4]** (Jacob et al., 2024).

---

## [7] L. Ortmann, A. Prostejovsky, K. Heussen, S. Bolognani (EPSR, vol. 189, 2020) — *Fully Distributed Peer-to-Peer Optimal Voltage Control with Minimal Model Requirements*

### Why This Paper Matters for Our Thesis
The exact **Online Feedback Optimization (OFO)** foundation behind Mashhood's `D_V` baseline (`[1]`), experimentally validated on a real 400 V three-phase feeder (DTU SYSLAB) under asynchronous peer-to-peer communication.

### Key Takeaways for Thesis Design
1. **Failure of Purely Local Droop (Sec. I & IV-A, Fig. 6):**
   * Experimentally proves IEEE 1547 local Volt-VAR droop fails to resolve overvoltages once one inverter saturates—and upstream inverters can even act **detrimentally** (injecting $Q$ while a downstream bus is in overvoltage), directly justifying neighbor coordination over purely local control.
2. **Peer-to-Peer Feedback Optimization & Neighbor Sparsity (Sec. II-A/B, Eqs. 1–12, Algs. 1–2):**
   * Solves $\min \frac{1}{2}q^T M q$ subject to voltage and reactive power bounds via outer dual ascent on voltage multipliers $\lambda$ (Eq. 4) and an inner $K$-step distributed QP on reactive-limit multipliers $\mu$ (Eq. 9).
   * Defining neighbors via direct electrical paths without intervening inverters (Fig. 2) and choosing $M = X$ makes $G = X^{-1}$ sparse on the neighbor graph (Eq. 12), requiring only peer-to-peer $\mu$ exchange and neighbor impedances.
3. **Limitations Motivating RL (Sec. IV-D/E & V, Tables II–III):**
   * Highlights **integral windup** of $\lambda$ under temporary infeasibility (Fig. 10, locking inverters at saturation for minutes), restriction of the quadratic cost $M = X$ vs. proportional fairness $J_{\mathrm{fair}} = \sum (q_i / q_{i,\max})^2$ (Eq. 13), and scaling reliance on $K \gg 1$ communication steps per actuation step (up to thousands of peer messages for 30–100 nodes, Table III)—bottlenecks that a trained decentralized RL policy avoids at inference time.

---

## [8] P. Moutis, P. S. Georgilakis, N. D. Hatziargyriou (IEEE TSG, vol. 9, no. 4, 2018) — *Voltage Regulation Support Along a Distribution Line by a Virtual Power Plant Based on a Center of Mass Load Modeling*

### Why This Paper Matters for Our Thesis
Cited in `[1]`, this paper provides a clear taxonomy of classical vs. smart-grid distribution voltage regulation methods (Sec. II) alongside an active-power-only VPP heuristic baseline that contrasts directly with fast reactive-power-first RL control.

### Key Takeaways for Thesis Design
1. **Review & Limitations of Classical/OPF Voltage Regulation (Sec. II-B/C, Eqs. 1–2):**
   * Summarizes drawbacks of OLTC/capacitors (slow, mechanical wear, top-down), OPF / voltage-profile minimization $\sum (V_k - V_{\mathrm{sp}})^2$ (full grid telemetry, hunting risk, soft constraints), and Newton-Raphson Jacobian sensitivity methods (require recalculating and inverting the Jacobian after every action).
2. **Center-of-Mass Active-Power Redispatch Heuristic (Sec. III & IV):**
   * Represents absorbed load currents and injected DG currents along a radial feeder (ordered by accumulated impedance $\sum |\tilde{Z}_m|$ via DFS) as negative/positive point masses ($g_L, g_G$, Eq. 4) and iteratively redispatches VPP active power and interruptible loads to minimize $|g_L - g_G|$ (evaluated via Monte Carlo on the 119-bus Rhodes feeder, achieving 82.7%–96.1% success at 500 kW steps).
3. **Thesis Contrast (Sec. III-D2 & V):**
   * Targets slow variations via active power only, relies on online feeder metering, and is non-optimal with step-size-dependent failure rates—reinforcing our continuous **reactive-power-first** decentralized RL design with active curtailment only as a last resort.

---

## [9] S. Stradowski, L. Madeyski (Information and Software Technology, vol. 159, 2023) — *Industrial applications of software defect prediction using machine learning: A business-driven systematic literature review*

### Why This Paper Matters for Our Thesis
Authored by our WUST research contact **Dr. Szymon Stradowski**. Although focused on industrial ML in software engineering (5G testing at Nokia), it provides a strong **methodological template** for structuring a systematic literature review and designing practically deployable, benchmarked ML/RL engineering studies.

### Key Takeaways for Thesis Design
1. **Systematic Literature Review Protocol (Sec. 1.2, Sec. 2 & Appendix B):**
   * Uses Goal-Question-Metric (**GQM**) research questions, transparent multi-database search strings + snowballing across IEEE/ACM/Scopus/ScienceDirect/Springer/Google Scholar, and **SEGRESS** reporting checklists—a direct template for a rigorous thesis literature review chapter.
2. **Engineering Deployment Priorities Over Raw Complexity (Sec. 4.1 & 4.2):**
   * Concludes from 32 industrial studies and practitioner feedback that real-world adoption prioritizes **low error rates, interpretability/XAI, minimal already-available features, and clean multi-model benchmarking** over squeezing marginal gains from bloated models—directly reinforcing our **network-depth ablation** and **local/neighbor observation design**.
3. **Reproducibility & Empirical Rigor (Sec. 4.2 & 4.3):**
   * Recommends staged validation on open academic benchmarks prior to proprietary/complex environments, reporting computational/implementation overhead, and including structured **Threats to Validity** and **Lessons Learnt** sections.

---

## [10] S. Satsangi, G. B. Kumbhar (CSEE JPES, vol. 8, no. 5, 2022) — *Energy Savings Estimation of a Distribution System in Presence of Intelligent Volt-VAr Control Based on IEEE Std. 1547-2018*

### Why This Paper Matters for Our Thesis
Secondary supporting reference documenting the exact **IEEE Std. 1547-2018** local Volt-VAR ($Q(V)$) curve and reactive capability formulations while illustrating the computational bottleneck of offline metaheuristic curve tuning (**GA + Pattern Search**), cleanly motivating our fast, neighbor-aware decentralized RL controller.

### Key Takeaways for Thesis Design
1. **Ready-to-Use IEEE Std. 1547-2018 Droop & Capability Equations (Sec. III-C/E, Eqs. 5–11, Table II):**
   * Provides the exact 5-segment piecewise-linear Volt-VAR curve ($V^{O1}\text{--}V^{O4} = 0.92, 0.98, 1.02, 1.08\text{ p.u.}$, $Q^{\max} = 0.44\,S^{\text{rated}}$), allowable breakpoint tuning ranges, and active-power-dependent reactive capability curve ($0.05\text{--}0.20\,P^{\text{rated}}$ ramp) for implementing our standard IEEE 1547 droop baseline.
2. **Fixed vs. Optimized Local Curves & Motivation for RL (Sec. III-D & V, Tables I & III–IV):**
   * Shows default local droop underutilizes inverters inside the deadband, whereas optimizing custom per-inverter breakpoints (`OIVVCC`) cuts substation reactive demand by `51.56%` and minimizes tap operations—but requires **~4.5 hours** (`16,135 s`) of centralized GA-PS optimization for one 24-hour day on IEEE-123 and still executes purely locally without neighbor coordination.

---

## Synthesis: Mapping References to Our Thesis Roadmap

| Thesis Task / Design Decision (Nov 13 Meeting) | Primary Reference(s) | Key Takeaway / Method to Apply |
| :--- | :--- | :--- |
| **1. Base IEEE 13-Node Grid & Inverter Abstraction** | **[1]**, **[2]**, **[8]** | Adopt HTW's 4.16 kV modified 13-bus feeder (4 active PV buses: 634, 672, 675, 680; 8 passive buses: 611, 632, 645, 646, 652, 671, 684, 692), treating inverters as stable controlled $P$/$Q$ injections within $S_{\max}$ limits; contrast fast $Q$-first RL against classical OLTC/OPF/active-VPP methods ([8] Sec. II) and [1]'s `LS_V`, `RLS_V`, and `D_V` baselines. |
| **2. End-of-Year Milestone: Optimization Viewpoint & 1-Agent Base Model** | **[3]**, **[4]**, **[6]** | Formulate single-agent voltage control as a continuous OPF / sensitivity optimization problem first ([3] Sec. IV-C/D, [4] DistFlow Eqs. 19–22) and use a two-stage curriculum + Behavior Cloning warm-start ([6] Eqs. 10–12) for cross-stage transfer to full RL. |
| **3. Decentralized Neighbor-Only Observations & Scalability** | **[3]**, **[4]**, **[5]**, **[7]**, **[9]** | Limit agent observations to local + neighboring bus voltages ([3] fast-decaying sensitivities; [4] $k$-hop graph neighborhoods; [7] electrical neighbor sparsity of $G = X^{-1}$), adopt minimal scalar coordination intents ([5] `CE-ASF`), and evaluate lightweight/interpretable architectures over oversized models ([9] Sec. 4.2). |
| **4. Apparent Power ($S_{\max}$) & Voltage Safety Constraints** | **[3]**, **[5]**, **[6]**, **[7]** | Enforce $|Q_i| \le \sqrt{S_{\max, i}^2 - P_i^2}$ via action clipping/projection ([3] Sec. IV-A) or power-factor angle parameterization ([6] Table I), and voltage bounds via quadratic deadband penalties ($\vartheta_t$, [6] Eq. 3c), shrinking-corridor adaptive safety filters ([5] `CE-ASF`), and comparisons against peer-to-peer OFO without integral windup ([7] Sec. IV-D). |
| **5. Unmeasured Passive Nodes (Future State Observer)** | **[1]**, **[3]**, **[4]** | Evaluate global voltage violations across all buses using $V_{\mathrm{viol}}$ ([4] Eq. 4) during centralized critic training (CTDE, [3]), and investigate adding a state observer if passive nodes remain under-regulated. |
| **6. Centralized vs. Decentralized Benchmarking & Thesis Methodology** | **[1]**, **[3]**, **[4]**, **[5]**, **[6]**, **[7]**, **[9]**, **[10]** | Benchmark decentralized RL against: (a) IEEE 1547-2018 droop ([10] Eq. 5, Table II) & [1]/[7] `D_V` OFO, (b) [1]'s `LS_V` and `RLS_V`, (c) a centralized RL agent, and (d) an exact centralized OPF/SOCP upper bound ([4]), using non-overlapping temporal splits ([6]), model-mismatch perturbations ([5] Fig. 7), and a GQM/threats-to-validity structure ([9]). |
