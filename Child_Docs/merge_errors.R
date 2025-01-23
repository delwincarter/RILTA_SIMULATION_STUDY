
# Ensure consistent column formats and remove .out and .csv extensions
error_summary <- error_summary %>%
  mutate(
    FileName = tolower(str_trim(gsub("\\.out$|\\.csv$", "", FileName))), # Remove extensions and standardize FileName
    Replication = as.character(Replication) # Convert Replication to character
  )

final_data_with_actuals <- final_data_with_actuals %>%
  mutate(
    FileName = tolower(str_trim(gsub("\\.out$|\\.csv$", "", FileName))), # Remove extensions and standardize FileName
    Replication = as.character(Replication) # Convert Replication to character
  )

# Add a new column to flag errors
error_summary <- error_summary %>%
  mutate(ErrorFlag = if_else(Message == "None", 0, 1))

# Merge ErrorFlag into final_data_with_actuals
final_data_with_actuals <- final_data_with_actuals %>%
  left_join(error_summary %>% select(FileName, Replication, ErrorFlag),
            by = c("FileName" = "FileName", "Replication" = "Replication"))