generate_readme_and_doc <- function(root_dir = getwd(), readme_file = "README.md", doc_file = "_RILTA_Simulation_Study_Project_Documentation.docx") {
  # List all files and folders recursively
  all_contents <- list.files(root_dir, full.names = TRUE, recursive = TRUE, include.dirs = TRUE)
  
  # Define descriptors for specific folder patterns
  folder_descriptors <- list(
    "ANALYZED" = " --> Contains Simulation files: .inp, .out, and .csv",
    "zFIGURES" = " --> Contains figures of Bias",
    "zHEATMAPS" = " --> Contains heatmaps of Bias",
    "zViolator_Plots" = " --> Contains sample of label switching plots"
  )
  
  # Specify folders to exclude
  excluded_folders <- c("_files$", "figure-html", "libs", "bootstrap", "clipboard", "quarto-html")
  
  # Helper to exclude unwanted folders
  is_excluded <- function(item) {
    any(sapply(excluded_folders, function(exclude) grepl(exclude, item, ignore.case = TRUE)))
  }
  
  # Prepare a nested structure
  structure_lines <- c("# Project Directory Overview", "")
  
  for (item in all_contents) {
    # Get relative path
    local_path <- gsub(paste0(root_dir, "/"), "", item)
    
    # Skip excluded folders
    if (is_excluded(local_path)) {
      next
    }
    
    # Count slashes to determine indentation
    depth <- length(strsplit(local_path, "/")[[1]]) - 1
    indent <- paste(rep("  ", depth), collapse = "")
    
    # Add folder or file names to the structure
    if (dir.exists(item)) {
      # Determine if folder matches any descriptor
      label <- ""
      for (pattern in names(folder_descriptors)) {
        if (grepl(pattern, basename(item), ignore.case = TRUE)) {
          label <- folder_descriptors[[pattern]]
          break
        }
      }
      structure_lines <- c(structure_lines, paste0(indent, "- ", basename(item), label))
    } else if (grepl("\\.qmd$", item)) {
      structure_lines <- c(structure_lines, paste0(indent, "- ", basename(item), " --> Quarto Markdown File"))
    }
  }
  
  # Write README.md
  writeLines(structure_lines, file.path(root_dir, readme_file))
  message("README.md created successfully at: ", file.path(root_dir, readme_file))
  
  # Create Word document
  library(officer)
  doc <- read_docx()
  doc <- body_add_par(doc, "Project Directory Overview", style = "heading 1")
  for (line in structure_lines) {
    if (line != "# Project Directory Overview") {
      doc <- body_add_par(doc, gsub("^\\s*- ", "", line), style = "Normal")
    }
  }
  
  # Save the Word document with the specified name
  print(doc, target = file.path(root_dir, doc_file))
  message("Word document created successfully at: ", file.path(root_dir, doc_file))
}

# Run the script
generate_readme_and_doc()

