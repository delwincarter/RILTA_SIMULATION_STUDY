# Ensure required libraries are loaded
library(parallel)
library(dplyr)

# Step 1: Define the corrected actual values for M1
M1Ac1u <- c(0.73, 0.73, 0.73, 0.73, 0.73)
M1Ac2u <- c(0.27, 0.27, 0.27, 0.27, 0.27)

# Step 2: Define the function to get actual values (only for M1)
get_actual_values <- function(model) {
  return(c(M1Ac1u, M1Ac2u))
}

# Step 3: Set up the number of cores and cluster
num_cores <- detectCores() - 1
cluster_type <- ifelse(.Platform$OS.type == "windows", "PSOCK", "FORK")
cl <- makeCluster(num_cores, type = cluster_type)

# Step 4: Export necessary variables and functions to the cluster workers
clusterExport(cl, c("final_combined_data", "get_actual_values", "M1Ac1u", "M1Ac2u"))

# Step 5: Convert logits to probabilities for columns 3 to 12 (Ec1u1 to Ac2u5)
logit_columns <- final_combined_data[, 3:12]
probabilities <- apply(logit_columns, 2, function(x) round(1 / (1 + exp(-as.numeric(x))), 2))

# Combine probabilities with the FileName, Rep, TRANS11, and SE_11 columns
final_combined_data_with_trans_se <- final_combined_data %>%
  select(FileName, Replication, TRANS11, SE_11) %>%
  bind_cols(as.data.frame(probabilities))

# Step 6: Add actual values to the data in parallel
process_row_parallel <- function(i, data) {
  actual_values <- get_actual_values("M1")
  combined_row <- cbind(data[i, ], as.data.frame(t(actual_values)))
  return(combined_row)
}
final_data_with_actuals <- parLapply(
  cl, 1:nrow(final_combined_data_with_trans_se), 
  process_row_parallel, data = final_combined_data_with_trans_se
)

# Step 7: Stop the cluster
stopCluster(cl)

# Step 8: Combine the results and set column names
final_data_with_actuals <- do.call(rbind, final_data_with_actuals)
colnames(final_data_with_actuals)[(ncol(final_combined_data_with_trans_se) + 1):ncol(final_data_with_actuals)] <- c(
  "Ac1u1", "Ac1u2", "Ac1u3", "Ac1u4", "Ac1u5",
  "Ac2u1", "Ac2u2", "Ac2u3", "Ac2u4", "Ac2u5"
)

# Step 9: Round all numeric columns
final_data_with_actuals <- final_data_with_actuals %>%
  mutate(across(where(is.numeric), ~ round(.x, 3)))


# Initialize columns for comparisons and flags
final_data_with_actuals <- final_data_with_actuals %>%
  mutate(
    X1v2_item1 = NA,  # Comparison for Item 1 (Ec1u1 vs Ec2u1)
    X1v2_item2 = NA,  # Comparison for Item 2 (Ec1u2 vs Ac2u2)
    X1v2_item3 = NA   # Comparison for Item 3 (Ec1u3 vs Ac2u3)
  )

# Set up parallel processing
num_cores <- detectCores() - 1
cl <- makeCluster(num_cores)
clusterExport(cl, varlist = c("final_data_with_actuals"), envir = environment())

# Define the function to compute differences
compute_diffs <- function(data) {
  data <- transform(data,
                    X1v2_item1 = Ec1u1 - Ec2u1,
                    X1v2_item2 = Ec1u2 - Ec2u2,
                    X1v2_item3 = Ec1u3 - Ec2u3
  )
  return(data)
}

# Divide data into chunks and apply the function
data_chunks <- split(final_data_with_actuals, cut(seq(nrow(final_data_with_actuals)), num_cores, labels = FALSE))
processed_chunks <- clusterApply(cl, data_chunks, compute_diffs)
final_data_with_actuals <- do.call(rbind, processed_chunks)
stopCluster(cl)

# Flagging logic for violations
final_data_with_actuals <- final_data_with_actuals %>%
  mutate(
    Flag_M1 = if_else(rowSums(select(., starts_with("X1v2_item")) < 0) >= 1, 1, 0),
    Any_Violation = if_else(Flag_M1 == 1, 1, 0)
  )

# Post-processing for numeric formatting and filtering violators
options(scipen = 999)
final_data_with_actuals <- final_data_with_actuals %>%
  mutate(across(where(is.numeric), \(x) round(x, 3))) %>%
  mutate(Any_Violation = if_else(is.na(Any_Violation), 0, Any_Violation))

violators <- filter(final_data_with_actuals, Any_Violation == 1)

# Return results for future steps
return(list(
  final_data_with_actuals = final_data_with_actuals,
  violators = violators
))
