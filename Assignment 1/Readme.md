# GAP Solver using intlinprog in MATLAB

This project solves the **Generalized Assignment Problem (GAP)** using MATLAB's `intlinprog` function.

## Problem Description

In the Generalized Assignment Problem, a set of tasks must be assigned to a set of agents such that:

- Each task is assigned to exactly one agent.
- The total resource usage for each agent does not exceed its capacity.
- The total assignment cost is minimized.

## Method Used

The problem is formulated as a **Mixed Integer Linear Program (MILP)** and solved using MATLAB’s built-in `intlinprog` solver. Binary decision variables are used to represent task-agent assignments.

## Datasets

The project uses 12 benchmark GAP instances (`gap1.txt` to `gap12.txt`), which are loaded and solved sequentially.

## How to Run

1. Place all dataset files in a folder (e.g., `datasets/`).
2. Run the main script in MATLAB:

```matlab
main_intlinprog_solver
