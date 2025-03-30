
# Step 1: Define the function to process each 9-row chunk, including log likelihood extraction
process_chunk <- function(chunk_start, data) {
  if (chunk_start + 8 <= nrow(data)) {
    # Extract the relevant rows from the current 9-row chunk
    row1 <- data[chunk_start, ]
    row2 <- data[chunk_start + 1, ]
    row3 <- data[chunk_start + 2, ]  # TRANS11 row
    row6 <- data[chunk_start + 5, ]  # SE_11 row
    row8 <- data[chunk_start + 7, ]  # Log likelihood row
    
    rep_variable <- row1[1]
    columns_6_to_10 <- row2[6:10]
    columns_1_to_5 <- row3[1:5]
    trans11 <- row3[9]
    se11 <- row6[9]
    ll_csv <- row8[2]  # Log likelihood value is in row 8, column 2
    
    # Combine all extracted values into a single vector
    combined_data_chunk <- c(
      as.character(row1$FileName),
      as.character(rep_variable),
      as.numeric(columns_6_to_10),
      as.numeric(columns_1_to_5),
      as.numeric(trans11),
      as.numeric(se11),
      as.numeric(ll_csv)
    )
    
    # Transpose the vector into a single-row data frame and set column names
    single_row_df <- as.data.frame(t(combined_data_chunk), stringsAsFactors = FALSE)
    colnames(single_row_df) <- c(
      "FileName", "Replication",
      "Ec1u1", "Ec1u2", "Ec1u3", "Ec1u4", "Ec1u5",
      "Ec2u1", "Ec2u2", "Ec2u3", "Ec2u4", "Ec2u5",
      "TRANS11", "SE_11", "ll_csv"
    )
    return(single_row_df)
  } else {
    return(NULL)
  }
}

# Step 2: Set up parallel processing
num_cores <- detectCores() - 1
cluster_type <- ifelse(.Platform$OS.type == "windows", "PSOCK", "FORK")
cl <- makeCluster(num_cores, type = cluster_type)
clusterExport(cl, c("combined_data", "process_chunk"))
chunk_starts <- seq(1, nrow(combined_data), by = 9)

# Step 3: Process the chunks in parallel
final_data <- tryCatch(
  parLapply(cl, chunk_starts, process_chunk, data = combined_data),
  error = function(e) {
    stopCluster(cl)
    stop(e)
  }
)
stopCluster(cl)

# Step 4: Combine and clean up the processed data
final_data <- Filter(Negate(is.null), final_data)
final_combined_data <- do.call(rbind, final_data)

# Return both objects to the current environment, with the combined data now named ll_csv
list(final_data = final_data, ll_csv = final_combined_data)
