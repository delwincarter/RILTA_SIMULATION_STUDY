# Step 1: Set up the number of cores to use (leave one core free for the system)
num_cores <- detectCores() - 1  

# Step 2: Select the cluster type based on the system (PSOCK for Windows, FORK for macOS/Linux)
cluster_type <- ifelse(.Platform$OS.type == "windows", "PSOCK", "FORK")

# Step 3: Create the cluster
cl <- makeCluster(num_cores, type = cluster_type)

# Step 4: Export necessary variables to each worker in the cluster
clusterExport(cl, c("combined_data"))

# Step 5: Define the function to process each 9-row chunk
process_chunk <- function(chunk_start, data) {
  if (chunk_start + 8 <= nrow(data)) {
    row1 <- data[chunk_start, ]        # Row 1
    row2 <- data[chunk_start + 1, ]    # Row 2
    row3 <- data[chunk_start + 2, ]    # Row 3
    row4 <- data[chunk_start + 3, ]    # Row 4 (TRANS11)
    row7 <- data[chunk_start + 6, ]    # Row 7 (SE_11)
    row8 <- data[chunk_start + 7, ]    # Row 2 (ll_csv)
    
    # Step 5.1: Extract relevant data
    rep_variable <- row1[1]            # Replication number from row 1, column 1
    columns_1_to_10 <- row2[1:10]      # Columns 1-10 from row 2
    columns_1_to_5 <- row3[1:5]        # Columns 1-5 from row 3
    trans11 <- row4[4]                 # Column 4 from row 4 (TRANS11)
    se11 <- row7[4]                    # Column 4 from row 7 (SE_11)
    ll_csv <- row8[2]                  # Column 2 from row 8 (ll_csv)
    
    # Step 5.2: Combine extracted columns into a single row
    combined_data_chunk <- c(as.character(row1$FileName), 
                             as.character(rep_variable), 
                             as.numeric(columns_1_to_10), 
                             as.numeric(columns_1_to_5),
                             as.numeric(trans11), 
                             as.numeric(se11),
                             as.numeric(ll_csv))
    
    # Step 5.3: Convert the combined row into a data frame
    single_row_df <- as.data.frame(t(combined_data_chunk), stringsAsFactors = FALSE)
    
    # Step 5.4: Rename columns, ensuring TRANS11 and SE_11 are included
    colnames(single_row_df) <- c("FileName", "Replication", 
                                 "Ec1u1", "Ec1u2", "Ec1u3", "Ec1u4", "Ec1u5", 
                                 "Ec2u1", "Ec2u2", "Ec2u3", "Ec2u4", "Ec2u5",
                                 "Ec3u1", "Ec3u2", "Ec3u3", "Ec3u4", "Ec3u5",
                                 "TRANS11", "SE_11", "ll_csv")
    return(single_row_df)
  } else {
    return(NULL)
  }
}

# Step 6: Set up the sequence of chunk starts (every 9 rows)
chunk_starts <- seq(1, nrow(combined_data), by = 9)

# Step 7: Process chunks in parallel using parLapply
final_data <- parLapply(cl, chunk_starts, process_chunk, data = combined_data)

# Step 8: Stop the cluster after processing
stopCluster(cl)

# Step 9: Remove NULL elements (if any chunks are skipped)
final_data <- Filter(Negate(is.null), final_data)

# Step 10: Combine all processed chunks into a single data frame
final_combined_data <- do.call(rbind, final_data)

