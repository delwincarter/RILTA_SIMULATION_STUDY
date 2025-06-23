library(parallel)
library(tidyverse)
library(stringr)

# SECTION 1: Extract Errors, Log-Likelihood, and Replication
extract_all_info <- function(filepath) {
  lines <- readLines(filepath)
  error_keywords <- c(
    "NON-POSITIVE DEFINITE",  
    "SADDLE",                 
    "NONIDENTIFICATION"   
  )
  
  current_rep <- NA
  current_ll <- NA
  current_LL_Replicated <- "No"
  current_error_flag <- 0
  current_message <- "None"
  
  results <- list()
  
  for (i in seq_along(lines)) {
    line <- lines[i]
    
    if (str_detect(line, "^REPLICATION\\s+\\d+:")) {
      rep_num <- as.integer(str_extract(line, "\\d+"))
      if (!is.na(current_rep) && rep_num != current_rep) {
        results[[length(results) + 1]] <- tibble(
          FileName = basename(filepath),
          Replication = current_rep,
          ll_out = current_ll,
          LL_Replicated = current_LL_Replicated,
          Message = current_message,
          ErrorFlag = current_error_flag
        )
        current_ll <- NA
        current_LL_Replicated <- "No"
        current_error_flag <- 0
        current_message <- "None"
      }
      current_rep <- rep_num
    }
    
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
    
    if (str_detect(line, paste(error_keywords, collapse = "|"))) {
      current_error_flag <- 1
      if (current_message == "None") {
        current_message <- str_trim(line)
      }
    }
  }
  
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

# SECTION 2: Parallel Processing
file_list <- list.files(output_folder, pattern = "\\.out$", full.names = TRUE)

num_cores <- detectCores() - 1
cl <- makeCluster(num_cores, type = "PSOCK")
clusterExport(cl, c("extract_all_info"))
clusterEvalQ(cl, library(tidyverse))

final_results <- bind_rows(parLapply(cl, file_list, extract_all_info))

stopCluster(cl)

# SECTION 3: Compute Replication Summary
replication_summary <- final_results %>%
  group_by(FileName) %>%
  summarise(
    Total = n(),
    Replicated_Yes = sum(LL_Replicated == "Yes", na.rm = TRUE),
    Replicated_No = sum(LL_Replicated == "No", na.rm = TRUE),
    Error_Count = sum(ErrorFlag, na.rm = TRUE),
    .groups = "drop"
  )

# SECTION 4: Standardize Log-Likelihood Decimal Precision
final_results <- final_results %>%
  mutate(ll_out = round(ll_out, 3))

final_data_with_actuals <- final_data_with_actuals %>%
  mutate(ll_csv = as.numeric(ll_csv)) %>%
  mutate(ll_csv = round(ll_csv, 3))

# SECTION 5: Normalize FileName (Ensure Consistency)
final_results <- final_results %>%
  mutate(
    FileName = str_replace(FileName, "\\.out$", ""),
    FileName = tolower(FileName),
    FileName = str_trim(FileName),
    Replication = as.character(Replication)
  )

final_data_with_actuals <- final_data_with_actuals %>%
  mutate(
    FileName = str_replace(FileName, "\\.out$", ""),
    FileName = tolower(FileName),
    FileName = str_trim(FileName)
  )


# SECTION 6: Remap FileName for M1-M12 Models
final_results <- final_results %>%
  mutate(
    OriginalModel = sub(".*(m[0-9]+)_.*", "\\1", FileName, ignore.case = TRUE),
    FileName = case_when(
      grepl("m[1-3]_", FileName, ignore.case = TRUE) ~ FileName,
      grepl("m[4-6]_", FileName, ignore.case = TRUE) ~ sub("m[4-6]_", "m1_", FileName, ignore.case = TRUE),
      grepl("m[7-9]_", FileName, ignore.case = TRUE) ~ sub("m[7-9]_", "m2_", FileName, ignore.case = TRUE),
      grepl("m(10|11|12)_", FileName, ignore.case = TRUE) ~ sub("m(10|11|12)_", "m3_", FileName, ignore.case = TRUE),
      TRUE ~ FileName
    )
  )
# SECTION 7: Update Replication Summary with Remapped FileName
replication_summary <- final_results %>%
  group_by(FileName) %>%
  summarise(
    Total = n(),
    Replicated_Yes = sum(LL_Replicated == "Yes", na.rm = TRUE),
    Replicated_No = sum(LL_Replicated == "No", na.rm = TRUE),
    Error_Count = sum(ErrorFlag, na.rm = TRUE),
    .groups = "drop"
  )