library(parallel)
library(tidyverse)
library(stringr)

# ===================================================== #
#  ✅ SECTION 1: Extract Errors, Log-Likelihood, and Replication
# ===================================================== #
extract_all_info <- function(filepath) {
  lines <- readLines(filepath)
  error_keywords <- c("NON-POSITIVE DEFINITE", "SADDLE")
  
  # Initialize current replication info
  current_rep <- NA
  current_ll <- NA
  current_LL_Replicated <- "No"
  current_error_flag <- 0
  current_message <- "None"
  
  results <- list()
  
  # Process the file line-by-line
  for (i in seq_along(lines)) {
    line <- lines[i]
    
    # Check for a replication header
    if (str_detect(line, "^REPLICATION\\s+\\d+:")) {
      rep_num <- as.integer(str_extract(line, "\\d+"))
      
      # If we've already started a replication and encounter a new one, save the previous record
      if (!is.na(current_rep) && rep_num != current_rep) {
        results[[length(results) + 1]] <- tibble(
          FileName = basename(filepath),
          Replication = current_rep,
          ll_out = current_ll,
          LL_Replicated = current_LL_Replicated,
          Message = current_message,
          ErrorFlag = current_error_flag
        )
        # Reset values for the new replication
        current_ll <- NA
        current_LL_Replicated <- "No"
        current_error_flag <- 0
        current_message <- "None"
      }
      current_rep <- rep_num
    }
    
    # Look for the log-likelihood marker and process the following lines
    if (str_detect(line, "Final stage loglikelihood values")) {
      start_ll <- i + 1
      end_ll <- min(length(lines), i + 10)
      ll_lines <- lines[start_ll:end_ll]
      ll_values <- as.numeric(unlist(str_extract_all(ll_lines, "-?\\d+\\.\\d+")))
      if (length(ll_values) > 0) {
        current_ll <- ll_values[1]
        current_LL_Replicated <- ifelse(sum(ll_values == current_ll) > 1, "Yes", "No")
      }
    }
    
    # Check for error keywords
    if (str_detect(line, paste(error_keywords, collapse = "|"))) {
      current_error_flag <- 1
      if (current_message == "None") {
        current_message <- str_trim(line)
      }
    }
  }
  
  # Save the final replication record if it exists
  if (!is.na(current_rep)) {
    results[[length(results) + 1]] <- tibble(
      FileName = basename(filepath),
      Replication = current_rep,
      ll_out = current_ll,
      LL_Replicated = current_LL_Replicated,
      Message = current_message,
      ErrorFlag = current_error_flag
    )
  }
  
  bind_rows(results)
}

# ===================================================== #
#  ✅ SECTION 2: Parallel Processing
# ===================================================== #
file_list <- list.files(output_folder, pattern = "\\.out$", full.names = TRUE)

num_cores <- detectCores() - 1
cl <- makeCluster(num_cores, type = "PSOCK")
clusterExport(cl, c("extract_all_info"))
clusterEvalQ(cl, library(tidyverse))

final_results <- bind_rows(parLapply(cl, file_list, extract_all_info))

stopCluster(cl)

# ===================================================== #
#  ✅ SECTION 3: Compute Replication Summary
# ===================================================== #
replication_summary <- final_results %>%
  group_by(FileName) %>%
  summarise(
    Total = n(),
    Replicated_Yes = sum(LL_Replicated == "Yes", na.rm = TRUE),
    Replicated_No = sum(LL_Replicated == "No", na.rm = TRUE),
    Error_Count = sum(ErrorFlag, na.rm = TRUE),
    .groups = "drop"
  )

# ===================================================== #
#  ✅ SECTION 4: Standardize Log-Likelihood Decimal Precision
# ===================================================== #
final_results <- final_results %>%
  mutate(ll_out = round(ll_out, 3))

final_data_with_actuals <- final_data_with_actuals %>%
  mutate(ll_csv = as.numeric(ll_csv)) %>%
  mutate(ll_csv = round(ll_csv, 3))

# ===================================================== #
#  ✅ SECTION 5: Normalize FileName (Ensure Consistency)
# ===================================================== #
final_results <- final_results %>%
  mutate(
    FileName = str_replace(FileName, "\\.out$", ""),  # Remove .out extension
    FileName = tolower(FileName),  # Standardize filename
    FileName = str_trim(FileName),  # Trim whitespace
    Replication = as.character(Replication)  # Convert to character for merging
  )

final_data_with_actuals <- final_data_with_actuals %>%
  mutate(FileName = str_replace(FileName, "\\.out$", ""),
         FileName = tolower(FileName),
         FileName = str_trim(FileName))

