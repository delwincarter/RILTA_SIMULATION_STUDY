# RILTA Simulation Study

## Introduction

This repository contains the Monte Carlo simulation study for my Ph.D. dissertation at the University of California, Santa Barbara, where I am a candidate in the Department of Education, specializing in quantitative methods in social sciences. The study evaluates the performance of Random Intercepts Latent Transition Analysis (RI-LTA) using MplusAutomation, focusing on its robustness under various data conditions.

- **Tools**: 
  - **Software**: R, MplusAutomation, Quarto.
  - **R Packages**:
    - `tidyverse` (data manipulation and visualization, includes `ggplot2`, `dplyr`, etc.)
    - `MplusAutomation` (running Mplus models for RI-LTA simulations)
    - `here` (managing file paths)
    - `gt` (creating tables)
    - `janitor` (cleaning data, e.g., column names)
    - `glue` (string interpolation)
    - `ggtext` (enhanced text rendering in `ggplot2` plots)
    - `rlang` (programming with R, used with `tidyverse`)
    - `parallel` (parallel processing for simulations)
    - `tools` (utility functions, e.g., file path manipulation)
    - `webshot2` (screenshots of web content, e.g., for Quarto outputs)
    - `flextable` (flexible tables for reports)
    - `officer` (working with Microsoft Office documents, e.g., exporting tables)
- **Status**: In progress.
- **Related Work**: Part of my dissertation, "Understanding the performance of random intercepts latent transition analysis (RI-LTA): A Monte Carlo simulation study with MplusAutomation."

## About Me

I am a Ph.D. candidate in the Department of Education at UC Santa Barbara, with a focus on quantitative methods. My research interests include latent variable modeling, longitudinal data analysis, and the use of simulation studies to evaluate statistical methods. I am passionate about bridging the gap between statistical theory and applied research in education and psychology.

- **Institution**: University of California, Santa Barbara
- **Program**: Ph.D. in Education (Quantitative Methods)
- **Advisor**: Dr. Karen Nylund-Gibson
- **Expected Graduation**: 2025

## Overview

This project is organized into two main studies (`Study 1` and `Study 2`), each containing Quarto documents, simulation runs, and visualization outputs. The structure includes:
- **12 Quarto Documents**: 8 for `Study 1` (covering 2 and 3 time points) and 4 for `Study 2`, used for reproducible analysis and documentation.
- **16 Folders with Input/Output/CSV Files**: Simulation runs for both studies, analyzing LTA and RI-LTA models under various conditions.
- **Visualization Outputs**: Figures, heatmaps, and violator plots to visualize simulation results and label-switching violations.

## Studies

### [Study 1](Simulations/STUDY_1/)
- **Description**: Simulation study evaluating RI-LTA across 2 and 3 time points, with 8 conditions (LTA vs. RI-LTA, generated and analyzed).
- **Quarto Documents (8)**:
  - **2 Time Points**:
    - [Study_1_2T_LTA_LTA.qmd](Simulations/STUDY_1/2%20Time%20Points/Study_1_2T_LTA_LTA.qmd) - Analysis of LTA-generated, LTA-analyzed data.
    - [Study_1_2T_LTA_RILTA.qmd](Simulations/STUDY_1/2%20Time%20Points/Study_1_2T_LTA_RILTA.qmd) - Analysis of LTA-generated, RI-LTA-analyzed data.
    - [Study_1_2T_RILTA_LTA.qmd](Simulations/STUDY_1/2%20Time%20Points/Study_1_2T_RILTA_LTA.qmd) - Analysis of RI-LTA-generated, LTA-analyzed data.
    - [Study_1_2T_RILTA_RILTA.qmd](Simulations/STUDY_1/2%20Time%20Points/Study_1_2T_RILTA_RILTA.qmd) - Analysis of RI-LTA-generated, RI-LTA-analyzed data.
  - **3 Time Points**:
    - [Study_1_3T_LTA_LTA.qmd](Simulations/STUDY_1/3%20Time%20Points/Study_1_3T_LTA_LTA.qmd) - Analysis of LTA-generated, LTA-analyzed data.
    - [Study_1_3T_LTA_RILTA.qmd](Simulations/STUDY_1/3%20Time%20Points/Study_1_3T_LTA_RILTA.qmd) - Analysis of LTA-generated, RI-LTA-analyzed data.
    - [Study_1_3T_RILTA_LTA.qmd](Simulations/STUDY_1/3%20Time%20Points/Study_1_3T_RILTA_LTA.qmd) - Analysis of RI-LTA-generated, LTA-analyzed data.
    - [Study_1_3T_RILTA_RILTA.qmd](Simulations/STUDY_1/3%20Time%20Points/Study_1_3T_RILTA_RILTA.qmd) - Analysis of RI-LTA-generated, RI-LTA-analyzed data.
- **Simulation Runs (8 Folders)**:
  - **2 Time Points**:
    - [1_2T_LTA_GEN_LTA_ANALYZED](Simulations/STUDY_1/2%20Time%20Points/1_2T_LTA_GEN_LTA_ANALYZED/) - LTA-generated, LTA-analyzed.
    - [1_2T_LTA_GEN_LTA_ANALYZED_REP](Simulations/STUDY_1/2%20Time%20Points/1_2T_LTA_GEN_LTA_ANALYZED_REP/) - Replicated run.
    - [2_2T_LTA_GEN_RILTA_ANALYZED](Simulations/STUDY_1/2%20Time%20Points/2_2T_LTA_GEN_RILTA_ANALYZED/) - LTA-generated, RI-LTA-analyzed.
    - [2_2T_LTA_GEN_RILTA_ANALYZED_REP](Simulations/STUDY_1/2%20Time%20Points/2_2T_LTA_GEN_RILTA_ANALYZED_REP/) - Replicated run.
    - [3_2T_RILTA_GEN_LTA_ANALYZED](Simulations/STUDY_1/2%20Time%20Points/3_2T_RILTA_GEN_LTA_ANALYZED/) - RI-LTA-generated, LTA-analyzed.
    - [3_2T_RILTA_GEN_LTA_ANALYZED_REP](Simulations/STUDY_1/2%20Time%20Points/3_2T_RILTA_GEN_LTA_ANALYZED_REP/) - Replicated run.
    - [4_2T_RILTA_GEN_RILTA_ANALYZED](Simulations/STUDY_1/2%20Time%20Points/4_2T_RILTA_GEN_RILTA_ANALYZED/) - RI-LTA-generated, RI-LTA-analyzed.
    - [4_2T_RILTA_GEN_RILTA_ANALYZED_REP](Simulations/STUDY_1/2%20Time%20Points/4_2T_RILTA_GEN_RILTA_ANALYZED_REP/) - Replicated run.
  - **3 Time Points**:
    - [5_3T_LTA_GEN_LTA_ANALYZED](Simulations/STUDY_1/3%20Time%20Points/5_3T_LTA_GEN_LTA_ANALYZED/) - LTA-generated, LTA-analyzed.
    - [5_3T_LTA_GEN_LTA_ANALYZED_REP](Simulations/STUDY_1/3%20Time%20Points/5_3T_LTA_GEN_LTA_ANALYZED_REP/) - Replicated run.
    - [6_3T_LTA_GEN_RILTA_ANALYZED](Simulations/STUDY_1/3%20Time%20Points/6_3T_LTA_GEN_RILTA_ANALYZED/) - LTA-generated, RI-LTA-analyzed.
    - [6_3T_LTA_GEN_RILTA_ANALYZED_REP](Simulations/STUDY_1/3%20Time%20Points/6_3T_LTA_GEN_RILTA_ANALYZED_REP/) - Replicated run.
    - [7_3T_RILTA_GEN_LTA_ANALYZED](Simulations/STUDY_1/3%20Time%20Points/7_3T_RILTA_GEN_LTA_ANALYZED/) - RI-LTA-generated, LTA-analyzed.
    - [7_3T_RILTA_GEN_LTA_ANALYZED_REP](Simulations/STUDY_1/3%20Time%20Points/7_3T_RILTA_GEN_LTA_ANALYZED_REP/) - Replicated run.
    - [8_3T_RILTA_GEN_RILTA_ANALYZED](Simulations/STUDY_1/3%20Time%20Points/8_3T_RILTA_GEN_RILTA_ANALYZED/) - RI-LTA-generated, RI-LTA-analyzed.
    - [8_3T_RILTA_GEN_RILTA_ANALYZED_REP](Simulations/STUDY_1/3%20Time%20Points/8_3T_RILTA_GEN_RILTA_ANALYZED_REP/) - Replicated run.
- **Visualizations**:
  - **2 Time Points**:
    - [Figures](Simulations/STUDY_1/2%20Time%20Points/zFIGURES/) - Plots for all conditions (e.g., `x2t_lta_lta_plots`, `x2t_rilta_rilta_plots`).
    - [Heatmaps](Simulations/STUDY_1/2%20Time%20Points/zHEATMAPS/) - Heatmaps visualizing results (e.g., `z2t_heatmaps`, `z2t_r_r_heatmaps`).
    - [Violator Plots](Simulations/STUDY_1/2%20Time%20Points/zVIOLATOR_PLOTS/) - Plots highlighting label-switching violations (e.g., `z2t_lta_lta_violator_plots`).
  - **3 Time Points**:
    - [Figures](Simulations/STUDY_1/3%20Time%20Points/zFigures/) - Plots for all conditions (e.g., `x3t_lta_lta_plots`, `x3t_rilta_rilta_plots`).
    - [Heatmaps](Simulations/STUDY_1/3%20Time%20Points/zHeatmaps/) - Heatmaps visualizing results (e.g., `z3t_l_l_heatmaps`, `z3t_r_r_heatmaps`).
    - [Violator Plots](Simulations/STUDY_1/3%20Time%20Points/zViolator%20Plots/) - Plots highlighting label-switching violations (e.g., `z3t_lta_lta_violator_plots`).

### [Study 2](Simulations/STUDY_2/)
- **Description**: Simulation study evaluating RI-LTA with a different focus (details to be added).
- **Quarto Documents (4)**:
  - [Study_F_2T_LTA_LTA.qmd](Simulations/STUDY_2/Study_F_2T_LTA_LTA.qmd) - Analysis of LTA-generated, LTA-analyzed data.
  - [Study_F_2T_LTA_RILTA.qmd](Simulations/STUDY_2/Study_F_2T_LTA_RILTA.qmd) - Analysis of LTA-generated, RI-LTA-analyzed data.
  - [Study_F_2T_RILTA_LTA.qmd](Simulations/STUDY_2/Study_F_2T_RILTA_LTA.qmd) - Analysis of RI-LTA-generated, LTA-analyzed data.
  - [Study_F_2T_RILTA_RILTA.qmd](Simulations/STUDY_2/Study_F_2T_RILTA_RILTA.qmd) - Analysis of RI-LTA-generated, RI-LTA-analyzed data.
- **Simulation Runs (8 Folders)**:
  - [1_LTA_GEN_LTA_ANALYZED](Simulations/STUDY_2/1_LTA_GEN_LTA_ANALYZED/) - LTA-generated, LTA-analyzed.
  - [1_LTA_GEN_LTA_ANALYZED_REP](Simulations/STUDY_2/1_LTA_GEN_LTA_ANALYZED_REP/) - Replicated run.
  - [2_LTA_GEN_RILTA_ANALYZED](Simulations/STUDY_2/2_LTA_GEN_RILTA_ANALYZED/) - LTA-generated, RI-LTA-analyzed.
  - [2_LTA_GEN_RILTA_ANALYZED_REP](Simulations/STUDY_2/2_LTA_GEN_RILTA_ANALYZED_REP/) - Replicated run.
  - [3_RILTA_GEN_LTA_ANALYZED](Simulations/STUDY_2/3_RILTA_GEN_LTA_ANALYZED/) - RI-LTA-generated, LTA-analyzed.
  - [3_RILTA_GEN_LTA_ANALYZED_REP](Simulations/STUDY_2/3_RILTA_GEN_LTA_ANALYZED_REP/) - Replicated run.
  - [4_RILTA_GEN_RILTA_ANALYZED](Simulations/STUDY_2/4_RILTA_GEN_RILTA_ANALYZED/) - RI-LTA-generated, RI-LTA-analyzed.
  - [4_RILTA_GEN_RILTA_ANALYZED_REP](Simulations/STUDY_2/4_RILTA_GEN_RILTA_ANALYZED_REP/) - Replicated run.
- **Visualizations**:
  - [Figures](Simulations/STUDY_2/zFigures/) - Generated figures for analyses.
  - [Heatmaps](Simulations/STUDY_2/zHeatmaps/) - Heatmaps visualizing results (e.g., `z2t_lta_lta_tables`).
  - [Violator Plots](Simulations/STUDY_2/zViolator_Plots/) - Plots highlighting label-switching violations (e.g., `z2t_lta_lta_violator_plots`).

## Notes
- The Quarto documents are currently in progress and will be updated with rendered outputs (e.g., HTML or PDF reports) in the future.
- The simulation runs use MplusAutomation to execute LTA and RI-LTA models, with input/output/CSV files stored in the respective folders.
