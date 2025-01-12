
# Process the data to scrape the relevant rows of each 11-row chunk
processed_data <- combined_data %>%
  slice(1:nrow(combined_data)) %>%  
  filter((row_number() - 1) %% 11 < 11)  # Ensure all 11 rows are considered

# Define the function to process each chunk
process_chunk <- function(chunk_start, data) {
  if (chunk_start + 10 <= nrow(data)) {
    row1 <- data[chunk_start, ]        # Row 1
    row2 <- data[chunk_start + 1, ]    # Row 2
    row3 <- data[chunk_start + 2, ]    # Row 3
    row4 <- data[chunk_start + 3, ]    # Row 4 (TRANS data)
    row8 <- data[chunk_start + 7, ]    # Row 8 (SE data)
    
    # Combine data from the rows into a single row, including all necessary columns
    rep_variable <- row1[1]            # Replication number from row 1, column 1
    row2_cols_6_to_10 <- row2[6:10]    # Row 2 columns 6 through 10
    row3_cols_1_to_10 <- row3[1:10]    # Row 3 columns 1 through 10
    trans11 <- row4[9]                 # Row 4 column 9 (TRANS11)
    se11 <- row8[9]                    # Row 8 column 9 (SE_11)
    
    # Combine all columns into a single row
    combined_data_chunk <- c(as.character(row1$FileName), 
                             as.character(rep_variable), 
                             as.numeric(row2_cols_6_to_10), 
                             as.numeric(row3_cols_1_to_10),
                             as.numeric(trans11), 
                             as.numeric(se11))
    
    # Convert to a data frame
    single_row_df <- as.data.frame(t(combined_data_chunk), stringsAsFactors = FALSE)
    
    # Rename columns, ensuring TRANS11 and SE_11 are included
    colnames(single_row_df) <- c("FileName", "Replication", 
                                 "Ec1u1", "Ec1u2", "Ec1u3", "Ec1u4", "Ec1u5", 
                                 "Ec2u1", "Ec2u2", "Ec2u3", "Ec2u4", "Ec2u5",
                                 "Ec3u1", "Ec3u2", "Ec3u3", "Ec3u4", "Ec3u5",
                                 "TRANS11", "SE_11")
    return(single_row_df)
  } else {
    return(NULL)
  }
}

# Step 6: Set up the number of cores to use
num_cores <- detectCores() - 1  # Leave one core free for the system
cluster_type <- ifelse(.Platform$OS.type == "windows", "PSOCK", "FORK")

# Step 7: Create the cluster and export required variables
cl <- makeCluster(num_cores, type = cluster_type)

# Export variables and functions to cluster
clusterExport(cl, c("processed_data", "process_chunk"))

# Step 8: Process chunks in parallel
chunk_starts <- seq(1, nrow(processed_data), by = 11)  # Adjust for chunk size
final_data <- parLapply(cl, chunk_starts, process_chunk, data = processed_data)

# Step 9: Stop the cluster after processing
stopCluster(cl)

# Step 10: Remove NULL elements and combine into a single data frame
final_data <- Filter(Negate(is.null), final_data)
final_combined_data <- do.call(rbind, final_data)
