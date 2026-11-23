# Master Thesis Proposal

## Reinforcement Learning for Decentralized Voltage Regulation in the IEEE 13-Node Feeder Distribution Grid

### Environment

The thesis will be conducted in collaboration with the Control Engineering and Power Systems research group at HTW Berlin, building upon their active distribution grid modeling and simulation environment.

### Description of the subject

The growing integration of PV inverters into distribution grids is leading to voltage distribution issues worldwide, particularly in developing countries. In some cases, manual adjustment of tap-changing transformers at the interfaces between the 10/11 kV and 400 V levels is used to mitigate these problems.

However, this is not a scalable solution. The basic idea is to use PV inverters, which in the future may also operate in grid-forming mode, even at low power ratings of 1–4 kW, to inject or absorb reactive power in a targeted manner at their connection points. In this work, inner inverter control loops are assumed to be internally stable; the reinforcement learning (RL) controller operates strictly at the supervisory layer, determining reactive power setpoints (and active power curtailment only as a last resort) within each inverter's circular apparent power capability $|Q_g(t)| \le \sqrt{S_{g,\text{rated}}^2 - P_g(t)^2}$. This enables smart, fast, and hardware-safe voltage regulation across the distribution grid by controlling the active inverter nodes in order to maintain all active and passive nodes within statutory voltage limits (0.95–1.05 p.u.).

Building on the results of a previous master's thesis [1] and related research projects [2], this work investigates the potential of reinforcement learning methods for decentralized supervisory voltage regulation in a modified IEEE 13-node feeder distribution grid with four integrated solar PV systems. Specifically, the RL formulation is structured around the following core principles:

* **Centralized Training with Decentralized Execution (CTDE) & Centralized Baseline:** Offline training uses a centralized critic that observes all monitored active and passive buses to guide decentralized actors, which will be compared against a centralized RL agent to quantify the trade-off between communication overhead, training speed, and voltage regulation accuracy.
* **Decentralized Local Observations:** During online operation, each inverter agent relies strictly on normalized local measurements and immediate neighboring node voltages, ensuring minimal communication overhead.
* **Composite Reward & Hard Apparent Power Constraint:** The step-by-step reward $r_t = -(w_1 R_{\text{viol}}(t) + w_2 R_{\text{cost}}(t))$ combines a primary voltage violation penalty across all buses with a secondary operational cost on reactive power effort and active power curtailment, while circular apparent power limits are enforced by construction via normalized output scaling.

### Specific tasks of the student

* Review literature on reinforcement learning and decentralized control approaches for active distribution networks [3]–[5].
* Formulate the supervisory voltage regulation problem from an optimization perspective and develop a physically constrained RL environment and end-to-end training pipeline for the modified IEEE 13-node feeder with four PV systems [1], [2] that guarantees inverter apparent power limits by construction.
* Design and train a scalable, low-communication decentralized control policy under the CTDE paradigm operating strictly on normalized local and neighboring node measurements to maintain all active and passive bus voltages within 0.95–1.05 p.u.
* Evaluate policy network complexity and benchmark the decentralized RL controller against a centralized RL baseline and reference control methods from [1] under load and generation disturbances, quantifying voltage regulation performance, training speed, and communication trade-offs.

### Literature

* **[1]** Mashhood Bin Abdul Mughni, *DVPP Control for Fast Voltage Control in Active Distribution*, Master Thesis, DREAM Programme, August 2026.
* **[2]** H. Schulte, J. Brunner, and M. Wypych, "Frequency Control of Low-inertia Power Grids via DVPP-based support from Distribution Networks: An IEEE 13-node Feeder Case Study," in *Proc. IEEE PES ISGT Europe 2026 (Innovative Smart Grid Technologies)*, Budapest, Hungary, 2026.
* **[3]** X. Chen, G. Qu, Y. Tang, S. Low, and N. Li, "Reinforcement learning for selective key applications in power systems: Recent advances and future challenges," *IEEE Transactions on Smart Grid*, vol. 13, no. 4, pp. 2935–2958, 2022.
* **[4]** R. A. Jacob, S. Paul, S. Chowdhury, Y. R. Gel, and J. Zhang, "Real-time outage management in active distribution networks using reinforcement learning over graphs," *Nature Communications*, vol. 15, no. 1, p. 4766, 2024.
* **[5]** W. H. D. Chan, M. Montazeri, B. Nortmann, F. Bellizio, and G. Sansavini, "Decentralized Safe Reinforcement Learning for Demand-Side Flexibility," in *Proc. IEEE PES ISGT Europe 2026 (Innovative Smart Grid Technologies)*, Budapest, Hungary, 2026.

### Supervisors

* Prof. Dr. Irina-Ioana Picioroagă – Official Supervisor, Professor, UNSTPB.
* Prof. Dr.-Ing. Horst Schulte – External Supervisor, Professor, HTW Berlin.
* Felix Dietrich, M.Sc. – External Co-Supervisor, Research Associate, HTW Berlin.

### Dates

**Start:** February 2027 &emsp;&emsp; **End:** August 2027

---

**Student:** Xavier Gonzalez Torres
