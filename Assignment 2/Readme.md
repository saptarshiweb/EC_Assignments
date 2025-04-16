# GAP Solver using Approximation Method in MATLAB

This project solves the **Generalized Assignment Problem (GAP)** using an approximation algorithm implemented in MATLAB.

## Problem Description

The Generalized Assignment Problem involves assigning tasks to agents such that:

- Each task is assigned to exactly one agent.
- The resource usage by each agent does not exceed its capacity.
- The total assignment cost is minimized.

## Method Used

An **approximation method** (such as Genetic Algorithm, Particle Swarm Optimization, or another metaheuristic) is used to find near-optimal solutions to the problem. This approach is useful when exact methods like `intlinprog` are too slow for large instances.

## Datasets

The project uses 12 benchmark GAP instances (`gap1.txt` to `gap12.txt`), which are loaded and solved one by one.

## How to Run

1. Place all dataset files in a folder (e.g., `datasets/`).
2. Run the main script in MATLAB:

```matlab
main_approx_solver
