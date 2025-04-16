# Generalized Assignment Problem (GAP) Solver in MATLAB

This repository provides a comprehensive solution framework for the **Generalized Assignment Problem (GAP)** using multiple methods, both exact and approximate, implemented in MATLAB. It includes dataset files, solution scripts, stored results, and convergence graphs.

---

## 📌 Problem Description

The **Generalized Assignment Problem (GAP)** involves assigning `n` tasks to `m` agents such that:

- Each task is assigned to exactly one agent.
- The total resource usage by each agent does not exceed its capacity.
- The total assignment cost is minimized.

### Mathematical Formulation:

Minimize:
\[
\sum_{i=1}^{m} \sum_{j=1}^{n} c_{ij} \cdot x_{ij}
\]

Subject to:
- \(\sum_{i=1}^{m} x_{ij} = 1 \quad \forall j = 1, ..., n\)
- \(\sum_{j=1}^{n} r_{ij} \cdot x_{ij} \leq b_i \quad \forall i = 1, ..., m\)
- \(x_{ij} \in \{0, 1\}\)

---

## 🧠 Methods Implemented

The project implements the following solvers:

| Method                         | Script Name                  | Type           |
|-------------------------------|------------------------------|----------------|
| Exact Solver using `intlinprog` | `main_intlinprog_solver.m`   | Exact           |
| Binary Genetic Algorithm       | `main_binary_ga_solver.m`    | Approximation   |
| Real-Coded Genetic Algorithm   | `main_real_ga_solver.m`      | Approximation   |
| Particle Swarm Optimization    | `main_pso_solver.m`          | Approximation   |
| Teaching-Learning-Based Optimization (TLBO) | `main_tlbo_solver.m`        | Approximation   |

Each method follows the same input-output convention for comparability.

---

