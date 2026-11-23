# Meeting Takeaways: Thesis Kick-off & Scope Alignment

* **Date:** November 13, 2026
* **Participants:** Xavier Gonzalez Torres, Prof. Horst Schulte, Felix
* **Topic:** Master's Thesis — Reinforcement Learning for Decentralized Voltage Regulation in the IEEE 13-Feeder Distribution Grid

---

## 1. Supervision, Topic Confirmation & Administrative Setup

* **Topic Confirmed:** Agreed to proceed with **Reinforcement Learning for Decentralized Voltage Regulation** in active distribution grids.
* **Supervision Structure:**
  * **Official Supervisor:** Lucian (university side).
  * **External Partners:** Prof. Horst Schulte and Felix Dietrich (HTW Berlin).
  * **Submission Workflow:** Xavier will refine the thesis proposal (1–2 pages) and send it to Horst, who will review and forward it to Bogdan.
  * **Deadline for Proposal:** End of November 2026.
* **Collaboration & Expertise:** Horst and Felix are not RL specialists themselves, though they are keen to learn in parallel (Felix has prior experience with Physics-Informed Neural Networks). Regular supervisor check-in meetings are agreed upon.

---

## 2. Technical Scope & Modeling Decisions

* **Inverter Abstraction:** Inner inverter control dynamics are **not** the focus of the thesis. Inverters are assumed to be fully stable; the RL agent regulates grid voltage strictly by determining the **reactive power ($Q$)** injection/absorption alongside the reference **active power ($P$)**.
* **Physical Constraints:** Control actions are bounded by the inverter's **apparent power** rating ($S_{\max}$).
* **Decentralized Architecture & Minimal Communication:**
  * **Scalability** and **reduced communication overhead** are central priorities.
  * Voltage measurement placement is a key design question.
  * Under the **decentralized approach**, each agent only observes the voltages of its neighboring nodes.
* **Unobserved Nodes & State Estimation:** A **state observer** may be added in a later stage to estimate voltages at unmeasured (passive) nodes.
* **Benchmarking & Learning Depth:**
  * Compare the decentralized policy against a **centralized approach** (slower to train, but serves as a higher-accuracy benchmark).
  * Evaluate how deep the neural network architecture actually needs to be for this control task.
* **Previous Work Context (Mashhood's Thesis):** Evaluated 3 control methods and tested the system under **load events**.

---

## 3. Action Items & Next Steps

| Timeline | Owner | Action Item |
| :--- | :--- | :--- |
| **Immediate** | Xavier | Send follow-up email with a reminder for the requested references and confirm the required MATLAB version. |
| **In ~2 weeks (~late Nov)** | Horst / Felix | Clean and send the IEEE 13-node grid simulation project (ensuring only a clean, relevant project package is shared). |
| **By Nov 30, 2026** | Xavier | Refine and submit the **1–2 page thesis proposal** to Horst (to be forwarded to Bogdan). |
| **By end of the year (Dec 2026)** | Xavier | Analyze the problem from an optimization perspective; study policy extraction and build a simplified **1-agent base model** to start prototyping. |

### Checklist to Track
- [ ] Send follow-up email to Horst and Felix (summary + reference request + MATLAB version check).
- [ ] Receive Mashhood's Master's thesis [1] and the Chan et al. ISGT Europe 2026 Safe RL paper [5].
- [ ] Receive the cleaned MATLAB/Simulink grid model (~2 weeks).
- [ ] Deliver refined 1–2 page thesis proposal to Horst before the end of November.
- [ ] Frame the voltage regulation problem mathematically from an optimization viewpoint and build a simplified 1-agent testbed (by end of the year).

