# GAP Solver using Real-Coded Genetic Algorithm in MATLAB

This project solves the **Generalized Assignment Problem (GAP)** using a **Real-Coded Genetic Algorithm** implemented in MATLAB.

## Problem Description

The Generalized Assignment Problem (GAP) involves assigning a set of tasks to agents such that:

- Each task is assigned to exactly one agent.
- The resource usage by each agent does not exceed its capacity.
- The total assignment cost is minimized.

## Method Used

A **Real-Coded Genetic Algorithm** is used as an approximation method to find near-optimal solutions. Each individual in the population is represented by a vector of real values, which are decoded into task-to-agent assignments. The algorithm includes selection, crossover, mutation, and a repair mechanism to ensure feasibility.

## Datasets

The project uses 12 benchmark GAP instances (`gap1.txt` to `gap12.txt`), which are processed sequentially.

## How to Run

1. Place all dataset files in a folder (e.g., `datasets/`).
2. Run the main script in MATLAB:

```matlab
main_real_ga_solver
