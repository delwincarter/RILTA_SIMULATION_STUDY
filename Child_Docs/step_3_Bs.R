library(parallel)

# Step 1: Initialize and define data structures and constants
M1Ac1u <- c(0.73, 0.73, 0.73, 0.73, 0.73)
M1Ac2u <- c(0.73, 0.73, 0.27, 0.27, 0.27)
M1Ac3u <- c(0.27, 0.27, 0.27, 0.27, 0.27)
M2Ac1u <- c(0.0067, 0.230, 0.190, 0.175, 0.0067)
M2Ac2u <- c(0.9933, 0.0067, 0.720, 0.495, 0.290)
M2Ac3u <- c(0.0067, 0.825, 0.985, 0.460, 0.120)
M3Ac1u <- c(0.9933, 0.915, 0.960, 0.990, 0.990)
M3Ac2u <- c(0.650, 0.692, 0.695, 0.570, 0.800)
M3Ac3u <- c(0.190, 0.080, 0.0067, 0.155, 0.330)

# Step 2: Define the function to get actual values based on the model
get_actual_values <- function(model) {
  if (model == "M1") {
    return(c(M1Ac1u, M1Ac2u, M1Ac3u))
  } else if (model == "M2") {
    return(c(M2Ac1u, M2Ac2u, M2Ac3u))
  } else if (model == "M3") {
    return(c(M3Ac1u, M3Ac2u, M3Ac3u))
  } else {
    stop("Unknown model")
  }
}

# Step 3: Set up the number of cores to use (leave one core free for the system)
num_cores <- detectCores() - 1  

# Step 4: Select the cluster type based on the system (PSOCK for Windows, FORK for macOS/Linux)
cluster_type <- ifelse(.Platform$OS.type == "windows", "PSOCK", "FORK")

# Step 5: Create the cluster
cl <- makeCluster(num_cores, type = cluster_type)

# Step 6: Export the necessary variables and functions to the cluster workers
clusterExport(cl, c("final_combined_data", "get_actual_values", "M1Ac1u", "M1Ac2u", "M1Ac3u", "M2Ac1u", "M2Ac2u", "M2Ac3u", "M3Ac1u", "M3Ac2u", "M3Ac3u"))

# Step 7: Define the parallelized function to process each row and add actual values
process_row_parallel <- function(i, data) {
  model <- sub(".*(M[1-3]).*", "\\1", data$FileName[i])  # Extract M1, M2, or M3 from the FileName
  actual_values <- get_actual_values(model)               # Get the actual values based on the model
  combined_row <- cbind(data[i, ], as.data.frame(t(actual_values)))
  return(combined_row)
}

# Step 8: Convert logits to probabilities for columns 3 to 17 (Ec1u1 to Ec3u5)
logit_columns <- final_combined_data[, 3:17]  # Adjust to columns 3 to 17
probabilities <- apply(logit_columns, 2, function(x) round(1 / (1 + exp(-as.numeric(x))), 2))

# Step 9: Combine probabilities with the FileName, Rep columns, and the TRANS11, SE_11 columns, and the new variables
final_combined_data_with_trans_se <- final_combined_data %>%
  select(FileName, Replication, TRANS11, SE_11, b1_c1_c1, b2_c1_c2, b3_c2_c1, b4_c2_c2) %>%
  bind_cols(as.data.frame(probabilities))


# Step 10: Apply the function to add actual values in parallel using parLapply
final_data_with_actuals <- parLapply(cl, 1:nrow(final_combined_data_with_trans_se), process_row_parallel, data = final_combined_data_with_trans_se)

# Step 11: Stop the cluster after processing
stopCluster(cl)

# Step 12: Combine the results into a data frame
final_data_with_actuals <- do.call(rbind, final_data_with_actuals)

# Step 13: Set column names for the actual values (from Ac1u1 to Ac3u5)
colnames(final_data_with_actuals)[(ncol(final_combined_data_with_trans_se) + 1):ncol(final_data_with_actuals)] <- c(
  "Ac1u1", "Ac1u2", "Ac1u3", "Ac1u4", "Ac1u5",
  "Ac2u1", "Ac2u2", "Ac2u3", "Ac2u4", "Ac2u5",
  "Ac3u1", "Ac3u2", "Ac3u3", "Ac3u4", "Ac3u5"
)

# Step 14: Round all numeric columns to 3 decimal places
final_data_with_actuals <- final_data_with_actuals %>%
  mutate(across(where(is.numeric), ~ round(.x, 3)))

# Step 15: Ensure that TRANS11 and SE_11 columns are numeric and rounded to 3 decimal places
trans_se_columns <- c("b1_c1_c1", "b2_c1_c2", "b3_c2_c1", "b4_c2_c2", "TRANS11", "SE_11")

final_data_with_actuals[trans_se_columns] <- lapply(final_data_with_actuals[trans_se_columns], function(x) round(as.numeric(x), 3))

# Step 16: Initialize columns for comparisons and flags 

# Columns for basic comparisons across models
final_data_with_actuals$X1v3_item1 <- NA
final_data_with_actuals$X2v3_item2 <- NA
final_data_with_actuals$X1v2_item3 <- NA

# Additional columns for model-specific comparisons
final_data_with_actuals$X1v3_item1_model3 <- NA
final_data_with_actuals$X2v3_item3_model3 <- NA
final_data_with_actuals$X1v2_item4_model3 <- NA

# Columns for Model 2 specific comparisons
final_data_with_actuals$X2v3_item1_model2 <- NA
final_data_with_actuals$X3v2_item2_model2 <- NA
final_data_with_actuals$X3v1_item3_model2 <- NA

# Step 17: Select the cluster type based on the system (PSOCK for Windows, FORK for macOS/Linux)
cluster_type <- ifelse(.Platform$OS.type == "windows", "PSOCK", "FORK")

# Step 18: Create the cluster
cl <- makeCluster(num_cores, type = cluster_type)

# Step 19: Export necessary variables to each worker
clusterExport(cl, c("final_data_with_actuals"))

# Step 20: Define the function for parallelized row processing
process_row <- function(i, data) {
  model <- sub(".*(M[1-3]).*", "\\1", data$FileName[i])  # Extract model type (M1, M2, or M3)
  
  # Step 21: Initialize a temporary list to hold the values for each model
  temp <- list()
  
  if (model == "M1") {
    # Model 1 calculations
    temp$X1v3_item1 <- data$Ec1u1[i] - data$Ec3u1[i]
    temp$X2v3_item2 <- data$Ec2u2[i] - data$Ec3u2[i]
    temp$X1v2_item3 <- data$Ec1u3[i] - data$Ec2u3[i]
    
  } else if (model == "M2") {
    # Model 2 calculations
    temp$X2v3_item1_model2 <- data$Ec2u1[i] - data$Ec3u1[i]
    temp$X3v2_item2_model2 <- data$Ec3u2[i] - data$Ec2u2[i]
    temp$X3v1_item3_model2 <- data$Ec3u3[i] - data$Ec1u3[i]
    
  } else if (model == "M3") {
    # Model 3 calculations
    temp$X1v3_item1_model3 <- data$Ec1u1[i] - data$Ec3u1[i]
    temp$X2v3_item3_model3 <- data$Ec2u3[i] - data$Ec3u3[i]
    temp$X1v2_item4_model3 <- data$Ec1u4[i] - data$Ec2u4[i]
  }
  
  return(temp)
}

# Step 22: Apply the process_row function in parallel
parallel_results <- parLapply(cl, 1:nrow(final_data_with_actuals), process_row, data = final_data_with_actuals)

# Step 23: Stop the cluster after processing
stopCluster(cl)

# Step 24: Combine results from parallel processing
for (i in 1:nrow(final_data_with_actuals)) {
  final_data_with_actuals[i, names(parallel_results[[i]])] <- parallel_results[[i]]
}

# Step 25: Flagging process based on negative values (violators)
# Model 1 flagging
final_data_with_actuals$Flag_M1 <- ifelse(
  final_data_with_actuals$X1v3_item1 < 0 |
    final_data_with_actuals$X2v3_item2 < 0 |
    final_data_with_actuals$X1v2_item3 < 0, 
  1, 0
)

# Model 2 flagging
final_data_with_actuals$Flag_M2 <- ifelse(
  final_data_with_actuals$X2v3_item1_model2 < 0 |
    final_data_with_actuals$X3v2_item2_model2 < 0 |
    final_data_with_actuals$X3v1_item3_model2 < 0,
  1, 0
)
# Model 3 flaggin
final_data_with_actuals$Flag_M3 <- ifelse(
  final_data_with_actuals$X1v3_item1_model3 < 0 |
    final_data_with_actuals$X2v3_item3_model3 < 0 |
    final_data_with_actuals$X1v2_item4_model3 < 0, 
  1, 0
)

# Step 26: Final flagging for any violation across models
final_data_with_actuals$Any_Violation <- ifelse(
  final_data_with_actuals$Flag_M1 == 1 | final_data_with_actuals$Flag_M2 == 1 | final_data_with_actuals$Flag_M3 == 1, 
  1, 0
)

# step 27: Ensure that all numeric columns are rounded and suppress scientific notation
options(scipen = 999)
final_data_with_actuals <- final_data_with_actuals %>%
  mutate(across(where(is.numeric), ~ round(.x, 3)))

# Replace NA values in Any_Violation with 0
final_data_with_actuals <- final_data_with_actuals %>%
  mutate(Any_Violation = if_else(is.na(Any_Violation), 0, Any_Violation))

# Filter rows where there are violations (Any_Violation == 1)
violators <- final_data_with_actuals %>% filter(Any_Violation == 1)
