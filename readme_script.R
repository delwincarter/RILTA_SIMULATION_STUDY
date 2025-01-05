library(officer)

generate_readme_and_doc <- function(
    root_dir = ".", 
    readme_file = "README.md", 
    doc_file = "_RILTA_STUDY_1_Project_Documentation.docx", 
    subfolders = c("2 Time Points", "3 Time Points")
) {
  # Step 1: List main folder contents
  main_contents <- list.files(root_dir, full.names = FALSE)
  
  # Step 2: Prepare README.md content
  readme_lines <- c(
    "# Project Directory Overview",
    "",
    "## Main Folder Contents",
    paste("- ", main_contents),
    ""
  )
  
  # Step 3: Add subfolder contents to README.md
  for (subfolder in subfolders) {
    subfolder_contents <- list.files(file.path(root_dir, subfolder), full.names = FALSE)
    readme_lines <- c(
      readme_lines,
      paste0("## ", subfolder, " Folder Contents"),
      paste("- ", subfolder_contents),
      ""
    )
    
    # Add descriptions for subfolders
    readme_lines <- c(
      readme_lines,
      paste0("### Descriptions of Subfolders: ", subfolder)
    )
    for (folder in subfolder_contents) {
      description <- if (grepl("^\\d_", folder)) {
        "Contains input, output, and CSV files for simulation runs."
      } else if (grepl("^zFigures", folder)) {
        "Contains generated figures for analyses."
      } else if (grepl("^zHeatmaps", folder)) {
        "Contains heatmaps visualizing simulation results."
      } else if (grepl("^zViolator", folder)) {
        "Contains plots highlighting label switching or other violations."
      } else {
        ""  # Leave blank for other items
      }
      if (description != "") {
        readme_lines <- c(readme_lines, paste("- **", folder, "**:", description))
      }
    }
  }
  
  # Write README.md
  writeLines(readme_lines, file.path(root_dir, readme_file))
  message("README.md created successfully!")
  
  # Step 4: Prepare Word document content
  doc <- read_docx()
  doc <- body_add_par(doc, "Project Directory Overview", style = "heading 1")
  
  # Main folder contents
  doc <- body_add_par(doc, "Main Folder Contents", style = "heading 2")
  doc <- body_add_par(doc, paste("- ", main_contents, collapse = "\n"), style = "Normal")
  
  # Subfolder contents and descriptions
  for (subfolder in subfolders) {
    subfolder_contents <- list.files(file.path(root_dir, subfolder), full.names = FALSE)
    doc <- body_add_par(doc, paste(subfolder, "Folder Contents"), style = "heading 2")
    doc <- body_add_par(doc, paste("- ", subfolder_contents, collapse = "\n"), style = "Normal")
    
    doc <- body_add_par(doc, paste("Descriptions of Subfolders:", subfolder), style = "heading 2")
    for (folder in subfolder_contents) {
      description <- if (grepl("^\\d_", folder)) {
        "Contains input, output, and CSV files for simulation runs."
      } else if (grepl("^zFigures", folder)) {
        "Contains generated figures for analyses."
      } else if (grepl("^zHeatmaps", folder)) {
        "Contains heatmaps visualizing simulation results."
      } else if (grepl("^zViolator", folder)) {
        "Contains plots highlighting label switching or other violations."
      } else {
        ""  # Leave blank for other items
      }
      if (description != "") {
        doc <- body_add_par(doc, paste("- ", folder, ":", description), style = "Normal")
      }
    }
  }
  
  # Save the Word document
  print(doc, target = file.path(root_dir, doc_file))
  message("Documentation created successfully at: ", file.path(root_dir, doc_file))
}

# Run the function
generate_readme_and_doc()

