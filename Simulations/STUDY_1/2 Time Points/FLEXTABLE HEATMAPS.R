{r}
#| label: "create-heatmap-function-flextable"
#| echo: true
#| message: false
#| warning: false

library(flextable)

create_flextable_heatmap <- function(data, transition_probability) {
  # Keep only the required columns
  data <- data %>%
    select(
      N_Label,
      Population,
      average,
      Coverage,
      Power,
      Parameter_Bias,
      SE_Bias
    ) %>%
    as.data.frame()
  
  # Create the flextable
  ft <- flextable(data) %>%
    set_header_labels(
      N_Label = "N",
      Population = "Transition",
      average = "Estimated Probability",
      Coverage = "Coverage",
      Power = "Power",
      Parameter_Bias = "Parameter Bias",
      SE_Bias = "Standard Error Bias"
    )
  
  # Apply special formatting to headers
  ft <- compose(ft, part = "header", j = "N_Label", value = as_paragraph(as_i("N")))
  ft <- compose(ft, part = "header", j = "Population", value = as_paragraph("Transition"))
  ft <- compose(ft, part = "header", j = "average", value = as_paragraph("Estimated\nProbability"))
  ft <- compose(ft, part = "header", j = "Coverage", value = as_paragraph("Coverage"))
  ft <- compose(ft, part = "header", j = "Power", value = as_paragraph("Power"))
  ft <- compose(ft, part = "header", j = "Parameter_Bias", value = as_paragraph("Parameter\nBias"))
  ft <- compose(ft, part = "header", j = "SE_Bias", value = as_paragraph("Standard\nError Bias"))
  
  # Set column widths
  ft <- width(ft, j = "N_Label", width = 1)
  ft <- width(ft, j = "Population", width = 0.6)
  ft <- width(ft, j = "average", width = 0.6)
  ft <- width(ft, j = "Coverage", width = 0.6)
  ft <- width(ft, j = "Power", width = 0.6)
  ft <- width(ft, j = "Parameter_Bias", width = 0.6)
  ft <- width(ft, j = "SE_Bias", width = 0.6)
  
  # Correct vertical centering: Merge "N = _" across 6-row blocks
  ft <- merge_v(ft, j = "N_Label")
  
  # Ensure "N = ..." appears only ONCE in the center of the 6-row block
  ft <- compose(
    ft,
    part = "body",
    j = "N_Label",
    i = which(data$N_Label != ""),
    value = as_paragraph(data$N_Label[which(data$N_Label != "")])
  )
  
  # Fully remove duplicate N values in merged rows
  ft <- compose(
    ft,
    part = "body",
    j = "N_Label",
    i = which(data$N_Label == ""),
    value = as_paragraph("")
  )
  
  # Align vertically centered
  ft <- valign(ft, j = "N_Label", valign = "center", part = "body")
  
  # Center all text
  ft <- align(ft, align = "center", part = "all")
  
  # Apply number formatting (3 decimal places for all numeric columns)
  ft <- colformat_num(
    ft,
    j = c("average", "Coverage", "Power", "Parameter_Bias", "SE_Bias"),
    decimals = 3
  )
  
  # Add spanner header
  ft <- add_header_row(
    ft,
    values = c(" ", " ", " ", " ", " ", "Bias"),
    colwidths = c(1, 1, 1, 1, 1, 2)
  )
  
  # Define a transparent border
  no_border <- fp_border(color = "transparent", width = 0)
  
  # Remove ONLY the bottom border under the first and last columns
  ft <- hline(ft, i = 1, j = 1, border = no_border, part = "header")
  ft <- hline(ft, i = 1, j = 7, border = no_border, part = "header")
  
  # Autofit table layout
  ft <- set_table_properties(ft, layout = "fixed")
  
  # Apply font settings
  ft <- font(ft, fontname = "Avenir Next", part = "all")
  
  # Style the separator rows
  separator_rows <- which(!sapply(data$N_Label, function(x) is.numeric(as.numeric(x))))
  if (length(separator_rows) > 0) {
    ft <- bold(ft, i = separator_rows, bold = TRUE, part = "body")
    ft <- merge_h(ft, i = separator_rows, part = "body")
    ft <- align(ft, i = separator_rows, align = "center", part = "body")
  }
  
  # Add heatmap conditional coloring (only for numeric rows)
  numeric_rows <- which(sapply(data$Parameter_Bias, is.numeric))
  if (any(!(data$Parameter_Bias[numeric_rows] >= -9.99 & data$Parameter_Bias[numeric_rows] <= 9.99), na.rm = TRUE)) {
    ft <- ft %>%
      bg(
        j = "Parameter_Bias",
        i = numeric_rows[!(data$Parameter_Bias[numeric_rows] >= -9.99 & data$Parameter_Bias[numeric_rows] <= 9.99)],
        bg = scales::col_numeric(
          palette = c("#113386", "#DAE3FA", "#113386"),
          domain = c(-40, 40)
        )(data$Parameter_Bias[numeric_rows]),
        part = "body"
      ) %>%
      add_footer_lines(
        values = "Note. Darker blue indicates Parameter Bias values outside ±9.99."
      )
  }
  
  if (any(!(data$SE_Bias[numeric_rows] >= -4.99 & data$SE_Bias[numeric_rows] <= 4.99), na.rm = TRUE)) {
    ft <- ft %>%
      bg(
        j = "SE_Bias",
        i = numeric_rows[!(data$SE_Bias[numeric_rows] >= -4.99 & data$SE_Bias[numeric_rows] <= 4.99)],
        bg = scales::col_numeric(
          palette = c("#781049", "#FDEAF4", "#781049"),
          domain = c(-80, 80)
        )(data$SE_Bias[numeric_rows]),
        part = "body"
      ) %>%
      add_footer_lines(
        values = "Note. Darker red indicates Standard Error Bias values outside ±4.99."
      )
  }
  
  if (any(data$Coverage[numeric_rows] < 0.93 | data$Coverage[numeric_rows] > 0.979, na.rm = TRUE)) {
    ft <- ft %>%
      bg(
        j = "Coverage",
        i = numeric_rows[(data$Coverage[numeric_rows] < 0.93 | data$Coverage[numeric_rows] > 0.979)],
        bg = scales::col_numeric(
          palette = c("#93C6B1", "white"),
          domain = c(0, 1)
        )(data$Coverage[numeric_rows]),
        part = "body"
      ) %>%
      add_footer_lines(
        values = "Note. Green indicates Coverage values outside 0.93–0.979."
      )
  }
  
  if (any(data$Power[numeric_rows] < 0.8, na.rm = TRUE)) {
    ft <- ft %>%
      bg(
        j = "Power",
        i = numeric_rows[data$Power[numeric_rows] < 0.8],
        bg = scales::col_numeric(
          palette = c("#502CD1", "white"),
          domain = c(0, 1)
        )(data$Power[numeric_rows]),
        part = "body"
      ) %>%
      add_footer_lines(
        values = "Note. Purple indicates Power values below 0.80."
      )
  }
  
  return(ft)
}

{r}
#| label: "render-heatmap"
#| echo: true
#| message: false
#| warning: false

# Prepare test_map by adding grouping rows
test_map_with_groups <- rbind(
  data.frame(N_Label = "Mover Probabilities", Population = "", average = "", Coverage = "", Power = "", Parameter_Bias = "", SE_Bias = ""),
  test_map[1:12, ],
  data.frame(N_Label = "Stayer Probabilities", Population = "", average = "", Coverage = "", Power = "", Parameter_Bias = "", SE_Bias = ""),
  test_map[13:24, ]
)

# Create and display the flextable heatmap
ft_heatmap <- create_flextable_heatmap(test_map_with_groups, "Mover & Stayers")

ft_heatmap
# Save as PNG with the correct path
invisible(save_as_image(
  ft_heatmap,
  path = here("Simulations", "STUDY_1", "2 Time Points", "zHEATMAPS", "z2t_heatmaps", "2T_L_L.png")
))

