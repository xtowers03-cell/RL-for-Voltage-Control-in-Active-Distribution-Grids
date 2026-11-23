# Reinforcement Learning for Decentralized Voltage Regulation

Research repository for a master's thesis on using multi-agent reinforcement learning to regulate voltage in an active distribution grid with photovoltaic inverters.

## Project overview

The project studies decentralized control of a modified IEEE 13-node distribution feeder with four PV inverter systems. Each inverter should use local measurements, and optionally immediate-neighbor measurements, to coordinate reactive-power support while keeping voltages across both active and passive nodes within acceptable limits.

The planned approach is **centralized training with decentralized execution (CTDE)**:

- A centralized critic can use the full simulated grid state during training.
- Each deployed policy uses only local information available to its inverter.
- Inverter apparent-power limits are enforced by construction.
- Performance will be compared with uncontrolled operation, Volt-VAR control, centralized RL, and optimization-based baselines.

The exact grid parameters, inverter locations, ratings, and simulation interface remain dependent on the previous thesis and the cleaned Simulink model.

## Current status

This repository currently contains project planning, thesis material, literature notes, meeting records, and strategic design decisions. The implementation and training pipeline are planned work.

Locked-in design decisions include:

- Supervisory reactive-power setpoint control; inner inverter loops are out of scope.
- A voltage-violation reward combining deadband error and a worst-bus penalty.
- Hard apparent-power constraints using normalized action outputs.
- Local and immediate-neighbor observations for decentralized execution.
- CTDE with a centralized RL baseline for comparison.

Proposed items still to confirm include the simulator, exact topology and parameters, algorithm selection, network-depth study, and advanced safe-RL methods.

## Planned research workflow

1. Recover and verify the IEEE 13-node grid parameters and PV locations.
2. Reproduce the uncontrolled voltage profile and compute voltage sensitivities.
3. Formulate a one-agent OPF/sensitivity baseline and use it to warm-start RL.
4. Build a fast quasi-static Python environment for training.
5. Train and evaluate TD3/SAC or comparable continuous-control methods.
6. Extend the study to decentralized multi-agent policies using MATD3, MASAC, or MAPPO.
7. Compare against Volt-VAR, centralized RL, and OPF baselines.
8. Validate the learned policies in Simulink and test robustness to unseen scenarios, noise, communication loss, and inverter failures.

## Repository structure

```text
.
├── Meetings/                         # Meeting notes and preparation
├── Proposal/                         # Thesis proposal documents
├── References/                       # Literature summaries and takeaways
├── Report/                           # Thesis report source and figures
├── RL_Knowledge_Guide_for_Voltage_Control.md
├── Strategic_Decisions.md
└── rl_voltage_regulation_project_overview.md
```

The intended implementation layout is documented in the project overview and is expected to evolve as the simulator and training pipeline are established.

## Key technical concepts

- IEEE 13-node distribution feeder
- Active and passive nodes
- PV inverter reactive-power control
- Voltage sensitivity matrices
- Decentralized partially observable control
- Centralized training with decentralized execution
- Continuous-control actor-critic reinforcement learning
- Safe action constraints and reproducible multi-seed evaluation

## Research references

The repository includes summaries of the initial references and related work, including research on reinforcement learning for power systems, graph-based control, decentralized safe reinforcement learning, and DVPP-based distribution-grid control.

## Contributing and reproducibility

This is a research repository. Record assumptions, simulator versions, experiment configurations, random seeds, and evaluation scenarios alongside implementation changes. Validate learned policies against physical constraints and established power-flow or optimization baselines before interpreting results.
