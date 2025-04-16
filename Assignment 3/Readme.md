# GAP Solver using Binary Genetic Algorithm in MATLAB

This project solves the **Generalized Assignment Problem (GAP)** using a **Binary Genetic Algorithm (GA)** implemented in MATLAB.

## Problem Description

The Generalized Assignment Problem (GAP) requires assigning a set of tasks to a set of agents such that:

- Each task is assigned to exactly one agent.
- The total resource usage by an agent does not exceed its capacity.
- The overall assignment cost is minimized.

## Method Used

A **Binary Genetic Algorithm** is used to find approximate solutions. Each individual in the population is a binary chromosome representing a possible task-to-agent assignment. The GA uses selection, crossover, mutation, and a feasibility check to evolve better solutions over generations.

## Datasets

The solver uses 12 standard GAP instances (`gap1.txt` to `gap12.txt`), processed one at a time.

## How to Run

1. Ensure all dataset files are in a folder (e.g., `datasets/`).
2. Run the main script in MATLAB:

```matlab
main_binary_ga_solver
