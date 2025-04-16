# GAP Solver using Teaching-Learning-Based Optimization (TLBO) in MATLAB

This project solves the **Generalized Assignment Problem (GAP)** using the **Teaching-Learning-Based Optimization (TLBO)** algorithm implemented in MATLAB.

## Problem Description

The Generalized Assignment Problem (GAP) involves assigning a set of tasks to a set of agents such that:

- Each task is assigned to exactly one agent.
- The total resource consumption by each agent does not exceed its capacity.
- The overall assignment cost is minimized.

## Method Used

A **Teaching-Learning-Based Optimization (TLBO)** algorithm is used to find approximate solutions. Each learner (candidate solution) is represented as a real-valued vector, which is decoded into a feasible assignment. The algorithm simulates the teaching and learning phases to iteratively improve the population toward optimal solutions.

## Datasets

The solver uses 12 benchmark GAP instances (`gap1.txt` to `gap12.txt`), solved sequentially.

## How to Run

1. Ensure all dataset files (`gap1.txt` to `gap12.txt`) are placed in a folder (e.g., `datasets/`).
2. Run the main script in MATLAB:

```matlab
main_tlbo_solver
