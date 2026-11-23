# Strategic Design Decisions Log

**Thesis:** Reinforcement Learning for Decentralized Voltage Regulation in the IEEE 13-Node Distribution Grid   
**Last Updated:** November 15, 2026

---

## Decision Summary Matrix

| ID | Strategic Dimension | Decision / Proposal Summary | Status |
| :--- | :--- | :--- | :--- |
| **SD-01** | Control Boundary | Supervisory $Q_g(t)$ regulation only; inner inverter loops assumed stable | ✅ **Locked-In** |
| **SD-02** | Reward Structure | Deadband MSE + $\alpha \cdot L_\infty$ worst-bus penalty ($R_{\text{viol}}$) + secondary $Q$/curtailment cost ($R_{\text{cost}}$) | ✅ **Locked-In** |
| **SD-03** | Apparent Power Constraint | Hard enforcement of $\|Q_g(t)\| \le \sqrt{S_{g,\text{rated}}^2 - P_g(t)^2}$ via normalized `tanh` output scaling | ✅ **Locked-In** |
| **SD-04** | Observation Space & Decentralization | Local bus + immediate neighbors only; normalized observation vector $o_g(t)$ | ✅ **Locked-In** |
| **SD-05** | Training Paradigm & Baselines | CTDE (centralized critic over all $\mathcal{P}$ buses) benchmarked against a Centralized RL agent | ✅ **Locked-In** |
| **SD-06** | Progressive Modeling & Algorithms | Phase 1: 1-agent OPF warm-start $\to$ TD3/SAC; Phase 2: MATD3 / MASAC & MAPPO | 💡 **Proposed — To Confirm** |
| **SD-07** | Network Depth Study | 4-tier ablation: Droop/Baseline `[1]` $\to$ Linear/Shallow $\to$ 2-layer MLP ($64\times 64$) $\to$ Deep MLP / $K$-hop GNN | 💡 **Proposed — To Confirm** |
| **SD-08** | Two-Stage Simulation Workflow | Fast quasi-static Python environment (`pandapower` / `OpenDSS`) for training + Simulink validation | 💡 **Proposed — To Confirm** |
| **SD-09** | Unmeasured Passive Nodes | Implicit regulation via CTDE critic first; attach local State Observer $\hat{V}_{\text{passive}} = \psi(o_g)$ if needed | 💡 **Proposed — To Confirm** |
| **SD-10** | Safe RL Upgrade Path | Baseline via SD-02 + SD-03; optional QP sensitivity safety filter or CMDP Lagrangian after `[5]` | 💡 **Proposed — To Confirm** |
| **SD-11** | Benchmarking & Reproducibility | Multi-seed evaluation against Mashhood's 3 methods `[1]`, Volt-VAR droop, Centralized RL, and OPF | 💡 **Proposed — To Confirm** |

---

## Detailed Strategic Decisions

### SD-01 — Supervisory Control Boundary & Inverter Abstraction ✅ Locked-In
* **Decision:** Inner current/voltage inverter control loops are **excluded** from the thesis scope. All inverters $g \in \mathcal{G}$ are assumed internally stable (as modeled at the plant level in [Schulte et al., 2026]).
* **Control Interface:** The RL controller operates at the supervisory layer, deciding reactive power setpoints $Q_g(t)$ alongside the exogenous/reference active power $P_g(t)$ to maintain nodal voltages across the feeder.
* **Rationale:** Keeps the state-action dynamics focused on network-level voltage coupling ($\Delta V \approx S_{VQ}\Delta Q + S_{VP}\Delta P$) without getting bogged down in kHz switching transients.

---

### SD-02 — Step-by-Step Reward Structure ($r_t$) ✅ Locked-In
* **Decision:** At each control interval $t$, the scalar reward $r_t$ combines a primary voltage violation penalty $R_{\text{viol}}(t)$ and a secondary operational cost $R_{\text{cost}}(t)$:

$$r_t = -\left(w_1 \cdot R_{\text{viol}}(t) + w_2 \cdot R_{\text{cost}}(t)\right)$$

#### 1. Primary Voltage Violation Penalty ($R_{\text{viol}}(t)$)
Evaluated over all monitored buses $p \in \mathcal{P}$ (both active inverter nodes and passive load nodes) against the statutory $\pm 5\%$ deadband $[0.95, 1.05]\text{ p.u.}$:

$$R_{\text{viol}}(t) = \frac{1}{\vert{}\mathcal{P}\vert{}} \sum_{p \in \mathcal{P}} \left[ \max(0, V_p(t) - 1.05)^2 + \max(0, 0.95 - V_p(t))^2 \right] + \alpha \cdot \max_{p \in \mathcal{P}} \left( \max(0, V_p(t) - 1.05) + \max(0, 0.95 - V_p(t)) \right)$$

* **Why both terms matter:**
  * The **mean-squared deadband term** provides smooth gradients across all buses and drives zero penalty once every bus is inside $[0.95, 1.05]\text{ p.u.}$
  * The **$\alpha \cdot L_\infty$ worst-bus peak term** prevents the agent from sacrificing a single remote passive bus at the end of a lateral branch just to improve the network average.

#### 2. Secondary Operational Cost ($R_{\text{cost}}(t)$)
Because $R_{\text{viol}}(t) = 0$ everywhere inside the deadband, a small secondary objective ($w_1 \gg w_2$) ensures a unique, physically efficient optimal action when all voltages are compliant:

$$R_{\text{cost}}(t) = R_{Q}(t) + \lambda \cdot R_{\text{curt}}(t)$$

* **Reactive power effort / Inverter losses:**
  $$R_{Q}(t) = \frac{1}{\vert\mathcal{G}\vert} \sum_{g \in \mathcal{G}} \left(\frac{Q_g(t)}{S_{g,\text{rated}}}\right)^2$$
  *(Minimizes unnecessary reactive power circulation and converter/line copper losses when voltage is already safe.)*

* **Active power curtailment (if applicable):**
  $$R_{\text{curt}}(t) = \frac{1}{\vert\mathcal{G}\vert} \sum_{g \in \mathcal{G}} \frac{P_{g,\text{avail}}(t) - P_g(t)}{P_{g,\text{rated}}}$$
  *(With $\lambda_{\text{curt}}$ chosen high enough relative to $R_Q$ so the agent exhausts reactive power $Q$ first and only curtails active power $P$ as a last resort to prevent overvoltage.)*

* **Weight Hierarchy:** Choose $w_1 \gg w_2$ (for example, $w_1 \in [10, 100]$, $w_2 = 1$) so the agent never trades a voltage violation for marginal savings in $Q$ effort. *(Exact $w_1, w_2, \alpha, \lambda$ values to be calibrated during Phase 1 on the 1-agent base model.)*

---

### SD-03 — Hard Apparent Power Constraint ($S_{g,\text{rated}}$) ✅ Locked-In
* **Constraint:** Every inverter $g \in \mathcal{G}$ must strictly obey its circular apparent power limit at all times:
  $$|Q_g(t)| \le Q_{g,\max}(t) = \sqrt{S_{g,\text{rated}}^2 - P_g(t)^2}$$
* **Hard Scaling by Construction (Reactive-Only Mode):** Rather than relying on reward penalties for $S_{\text{rated}}$ violations, the actor outputs a normalized dimensionless signal $\tilde{a}_g(t) \in [-1, 1]$ (via a `tanh` output layer), which is multiplied by the instantaneous reactive headroom:
  $$Q_g(t) = \tilde{a}_g(t) \cdot \sqrt{S_{g,\text{rated}}^2 - P_g(t)^2}$$
* **General Two-Action Formulation (with Active Power Curtailment):** When active power curtailment is enabled alongside reactive power support, the actor outputs two normalized actions per inverter $g$:
  1. $\tilde{a}_{g,P}(t) \in [0, 1]$ **(Active Power Action):** Controls the fraction of available solar/wind active power $P_{g,\text{avail}}(t)$ that inverter $g$ injects into the grid (typically via a `sigmoid` output head or a shifted `tanh` mapped from $[-1, 1] \to [0, 1]$).
  2. $\tilde{a}_{g,Q}(t) \in [-1, 1]$ **(Reactive Power Action — written as $\tilde{a}_g(t)$ in the main formula):** Controls the fraction of remaining reactive headroom used for inductive ($< 0$) or capacitive ($> 0$) support via a `tanh` output head.

  The physical setpoints are then computed sequentially in two steps:
  1. **Compute Active Power:**
     $$P_g(t) = \tilde{a}_{g,P}(t) \cdot P_{g,\text{avail}}(t)$$
  2. **Compute Remaining Reactive Headroom & Reactive Power:**
     $$Q_g(t) = \tilde{a}_{g,Q}(t) \cdot \sqrt{S_{g,\text{rated}}^2 - P_g(t)^2}$$
* **Rationale:** Guarantees 100% inverter hardware safety ($P_g(t)^2 + Q_g(t)^2 \le S_{g,\text{rated}}^2$) by construction during random exploration, training, and deployment.

---

### SD-04 — Decentralization & Local Observation Space ($o_g(t)$) ✅ Locked-In / 💡 Vector Proposal
* **Decision:** Scalability and minimal communication overhead are primary objectives. During online execution, each agent $g \in \mathcal{G}$ observes **only local and immediate electrical neighbor measurements**, never wide-area grid states.
* **💡 Proposed Normalized Observation Vector $o_g(t)$:**
  $$o_g(t) = \left[\ \tilde{V}_g(t),\ \{\tilde{V}_j(t)\}_{j \in \mathcal{N}_g},\ \frac{P_g(t)}{S_{g,\text{rated}}},\ \frac{Q_g(t-1)}{S_{g,\text{rated}}},\ \frac{\sqrt{S_{g,\text{rated}}^2 - P_g(t)^2}}{S_{g,\text{rated}}}\ \right]$$
* **Why Every Feature is Normalized to $[-1, 1]$:** Neural networks train poorly when inputs sit on wildly different numerical scales (e.g., per-unit voltages around $1.00\text{ p.u.}$ with tiny $0.01$ variations vs. power in hundreds of $\text{kW}$).
  * **Voltage Centering & Scaling ($\tilde{V}_k(t) = \frac{V_k(t) - 1.0}{0.05}$):** Raw per-unit ($\text{p.u.}$) voltages $V_k(t)$ only vary between $0.95$ and $1.05\text{ p.u.}$—a tiny $0.10$ band around $1.0\text{ p.u.}$ Subtracting $1.0$ and dividing by $0.05$ maps the compliant deadband directly onto $[-1, +1]$, giving the first layer of the neural network strong, well-conditioned gradients right where precision matters most.
  * **Rating Normalization ($/ S_{g,\text{rated}}$ for the 3 Power Components):** Dividing $P_g(t)$, $Q_g(t-1)$, and the instantaneous reactive headroom $\sqrt{S_{g,\text{rated}}^2 - P_g(t)^2}$ by the inverter's own apparent power rating $S_{g,\text{rated}}$ bounds all three power terms cleanly inside $[-1, 1]$ and makes the policy **hardware-agnostic** (a single trained policy network can control a $15\text{ kVA}$ residential rooftop inverter and a $500\text{ kVA}$ commercial inverter using the exact same weights).
* **Open Sub-Decision:** Define the exact neighbor set $\mathcal{N}_g$ (1-hop vs. 2-hop neighbors, or strictly adjacent active/measured buses) once the topology and measurement placements from `[1]` are confirmed.

---

### SD-05 — Training Paradigm & Centralized vs. Decentralized Comparison ✅ Locked-In
* **Primary Architecture (CTDE — Centralized Training, Decentralized Execution):**
  * **Offline Training:** A centralized critic $Q_w(s_{\text{global}}, \mathbf{a})$ observes all bus voltages $p \in \mathcal{P}$ (including unmeasured passive nodes) and computes $r_t$ from SD-02, providing accurate global credit assignment to the decentralized actors $\pi_{\theta_g}(o_g)$.
  * **Online Deployment:** The critic is discarded; each inverter executes $\pi_{\theta_g}(o_g)$ strictly from its local/neighbor observation $o_g$.
* **Required Thesis Comparison:** Train a **Centralized RL Baseline** (single global agent receiving all bus voltages $\{V_p\}_{p \in \mathcal{P}}$ and outputting $\mathbf{Q} \in \mathbb{R}^{|\mathcal{G}|}$) to directly quantify the **training speed, communication overhead, and voltage regulation accuracy trade-off** agreed with Horst.

---

### SD-06 — Progressive Modeling & Algorithm Roadmap 💡 Proposed — To Confirm
* **Phase 1 — End-of-Year 1-Agent Base Model (Dec 2026):**
  1. Formulate the 1-agent voltage regulation problem as a static **OPF / sensitivity optimization** problem ($\Delta V \approx S_{VQ}\Delta Q + S_{VP}\Delta P$).
  2. Extract an analytical/regression policy (**Behavior Cloning warm-start**) to verify optimal action structure and initialize RL weights.
  3. Train single-agent continuous RL (**TD3** and **SAC** as primary off-policy candidates; **PPO** if simulator speed is very high).
* **Phase 2 — Multi-Agent Decentralized Control (Jan–Mar 2027):**
  * Extend to **MATD3 / MASAC** (sample-efficient off-policy actor-critic, ideal if running coupled to Simulink or medium-speed solvers) and/or **MAPPO** (rock-solid stability on fast vectorized Python power flows).
* **Rationale:** Starting with deterministic optimization on 1 agent de-risks reward scaling ($w_1, w_2, \alpha, \lambda$) before adding multi-agent non-stationarity.

---

### SD-07 — Policy Network Depth & Complexity Study 💡 Proposed - To Confirm
* **Decision:** Explicitly evaluate *"how deep the learning really needs to be"* rather than defaulting to oversized deep networks.
* **💡 Proposed 4-Tier Ablation:**
  * **Tier 0 (Classical):** Local Volt-VAR droop + Mashhood's 3 methods `[1]`.
  * **Tier 1 (Linear / Single-Layer):** Linear or shallow 1-hidden-layer policy (tests whether local voltage sensitivity is nearly linear).
  * **Tier 2 (Compact MLP):** 2 hidden layers $\times$ 32–64 units (`ReLU`/`tanh`).
  * **Tier 3 (Deep / Graph-Based):** Deeper MLP (or recurrent GRU if temporal memory helps under partial observability) and/or $K$-hop Graph Neural Network ([Jacob et al., 2024]) for topology-agnostic scalability.

---

### SD-08 — Two-Stage Simulation Workflow (Python Training + Simulink Validation) 💡 Proposed — To Confirm
* **Proposal:**
  1. **Verify Equivalence:** Once Horst/Felix send the cleaned IEEE 13-node MATLAB/Simulink model, extract exact line impedances, transformer ratios, and load/PV parameters to build a matching fast steady-state/quasi-static replica in Python (`pandapower` or `OpenDSSDirect.py`, as in `[4]`), verifying steady-state voltage parity ($<10^{-4}\text{ p.u.}$ mismatch).
  2. **Train at Scale in Python:** Run rapid multi-seed RL training, hyperparameter sweeps, and network-depth ablations (100x–1000x faster than time-domain Simulink).
  3. **Validate in Simulink:** Deploy the trained actor weights into HTW's MATLAB/Simulink model (via MATLAB Engine API, ONNX/C-code block, or lightweight weight export) to test dynamic response under Mashhood's **load events** `[1]`. *(Optionally fine-tune in Simulink if dynamic interactions create a sim-to-real gap.)*
* **Fallback:** If dynamic grid-forming interactions cannot be decoupled from quasi-static steps, train directly against Simulink via parallel workers (`Parallel Computing Toolbox` / MATLAB Engine).

---

### SD-09 — Unmeasured Passive Nodes & State Observer Strategy 💡 Proposed — To Confirm
* **Proposal:** Follow a two-step escalation strategy:
  1. **Step A (Implicit Handling via CTDE):** First evaluate whether a CTDE critic trained on global $R_{\text{viol}}(t)$ (all $\mathcal{P}$ buses) teaches the decentralized actors $\pi_{\theta_g}(o_g)$ to proactively protect passive nodes through electrical coupling alone.
  2. **Step B (Local State Observer):** If unseen load events cause passive-node violations that neighbor voltages $o_g$ cannot detect, train a lightweight **State Observer** (Luenberger/Kalman observer or small supervised estimator $\hat{\mathbf{V}}_{\text{passive}} = \psi(o_g)$) on offline simulation data and append $\hat{\mathbf{V}}_{\text{passive}}$ to the actor input.

---

### SD-10 — Safe RL Upgrade Path (Incorporating Reference [5]) 💡 Proposed — To Confirm
* **Proposal:**
  * **Baseline Safety:** Guaranteed hardware limits ($S_{g,\text{rated}}$ via SD-03) + worst-bus $L_\infty$ penalty (SD-02).
  * **Advanced Safe RL (after reviewing [5] Chan et al., 2026):** Compare soft penalty tuning against either:
    * **Constrained MDP (Primal-Dual / Lagrangian):** Dynamically tunes $w_1$ (Lagrange multiplier $\lambda$) so expected voltage violations stay below a strict budget $d$ (`[3]` Eq. 32).
    * **Differentiable Safety Layer / QP Filter:** Projects any unsafe RL action $Q_{\text{RL}}$ onto the closest voltage-safe setpoint using the sensitivity matrix $\mathbf{S}_{VQ}$ (`[3]` Table II `[87]`, `[5]`).

---

### SD-11 — Benchmarking & Reproducibility Protocol 💡 Proposed — To Confirm
* **Baselines:** (1) Uncontrolled ($Q=0$), (2) Standard IEEE 1547 Volt-VAR droop, (3) Mashhood's 3 control methods `[1]`, (4) Centralized RL agent, (5) Ideal Centralized AC-OPF upper bound.
* **Test Scenarios:** Mashhood's load events `[1]`, rapid solar cloud transients `[2]`, and unseen load/PV stress scenarios (out-of-distribution generalization).
* **KPIs:** Voltage violation rate (% steps outside $[0.95, 1.05]\text{ p.u.}$), worst-bus peak deviation ($\max |V_p - 1.0|$), mean $R_{\text{viol}}$, total reactive power effort / active power losses, online inference time (ms), and training convergence across $\ge 5$ random seeds.

---

## Pending Inputs Needed to Lock Remaining Decisions
1. **From [1] (Mashhood's Thesis) & Clean Simulink Grid (~2 weeks):** Exact bus list $\mathcal{P}$, active inverter buses $\mathcal{G}$, ratings $S_{g,\text{rated}}$, line $R/X$ values, MATLAB version, and load event definitions.
2. **From [5] (Chan et al., ISGT Europe 2026):** Exact Safe RL formulation to align **SD-10** and finalize how **SD-02** interacts with hard/chance safety constraints.

