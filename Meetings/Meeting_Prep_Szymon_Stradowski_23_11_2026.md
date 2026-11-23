# Meeting Prep: Dr. Szymon Stradowski (WUST)

* **Date:** November 23, 2026
* **Contact:** Dr. inż. Szymon Stradowski — Wrocław University of Science and Technology (WUST / PWr) & Nokia
* **Introduction:** Referred on Nov 18, 2026 by **Prof. Adrianna Kozierkiewicz** (Deputy Head, Dept. of Applied Informatics, Faculty of ICT, WUST) as their team's RL expert for potential research collaboration.
* **Context Already Shared:** He received your 2-page refined Master's Thesis proposal PDF via email.
* **Links:** [LinkedIn Profile](https://www.linkedin.com/in/szymon-stradowski-362057155/) | [ResearchGate Profile](https://www.researchgate.net/profile/Szymon-Stradowski)

---

## 1. Profile & Background Summary

* **Academic Affiliation & Education:**
  * **Ph.D. (Doctor of Engineering)** in Technical Computer Science & Telecommunications / Software Engineering from **Wrocław University of Science and Technology (WUST)** (defended 2025, supervised by Prof. Lech Madeyski).
  * **Doctoral Dissertation:** Applying machine learning to improve software manufacturing quality and cost-efficiency for 5G systems in an industrial setting (Nokia).
  * **MBA** from Franklin University (Ohio, USA).
  * Affiliated with the **Department of Applied Informatics / Institute of Informatics** at WUST.
* **Industry Background:**
  * **15+ years** in software engineering, commercial system-level testing, project/quality management, and large-scale AI/ML deployment in wireless telecommunications.
  * **Nokia (Wrocław):** Project Office Manager (Mobile Infrastructure / RF Project Office), focused on 5G software development, testing optimization, and practical industrial AI integration.
* **Core Research Themes:**
  * **Applied & Industrial ML:** Bridging the gap between academic AI models and real-world engineering deployment (cost–benefit trade-offs, lightweight alternatives to overly complex models).
  * **Explainable AI (XAI) & Practitioner Trust:** Making AI decisions interpretable and managing false positives / reliability in high-stakes industrial workflows.
  * **Software Engineering AI, RL & Agents:** ML/RL for software defect prediction and test failure prediction (including RL-based feature selection and recent synthesis work on autonomous agents, LLMs, and RL for adaptive testing).
  * **Empirical Research Rigor:** Systematic literature reviews/mapping studies and industrial case studies in top venues.
* **Selected Recent Publications (2023–2025):**
  * *"Interpretability/Explainability Applied to Machine Learning Software Defect Prediction: An Industrial Perspective"*, **IEEE Software** (2025).
  * *"Predicting test failures induced by software defects: A lightweight alternative to software defect prediction and its industrial application"*, **Journal of Systems and Software** (2025).
  * *"'Your AI is impressive, but my code does not have any bugs' — Managing false positives in industrial contexts"*, **Science of Computer Programming** (2025).
  * *"Costs and Benefits of Machine Learning Software Defect Prediction: Industrial Case Study"*, **ACM FSE Companion** (2024).
  * *"Bridging the gap between academia and industry in machine learning software defect prediction: thirteen considerations"*, **ACM/IEEE ASE** (2023).
  * *"Industrial applications of software defect prediction using machine learning: A business-driven systematic literature review"*, **Information and Software Technology** (2023).

### Why He Is a Great Match for Your Thesis
* Your current supervision team (**HTW Berlin** + **UNSTPB**) brings deep **power systems & control** expertise, while explicitly noting they are **not RL specialists**.
* Szymon brings complementary **applied AI/RL engineering rigor**: lightweight vs. deep model trade-offs, explainability/trustworthiness for engineers, structured benchmarking, and strong publication track record.

---

## 2. Simple Meeting Script (Points to Cover)

### 1. Opening & Icebreaker (2 min)
* Thank him for making time after Prof. Kozierkiewicz's introduction.
* Mention that you are an EMJM DREAM student currently taking Prof. Kozierkiewicz's course and starting your Master's thesis on RL for voltage control.
* Ask if he had a chance to glance at the proposal PDF (and offer a quick 2-minute summary either way).

### 2. Brief Overview of Your Thesis & Current Stage (3–4 min)
* **Problem:** Decentralized supervisory voltage regulation in an IEEE 13-node distribution feeder with 4 PV inverters, keeping all active and passive buses within 0.95–1.05 p.u.
* **Control Setup:** Inner inverter dynamics are assumed stable; RL acts at the supervisory layer setting reactive power $Q$ (and active power curtailment only as a last resort) while guaranteeing circular apparent power limits by construction.
* **Core Research Angles:**
  * **CTDE (Centralized Training, Decentralized Execution)** using only local + neighbor voltages online, benchmarked against a **centralized RL** agent.
  * Testing **how complex/deep the policy network actually needs to be** (simple/lightweight vs. deeper architectures).
  * **Supervision Setup:** Official university supervisor at **UNSTPB** (Prof. Irina-Ioana Picioroagă) + external grid/control partners at **HTW Berlin** (Prof. Horst Schulte & Felix Dietrich), who are power/control specialists rather than RL specialists.
* **Where You Are Now:** Proposal finalized; waiting on the cleaned IEEE 13-node MATLAB/Simulink model from HTW Berlin (~end of November); planning to start in December with a simplified **1-agent optimization & RL prototype**.

### 3. Learn About His Background & RL Interests (3–5 min)
* Ask about his current work with **reinforcement learning** (at WUST or Nokia) and what kind of RL problems/methods he focuses on.
* Ask what caught his attention in the proposal or where he sees potential overlap with his research interests.

### 4. Key Technical Topics to Bounce Off Him (5–10 min)
*(Pick the ones that flow naturally in the conversation)*
* **RL Algorithm Selection & Practicality:** Thoughts on starting with single-agent continuous control (e.g., TD3/SAC) and scaling to CTDE multi-agent (MATD3/MASAC vs. MAPPO) when balancing simulator speed vs. sample efficiency.
* **Lightweight & Explainable Policies (connects to his XAI / lightweight ML work):** Since grid operators care heavily about reliability and transparency—and HTW wants to evaluate how deep the learning really needs to be—does he see value in adding an **explainability / policy interpretability** angle or comparing lightweight vs. deep policies?
* **Safe & Reliable Deployment:** Advice on handling safety constraints (hard action scaling + reward shaping vs. safety layers / Constrained MDPs) and structuring clean, publishable empirical benchmarks.

### 5. Collaboration Format & Next Steps (3–5 min)
* **Clarify Expectations:** Ask what form of collaboration would be mutually valuable and realistic for him:
  * Periodic RL technical feedback / advisory check-ins as you build the pipeline?
  * Potential **joint publication** (e.g., IEEE conference or journal paper combining the power-grid case study with strong RL/XAI evaluation) once results mature?
* **Note on IP / Coordination:** Mention transparently that you will align with your supervisors at HTW Berlin and UNSTPB before sharing their grid simulation model or formalizing any co-authorship.
* **Concrete Next Step:** Suggest reconnecting once you have your 1-agent base prototype / optimization formulation running (e.g., late December / January) — or sooner if he recommends specific RL papers, tools, or ideas to read first.
