# Convert necessary columns to numeric
cleaned_data <- filtered_data_with_no_violations %>%
  mutate(
    Population = as.numeric(as.character(Population)),
    TRANS11 = as.numeric(as.character(TRANS11)),  # Convert TRANS11 to numeric
    SE_11 = as.numeric(as.character(SE_11))  # Convert SE_11 to numeric
  )

# Step 1: Compute Monte Carlo values **WITHOUT Transitions affecting grouping**
mc_values <- cleaned_data %>%
  group_by(Population, N) %>%
  summarize(
    group_size = n(),
    average = round(mean(TRANS11, na.rm = TRUE), 3),
    average_SE = round(mean(SE_11, na.rm = TRUE), 3),
    population_sd = round(sd(TRANS11, na.rm = TRUE), 3),  # Compute SD across all replications
    MSE = round(mean((TRANS11 - Population)^2, na.rm = TRUE), 3),
    
    # Coverage calculation: check if Population lies within the confidence interval
    Coverage = round(mean((Population >= (TRANS11 - 1.96 * SE_11)) & 
                            (Population <= (TRANS11 + 1.96 * SE_11)), na.rm = TRUE), 3),
    
    # Power calculation: proportion of cases where TRANS11 is significant
    Power = round(mean(TRANS11 / SE_11 > 1.96, na.rm = TRUE), 3),
    
    # Reps_Used counts the number of replications (rows) used per condition
    Reps_Used = n()
  ) %>%
  ungroup()

# Step 2: **Merge Back `Transitions` Without Affecting Calculations**
mc_values <- cleaned_data %>%
  dplyr::dplyr::select(FileName, Population, N, Transitions) %>%  # Keep necessary columns
  distinct() %>%  # Remove duplicates
  right_join(mc_values, by = c("Population", "N"))  # Merge without altering calculations

# Step 3: Add **Bias Calculations**
mc_values <- mc_values %>%
  mutate(
    Parameter_Bias = round((average - Population) / Population * 100, 2),
    SE_Bias = round((average_SE - population_sd) / (sqrt(population_sd) + 0.01) * 100, 2)
  )

# Step 4: Final rounding
mc_values <- mc_values %>%
  mutate(across(starts_with("Avg_"), ~ round(.x, 3)))
