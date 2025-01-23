# Convert necessary columns to numeric
cleaned_data <- sampled_data %>%
  mutate(
    Population = as.numeric(as.character(Population)),
    TRANS11 = as.numeric(as.character(TRANS11)),  # Convert TRANS11 to numeric
    SE_11 = as.numeric(as.character(SE_11))  # Convert SE_11 to numeric
  )

# Calculate the Monte Carlo values, including Population (transition probability), N, 
# number of replications, and averages for TRANS11 and SE11
mc_values <- cleaned_data %>%
  group_by(FileName, Population, N, Transitions) %>%  # Group by FileName, Population, and N
  summarize(
    average = round(mean(TRANS11, na.rm = TRUE), 3),
    average_SE = round(mean(SE_11, na.rm = TRUE), 3),
    population_sd = round(sd(TRANS11, na.rm = TRUE), 3),
    
    # MSE calculation: mean squared error between TRANS11 and Population
    MSE = round(mean((TRANS11 - Population)^2, na.rm = TRUE), 3),
    
    # Coverage calculation: check if Population lies within the confidence interval
    Coverage = round(mean((Population >= (TRANS11 - 1.96 * SE_11)) & (Population <= (TRANS11 + 1.96 * SE_11)), na.rm = TRUE), 3),
    
    # Power calculation: proportion of cases where TRANS11 is significant
    Power = round(mean(TRANS11 / SE_11 > 1.96, na.rm = TRUE), 3),
    
    # Reps_Used counts the number of replications (rows) used for each FileName
    Reps_Used = n()
  )

# Round the values to 3 decimal points
mc_values <- mc_values %>%
  mutate(across(starts_with("Avg_"), ~ round(.x, 3)))