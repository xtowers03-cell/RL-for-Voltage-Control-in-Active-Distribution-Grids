# Reinforcement Learning for Decentralized Voltage Regulation in the IEEE 13-Node Distribution Grid

Project overview: motivation, grid architecture, proposed RL formulation, expected challenges, required skills and recommended work setup.

> **Note on sources.** The thesis description only states the objective (develop "a suitable RL formulation and an end-to-end training pipeline") and gives three starting references. Everything marked *(proposal)* below is a design suggestion drawn from the general literature, not something specified in the thesis description. Items marked *(to confirm)* must be clarified with the supervisor or taken from the previous master's thesis [1] and the related paper [2].

---

## 1. Motivation

### 1.1 The problem
- PV inverters are being integrated into distribution grids at a growing rate worldwide, particularly in developing countries.
- Reverse power flow from PV generation raises voltage at the point of connection and along the feeder, causing **voltage distribution issues** (typically overvoltage at midday, possible undervoltage during evening load peaks).
- In some cases the problem is mitigated by **manual adjustment of tap-changing transformers** at the 10/11 kV to 400 V interface. The thesis states this is **not a scalable solution**.

### 1.2 Why manual tap adjustment does not scale
1. **Effort grows with the number of transformers.** A distribution network contains many transformers, and each manual intervention requires personnel and travel time.
2. **It is static, while the problem is dynamic.** Voltage varies over seconds (cloud transients) to hours (daily load cycle). A manually set tap is tuned to an average case and fails at the extremes.
3. **It must be repeated as PV grows.** Each new installation changes the voltage profile, so the intervention effort increases with adoption.
4. **Limited monitoring and staff** in many developing-country grids make manual intervention even less practical.

### 1.3 The proposed alternative
- Use the **PV inverters themselves**, even at low ratings (1-4 kW), to inject or absorb **reactive power** at their connection points.
- In the future, these inverters may also operate in **grid-forming mode**.
- By controlling the **active nodes** (with inverters), the voltage at the **passive nodes** (loads only) is indirectly influenced through the electrical coupling of the network.
- This scales naturally: the more inverters are installed (the cause of the problem), the more regulation capacity is available.

### 1.4 Why reinforcement learning
- Coordinating several inverters by hand-designed rules is difficult: their actions interact, grid parameters are uncertain, and operating conditions change continuously.
- RL can **learn a control policy through interaction with a simulated grid**, without requiring an exact analytical model and without hand-tuning coordination rules.
- A **decentralized** policy (each inverter acting on local information) avoids dependence on a central controller and heavy communication infrastructure.

### 1.5 Context of the work
The project builds on a previous master's thesis [1] (DVPP control for fast voltage control in active distribution) and related research [2] (IEEE 13-node feeder case study for frequency support via distributed virtual power plants), and includes a literature review on RL for active distribution networks (starting references [3]-[5]).

---

## 2. Grid Architecture

### 2.1 The standard IEEE 13-node test feeder
- A benchmark network published by the IEEE PES Distribution System Analysis Subcommittee, widely used to compare analysis and control methods.
- **Nominal voltage:** 4.16 kV, with the source at node 650.
- **Topology:** radial (tree-like), with overhead and underground lines of different lengths and configurations.
- **Loads:** unbalanced across phases (single-, two- and three-phase), modelled as constant power, constant impedance or constant current.
- **Other equipment:** a voltage regulator, shunt capacitor banks and an in-line transformer.
- Small, but demanding: radial, unbalanced and heavily loaded.

### 2.2 The modified grid used in this project
The thesis refers to a **modified 13-node (13-feeder) test grid with four integrated PV systems**, and mentions the 10/11 kV to 400 V interface, which suggests adaptation to a European low-voltage context.

*(to confirm)*:
- Exact voltage levels and which part of the original feeder was modified.
- Locations of the four PV nodes (active nodes).
- Inverter ratings and operating modes (grid-following vs. grid-forming).
- Line parameters, in particular the R/X ratio at 400 V.
- Load and irradiance profiles used in [1] and [2].
- Whether a Simulink model of this grid already exists from [1] and [2].

### 2.3 Active and passive nodes
- **Active nodes:** connection points with a PV inverter that can inject or absorb reactive power (and possibly curtail active power).
- **Passive nodes:** load-only nodes with no control capability, which only experience the voltage.

### 2.4 Why active nodes can influence passive nodes
All nodes are electrically coupled through the line impedances. For a radial feeder, the voltage variation at a node is approximately:

```
ΔV ≈ (R·ΔP + X·ΔQ) / V
```

where R and X are the resistance and reactance of the path to the source, and ΔP, ΔQ are the changes in injected active and reactive power. In linearized form:

```
ΔV = S · ΔQ
```

where `S_ij` is the sensitivity of the voltage at node *i* to reactive power injected at node *j*. Passive nodes that share line sections with an active node have non-zero sensitivity to it, which is the mechanism the project exploits.

Key physical considerations:
- PV active power injection **raises** voltage.
- Absorbing reactive power **lowers** voltage; injecting it **raises** it.
- In low-voltage (400 V) lines the resistance dominates (high R/X), so reactive power is **less effective** than in medium voltage and active power curtailment may be needed as a complement.
- Inverter capability is limited by its apparent power: `P² + Q² ≤ S²`.

---

## 3. Proposed RL Structure *(proposal)*

### 3.1 Problem framing
- Each of the four PV inverters is an **agent**.
- Since each agent only has local information, the problem is a **Dec-POMDP** (decentralized, partially observable Markov decision process).
- Fully cooperative setting: all agents share the objective of keeping all node voltages within limits.

### 3.2 Observations (per agent)
- Voltage at its own connection point
- Own active power output P (depends on irradiance)
- Own current reactive power Q
- Optionally: time of day; voltages of neighbours if limited communication is allowed *(to confirm with supervisor)*

The agents do **not** observe passive-node voltages, which is the central difficulty.

### 3.3 Actions
- **Reactive power setpoint Q**, bounded by `|Q| ≤ √(S² − P²)`.
- Optionally, **active power curtailment**, useful when Q alone is insufficient at 400 V.
- Continuous action space, so suitable algorithms are actor-critic methods (SAC, DDPG, PPO and their multi-agent variants).

### 3.4 Reward
A typical composite design:
- **Voltage violation penalty** over *all* nodes (active and passive), e.g. outside 0.95-1.05 p.u.
- **Control effort penalty** (large Q means higher losses and current).
- **Curtailment penalty**, so the agent does not waste solar energy.

The relative weights are critical: if curtailment is cheap, the agent may learn to curtail permanently.

### 3.5 Training paradigm: CTDE
**Centralized Training, Decentralized Execution:**
- *Training (in simulation):* a centralized critic sees the full grid state, including passive-node voltages, and learns how each agent's action affects the whole network.
- *Execution:* each inverter runs only its local policy using its own measurements.

Candidate algorithms: MADDPG, MAPPO, MASAC. Safe-RL variants (constraint-based instead of pure penalty) are relevant given reference [5].

### 3.6 End-to-end pipeline
1. **Simulation environment** of the modified 13-node grid, wrapped as a Gymnasium-style interface (reset / step / observation / reward).
2. **Scenario generation:** daily load and irradiance profiles with variability (cloud transients, load peaks, different PV penetration).
3. **Training** of the four agents (CTDE).
4. **Evaluation against baselines:** no control, local Volt-VAR droop, centralized optimal power flow (OPF) as an upper bound.
5. **Robustness tests:** unseen scenarios, measurement noise, communication loss, failure of one inverter, parameter mismatch.
6. **Metrics:** voltage violation rate (all nodes), maximum/mean deviation, total reactive power used, curtailed energy, losses, and training sample efficiency.

---

## 4. Potential Problems to Solve

| Problem | Description | Possible approach |
|---|---|---|
| **Partial observability** | Agents cannot see passive-node voltages | CTDE with centralized critic; recurrent policies; limited neighbour communication |
| **Non-stationarity** | Each agent's environment changes as the others learn | Centralized critic, parameter sharing, or training agents sequentially |
| **Safety during training** | Exploration can violate voltage limits | Safe RL (constrained MDP, action projection, shielding) [5] |
| **Reward design** | Trade-off between voltage quality, effort and curtailment | Systematic weight tuning; constrained formulation instead of weighted sum |
| **High R/X ratio at 400 V** | Q is a weak lever; P curtailment may be required | Include P in the action space; analyze sensitivity matrix |
| **Generalization** | Policy may fail on unseen load/irradiance profiles or different PV penetration | Diverse training scenarios; domain randomization; test on held-out cases |
| **Simulation cost** | Time-domain simulation (especially in Simulink) can be slow for RL, which needs millions of steps | Fast steady-state/quasi-static solver for training, detailed model for validation; parallel environments |
| **Fidelity vs. speed** | Dynamic effects (grid-forming inverter, control interactions) vs. quasi-static power flow | Two-stage approach: train on fast model, validate on Simulink |
| **Sim-to-real gap** | Model errors, measurement noise, delays | Noise and parameter randomization during training |
| **Benchmarking** | Fair comparison with Volt-VAR and OPF | Same scenarios and metrics for all methods |
| **Reproducibility** | RL results vary strongly with seeds | Multiple seeds, fixed configs, logged experiments |

---

## 5. Required Skills

### 5.1 Power systems
- Distribution grid fundamentals: radial feeders, per-unit system, power flow, voltage regulation
- Active/reactive power and their effect on voltage; sensitivity analysis
- Inverter behaviour: grid-following vs. grid-forming, Volt-VAR control, capability curve
- Basic understanding of tap-changing transformers and DVPP concepts

### 5.2 Reinforcement learning
- MDP / POMDP formulation, policy gradient and actor-critic methods
- Continuous control algorithms (SAC, DDPG, PPO)
- Multi-agent RL: CTDE, MADDPG/MAPPO, cooperative settings
- Safe RL (constrained MDPs, shielding), reward shaping
- Experiment design and statistical evaluation (seeds, confidence intervals)

### 5.3 Simulation and tooling
- **MATLAB/Simulink** (modelling the grid, running simulations), and ideally **Simscape Electrical** if a detailed model is needed
- **Python** (PyTorch, Gymnasium; Stable-Baselines3, RLlib, or a multi-agent library)
- Optionally **pandapower** or **OpenDSS** as fast power-flow back ends
- Interfacing between Python and MATLAB/Simulink (see section 6)

### 5.4 Software engineering and research practice
- Git and version control, reproducible environments (conda/venv, requirements files)
- Experiment tracking (TensorBoard, Weights & Biases or MLflow)
- Scientific writing and literature review methodology
- Linux/command line and basic GPU/cluster usage if training scales up

---

## 6. Recommended Work Setup

### 6.1 Core question: where does the simulation run?
The main design decision is the simulator, because RL needs a very large number of environment steps.

| Option | Speed | Fidelity | Python integration | Comment |
|---|---|---|---|---|
| **A. Simulink model driven from Python** via the MATLAB Engine API for Python | Slow-medium | High | Moderate, needs a MATLAB licence | Reuses existing models from [1], [2]; good for final validation |
| **B. Simulink model exported as FMU**, run with a Python FMI library (e.g. FMPy) | Medium | High | Good, no MATLAB needed at run time | Export support depends on blocks used (Simscape/solver constraints) *(to verify)* |
| **C. RL entirely in MATLAB** using the Reinforcement Learning Toolbox | Medium | High | Not needed | Simple setup, but a smaller ecosystem than Python, and weaker multi-agent flexibility |
| **D. Python-native grid model** (pandapower or OpenDSS), Gymnasium environment | **Fast** | Medium (quasi-static) | Native | Best for training at scale; Simulink then used only for validation |

### 6.2 Recommended strategy: two-stage workflow
1. **Training environment:** build (or port) a fast quasi-static model of the modified 13-node grid in Python (pandapower or OpenDSS) and train there. This gives thousands of steps per second.
2. **Validation environment:** run the trained policies in the **Simulink** model (option A or B) to verify behaviour with detailed dynamics, and compare with results from [1] and [2].
3. **Consistency check:** verify that the Python and Simulink models agree on steady-state voltages for the same operating points before trusting the trained policy.

If a quasi-static model is judged insufficient (for example because grid-forming inverter dynamics matter), fall back to option A or B for training, using parallel simulation instances to compensate for the speed.

### 6.3 IDE and AI agent: Antigravity
Antigravity is an agent-oriented IDE that can work with AI agents on your codebase. Suggested way to use it for this project:

- Keep **one repository** containing: the Python environment package, training code, config files, evaluation scripts, the Simulink/MATLAB files, and documentation.
- Give the agent a **project context file** (e.g. `PROJECT.md` or `AGENTS.md`) with the grid description, the RL formulation, coding conventions and the folder structure, so its suggestions stay consistent.
- Good tasks to delegate: boilerplate Gymnasium wrappers, config handling, logging and plotting scripts, unit tests, baseline controllers (Volt-VAR), refactoring.
- Tasks to keep under your own control: reward design, physical modelling choices, interpretation of results.
- **Always verify physics**: check agent-written grid code against known cases (e.g. compare against the Simulink steady-state results).

*Caveat:* the MATLAB/Simulink side is a proprietary environment. Antigravity can edit `.m` scripts and Python code, but Simulink models (`.slx`) are binary/XML files that are best edited in the MATLAB GUI. It is practical to let the agent work on Python and MATLAB scripts, and to use MATLAB only for model editing and for running validation. Whether Antigravity offers dedicated MATLAB/Simulink support should be checked in its current documentation *(to verify)*.

### 6.4 Alternatives worth considering
- **VS Code (or a fork) with an AI coding agent** plus the official MATLAB extension, which gives decent MATLAB script support in the same editor as Python.
- **MATLAB Desktop for Simulink work** alongside any IDE for Python. This split is common and works well because Simulink editing is graphical anyway.
- If the Simulink model can be **replaced** by a Python-native one without losing what the thesis needs, that is the lowest-friction setup, but this should be agreed with the supervisor because the previous work [1], [2] is presumably built in Simulink *(to confirm)*.

### 6.5 Suggested repository structure
```
project/
├── PROJECT.md              # context for humans and AI agents
├── env/                    # Gymnasium environment (grid model wrapper)
├── grids/                  # grid definitions (pandapower/OpenDSS) and data
├── simulink/               # Simulink models and MATLAB scripts
├── agents/                 # RL algorithms and policies
├── baselines/              # no-control, Volt-VAR, OPF
├── scenarios/              # load and irradiance profiles
├── configs/                # experiment configurations
├── experiments/            # training and evaluation scripts
├── results/                # logs, figures, tables
├── tests/                  # unit and consistency tests
└── docs/                   # literature notes, thesis drafts
```

### 6.5 Practical tips
- Pin versions (Python, PyTorch, MATLAB release) so Simulink/Python interfaces keep working.
- Check early whether your MATLAB licence includes the toolboxes you need (Simulink, Simscape Electrical, Reinforcement Learning Toolbox, Parallel Computing Toolbox).
- Log every experiment with its config and seed.
- Start simple: single agent, Q-only, a fixed scenario; then add agents, curtailment and scenario diversity step by step.

---

## 7. Suggested First Steps

1. Read [1] and [2] to obtain the exact grid parameters, PV locations and the existing Simulink model.
2. Read the three starting references [3]-[5], taking notes on state/action/reward choices.
3. Reproduce the uncontrolled grid voltage profile (baseline) and identify where violations occur.
4. Compute the sensitivity matrix `S` to see which active nodes influence which passive nodes.
5. Implement the Volt-VAR droop baseline.
6. Build the Gymnasium environment and train a first single-agent controller.
7. Extend to four agents with CTDE and compare against the baselines.
8. Validate on the Simulink model and test robustness.

---

## References (from the thesis description)

1. M. B. Abdul Mughni, *DVPP Control for Fast Voltage Control in Active Distribution*, Master Thesis, DREAM Programme, August 2026.
2. H. Schulte, J. Brunner, M. Wypych, "Frequency Control of Low-inertia Power Grids via DVPP-based support from Distribution Networks: An IEEE 13-node Feeder Case Study," IEEE PES ISGT Europe 2026, Budapest, Hungary.
3. X. Chen, G. Qu, Y. Tang, S. Low, N. Li, "Reinforcement learning for selective key applications in power systems: Recent advances and future challenges," IEEE Trans. Smart Grid, vol. 13, no. 4, pp. 2935-2958, 2022.
4. R. A. Jacob, S. Paul, S. Chowdhury, Y. R. Gel, J. Zhang, "Real-time outage management in active distribution networks using reinforcement learning over graphs," Nature Communications, vol. 15, no. 1, p. 4766, 2024.
5. W. H. D. Chan, M. Montazeri, B. Nortmann, F. Bellizio, G. Sansavini, "Decentralized Safe Reinforcement Learning for Demand-Side Flexibility," IEEE PES ISGT Europe 2026, Budapest, Hungary.
