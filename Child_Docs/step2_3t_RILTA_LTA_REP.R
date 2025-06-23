library(here)
library(dplyr)
library(parallel)

# Step 1: Define the function to process each 7-row chunk
process_chunk <- function(chunk_start, data) {
  if (chunk_start + 7 <= nrow(data)) {  # Ensure chunk is within bounds
    row1 <- data[chunk_start, ]         # File name & replication
    row2 <- data[chunk_start + 1, ]     # Data columns
    row3 <- data[chunk_start + 2, ]     # TRANS11
    row5 <- data[chunk_start + 4, ]     # SE_11 (corrected to row 5)
    row6 <- data[chunk_start + 5, ]     # ll_csv (corrected to row 6)
    
    # Extract relevant data
    rep_variable    <- row1[1]           # Rep number from row 1
    columns_1_to_10 <- row2[1:10]        # First 10 columns from row 2
    trans11         <- row3[6]           # TRANS11 (column 6 from row 3)
    se11            <- row5[6]           # SE_11 (column 6 from row 5)
    ll_csv          <- row6[2]           # ll_csv (column 2 from row 6)
    
    # Combine extracted columns into a single row
    combined_data_chunk <- c(
      as.character(row1$FileName), 
      as.character(rep_variable), 
      as.numeric(columns_1_to_10), 
      as.numeric(trans11), 
      as.numeric(se11),
      as.numeric(ll_csv)
    )
    
    # Convert the combined row into a data frame
    single_row_df <- as.data.frame(t(combined_data_chunk), stringsAsFactors = FALSE)
    
    # Rename columns
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

# Step 2: Set up the number of cores to use (leave one core free for the system)
num_cores <- detectCores() - 1  

# Step 3: Select the cluster type based on the system (PSOCK for Windows, FORK for macOS/Linux)
cluster_type <- ifelse(.Platform$OS.type == "windows", "PSOCK", "FORK")

# Step 4: Create the cluster
cl <- makeCluster(num_cores, type = cluster_type)

# Step 5: Export necessary variables and the process_chunk function to each worker in the cluster
clusterExport(cl, c("combined_data", "process_chunk"))

# Step 6: Set up the sequence of chunk starts (every 7 rows)
chunk_starts <- seq(1, nrow(combined_data), by = 7)

# Step 7: Process chunks in parallel using parLapply
final_data <- tryCatch(
  parLapply(cl, chunk_starts, process_chunk, data = combined_data),
  error = function(e) {
    stopCluster(cl)
    stop(e)  # Stop cluster and throw the error
  }
)

# Step 8: Stop the cluster after processing
stopCluster(cl)

# Step 9: Remove NULL elements (if any chunks are skipped)
final_data <- Filter(Negate(is.null), final_data)

# Step 10: Combine all processed chunks into a single data frame
final_combined_data <- do.call(rbind, final_data)