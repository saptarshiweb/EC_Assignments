# GAP Solver using Particle Swarm Optimization (PSO) in MATLAB

This project solves the **Generalized Assignment Problem (GAP)** using a **Particle Swarm Optimization (PSO)** algorithm implemented in MATLAB.

## Problem Description

The Generalized Assignment Problem (GAP) is a classic optimization problem where:

- Each task must be assigned to exactly one agent.
- The resource usage by each agent should not exceed its capacity.
- The total assignment cost must be minimized.

## Method Used

A **Particle Swarm Optimization (PSO)** based approach is used to find approximate solutions. Each particle represents a potential solution encoded as a real-valued vector, which is decoded into a binary assignment matrix. The algorithm iteratively updates positions and velocities of particles to search for the best feasible solution.

## Datasets

The solver uses 12 standard GAP datasets (`gap1.txt` to `gap12.txt`), solved one after another.

## How to Run

1. Make sure all dataset files (`gap1.txt` to `gap12.txt`) are placed in a folder like `datasets/`.
2. Run the main script in MATLAB:

```matlab
main_pso_solver
