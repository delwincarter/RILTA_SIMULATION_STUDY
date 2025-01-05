library(officer)

generate_readme_and_doc <- function(root_dir = ".", readme_file = "README.md", doc_file = "_RILTA 1 (k = 2) _ STARTS Project_Documentation.docx") {
  # Step 1: List main folder contents
  main_contents <- list.files(root_dir, full.names = FALSE)
  
  # Step 2: List subfolders in "2 Time Points" and "3 Time Points"
  two_time_points <- list.files(file.path(root_dir, "2 Time Points"), full.names = FALSE)
  three_time_points <- list.files(file.path(root_dir, "3 Time Points"), full.names = FALSE)
  
  # Step 3: Prepare README.md content
  readme_lines <- c(
    "# Project Directory Overview",
    "",
    "## Main Folder Contents",
    paste("- ", main_contents),
    "",
    "## 2 Time Points Folder Contents",
    paste("- ", two_time_points),
    "",
    "## 3 Time Points Folder Contents",
    paste("- ", three_time_points),
    "",
    "## Descriptions of Subfolders",
    "### 2 Time Points Subfolders"
  )
  
  # Add descriptions for subfolders in "2 Time Points"
  for (folder in two_time_points) {
    description <- if (grepl("^\\d_", folder)) {
      "Contains input, output, and CSV files for simulation runs."
    } else if (grepl("^zFigures", folder)) {
      "Contains generated figures aggregated MC bias estimat4es."
    } else if (grepl("^zHeatmaps", folder)) {
      "Contains heatmaps visualizing simulation results."
    } else if (grepl("^zViolator", folder)) {
      "Contains plots highlighting label switching violations."
    } else {
      ""
    }
    readme_lines <- c(readme_lines, paste("- **", folder, "**:", description))
  }
  
  # Add descriptions for subfolders in "3 Time Points"
  readme_lines <- c(readme_lines, "### 3 Time Points Subfolders")
  for (folder in three_time_points) {
    description <- if (grepl("^\\d_", folder)) {
      "Contains input, output, and CSV files for simulation runs."
    } else if (grepl("^zFigures", folder)) {
      "Contains generated figures for analyses."
    } else if (grepl("^zHeatmaps", folder)) {
      "Contains heatmaps visualizing simulation results."
    } else if (grepl("^zViolator", folder)) {
      "Contains plots highlighting label switching or other violations."
    } else {
      "General folder for analysis."
    }
    readme_lines <- c(readme_lines, paste("- **", folder, "**:", description))
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
  
  # 2 Time Points folder
  doc <- body_add_par(doc, "2 Time Points Folder Contents", style = "heading 2")
  doc <- body_add_par(doc, paste("- ", two_time_points, collapse = "\n"), style = "Normal")
  
  # 3 Time Points folder
  doc <- body_add_par(doc, "3 Time Points Folder Contents", style = "heading 2")
  doc <- body_add_par(doc, paste("- ", three_time_points, collapse = "\n"), style = "Normal")
  
  # Descriptions for "2 Time Points" subfolders
  doc <- body_add_par(doc, "Descriptions of Subfolders: 2 Time Points", style = "heading 2")
  for (folder in two_time_points) {
    description <- if (grepl("^\\d_", folder)) {
      "Contains input, output, and CSV files for simulation runs."
    } else if (grepl("^zFigures", folder)) {
      "Contains generated figures for analyses."
    } else if (grepl("^zHeatmaps", folder)) {
      "Contains heatmaps visualizing simulation results."
    } else if (grepl("^zViolator", folder)) {
      "Contains plots highlighting label switching or other violations."
    } else {
      ""
    }
    doc <- body_add_par(doc, paste("- ", folder, ":", description), style = "Normal")
  }
  
  # Descriptions for "3 Time Points" subfolders
  doc <- body_add_par(doc, "Descriptions of Subfolders: 3 Time Points", style = "heading 2")
  for (folder in three_time_points) {
    description <- if (grepl("^\\d_", folder)) {
      "Contains input, output, and CSV files for simulation runs."
    } else if (grepl("^zFigures", folder)) {
      "Contains generated figures for analyses."
    } else if (grepl("^zHeatmaps", folder)) {
      "Contains heatmaps visualizing simulation results."
    } else if (grepl("^zViolator", folder)) {
      "Contains plots highlighting label switching or other violations."
    } else {
      ""
    }
    doc <- body_add_par(doc, paste("- ", folder, ":", description), style = "Normal")
  }
  
  # Save the Word document
  print(doc, target = file.path(root_dir, doc_file))
  message("Documentation created successfully at: ", file.path(root_dir, doc_file))
}

# Run the script
generate_readme_and_doc()


