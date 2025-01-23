

library(parallel)

extract_errors_from_file <- function(filepath, total_replications) {
  lines <- readLines(filepath)
  results <- vector("list", total_replications)
  error_keywords <- c("NON-POSITIVE DEFINITE", "SADDLE")
  
  # Initialize results for every replication
  for (rep in 1:total_replications) {
    results[[rep]] <- tibble(
      FileName = basename(filepath),
      Replication = rep,
      Message = "None",
      MessageType = "None"
    )
  }
  
  current_replication <- NULL
  for (line in lines) {
    if (str_detect(line, "REPLICATION")) {
      current_replication <- as.integer(str_extract(line, "\\d+"))
    }
    
    if (!is.null(current_replication) && current_replication <= total_replications &&
        any(sapply(error_keywords, grepl, line, ignore.case = TRUE))) {
      results[[current_replication]] <- tibble(
        FileName = basename(filepath),
        Replication = current_replication,
        Message = str_trim(line),
        MessageType = "Error"
      )
    }
  }
  
  return(bind_rows(results))
}

# Step 2: Extract Completed Replications
extract_completed_replications <- function(filepath) {
  lines <- readLines(filepath)
  completed_line <- lines[grepl("Completed", lines, ignore.case = TRUE)]
  completed <- as.integer(str_match(completed_line, "Completed\\s+(\\d+)")[, 2])
  if (length(completed) == 0) completed <- 0
  tibble(FileName = basename(filepath), CompletedReplications = completed)
}

# Step 3: Extract Requested Replications
extract_requested_replications <- function(filepath) {
  lines <- readLines(filepath)
  requested_line <- lines[grepl("Requested", lines, ignore.case = TRUE)]
  requested <- as.integer(str_match(requested_line, "Requested\\s+(\\d+)")[, 2])
  if (length(requested) == 0) requested <- 0
  tibble(FileName = basename(filepath), RequestedReplications = requested)
}

calculate_replication_summary <- function(error_summary, completed_replications, requested_replications) {
  summary <- error_summary %>%
    group_by(FileName) %>%
    summarise(
      ErrorReplications = n_distinct(Replication[MessageType == "Error"]),
      .groups = "drop"
    )
  
  full_summary <- requested_replications %>%
    left_join(completed_replications, by = "FileName") %>%
    left_join(summary, by = "FileName") %>%
    mutate(
      ErrorReplications = coalesce(ErrorReplications, 0),
      GoodReplications = CompletedReplications - ErrorReplications,
      ErrorRate = if_else(CompletedReplications > 0, (ErrorReplications / CompletedReplications) * 100, 0)
    ) %>%
    select(FileName, RequestedReplications, CompletedReplications, ErrorReplications, GoodReplications, ErrorRate)
  
  full_summary
}

# Assumes 'out_files_directory' is already defined in the main .qmd and passed into the child script
file_list <- list.files(output_folder, pattern = "\\.out$", full.names = TRUE)


# Step 5: Detect OS and Set Up Cluster
cluster_type <- ifelse(.Platform$OS.type == "windows", "PSOCK", "FORK")
num_cores <- detectCores() - 1  # Use all but one core
cl <- makeCluster(num_cores, type = cluster_type)

# Export necessary libraries and functions to the cluster
invisible(clusterExport(cl, c("extract_errors_from_file", "extract_completed_replications", "extract_requested_replications")))
invisible(clusterEvalQ(cl, library(tidyverse)))

# Step 6: Parallel Processing
# Calculate completed replications first
completed_rep_list <- parLapply(cl, file_list, extract_completed_replications)

# Extract errors while passing the total number of completed replications to the function
error_summary <- bind_rows(mapply(function(filepath, completed_data) {
  extract_errors_from_file(filepath, completed_data$CompletedReplications)
}, file_list, completed_rep_list, SIMPLIFY = FALSE))

completed_replications <- bind_rows(parLapply(cl, file_list, extract_completed_replications))
requested_replications <- bind_rows(parLapply(cl, file_list, extract_requested_replications))

# Stop the cluster
stopCluster(cl)

# Step 7: Calculate Replication Summary
replication_summary <- calculate_replication_summary(error_summary, completed_replications, requested_replications)


completed_replications <- completed_replications %>%
  mutate(FileName = str_replace(FileName, "\\.out$", ""),
         FileName = tolower(FileName),
         FileName = str_trim(FileName))

error_summary <- error_summary %>%
  mutate(FileName = str_replace(FileName, "\\.out$", ""),
         FileName = tolower(FileName),
         FileName = str_trim(FileName))

final_data_with_actuals <- final_data_with_actuals %>%
  mutate(FileName = tolower(FileName),
         FileName = str_trim(FileName))

replication_summary <- replication_summary %>%
  mutate(FileName = str_replace(FileName, "\\.out$", ""),
         FileName = tolower(FileName),
         FileName = str_trim(FileName))
