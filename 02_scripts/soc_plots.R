# Copyright 2025 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#***
#* This script is sourced by esg-dashboard.qmd
#* Requires soc_plot_data.rds created by 01_data/data.R
#***

# library(tidyverse)
# library(janitor)
# library(plotly)
# library(reactable)
# library(htmltools)

## read in data
plot_data <- readRDS("01_data/soc_plot_data.rds")

# layout options to use for all charts
plotly_custom_layout_soc <- function(plot) {
  
  plot %>%
    layout(
      title = list(x = 0, y = 0.96), ## left justified title
      xaxis = list(tickformat = "d"), ## integers only
      legend = list(orientation = "h"),
      hoverlabel = list(namelength = -1),  ## shows full hover label regardless of length
      dragmode = FALSE,  # remove drag zoom
      modebar = list(remove = list("autoscale","hoverCompareCartesian", "lasso", "pan", 
                                   "resetscale", "select", "zoom", "zoomin", "zoomout")),
      margin = list(t = 75)
    )
}

line_plot_1group <- function(data, Group1) {
  plot_ly(data, x = ~Year, y = ~Value, color = ~Group2, 
          colors = ~Color,
          type = 'scatter', mode = 'lines+markers',
          text = ~paste0("<b>", Year, "</b>, ",Group2, ": ", format(round_half_up(Value, digits = 1), nsmall = 1)),
          textposition = "none",
          hoverinfo = "text",
          hovertemplate = "%{text}<extra></extra>") %>%
    layout(
      title = list(text = paste0(unique(data$Metric), "<br><span style='font-size:14'>", Group1, "<br>", unique(data$Region), "</span>")),
      xaxis = list(title = ""),
      yaxis = list(title = unique(data$Unit)),
      hovermode = FALSE
      #hovermode = "x unified" # Unified hover mode
    ) %>%
    plotly_custom_layout_soc()
}

line_plot_2groups <- function(data) {
  plot_ly(data, x = ~Year, y = ~Value, color = ~Group1, linetype = ~Group2,   
          colors = ~Color,
          type = 'scatter', mode = 'lines+markers',
          text = ~paste0("<b>", Year, "</b>, ",Group2, ": ", format(round_half_up(Value, digits = 1), nsmall = 1)),
          textposition = "none",
          hoverinfo = "text",
          hovertemplate = "%{text}<extra></extra>") %>%
    layout(
      title = list(text = paste0(unique(data$Metric), "<br><span style='font-size:14'>Total, all industries<br>", unique(data$Region), "</span>")),
      xaxis = list(title = ""),
      yaxis = list(title = unique(data$Unit)),
      hovermode = FALSE
      #hovermode = "x unified" # Unified hover mode
    ) %>%
    plotly_custom_layout_soc()
  
}

## Employment by age group ----
age_plots <- plot_data %>% 
  filter(Metric == "Employment by age group") %>%
  mutate(Color = case_when(
    Group2 == "15 to 24 years" ~ RColorBrewer::brewer.pal(n = 4, name = "Set3")[1],
    Group2 == "25 to 54 years" ~ RColorBrewer::brewer.pal(n = 4, name = "Set3")[3],
    Group2 == "55 years and over" ~ RColorBrewer::brewer.pal(n = 4, name = "Set3")[4]),
    Group2 = fct_inorder(Group2)) %>%
  group_by(Group1) %>%
  nest() %>%
  mutate(Plot = map2(data, Group1, line_plot_1group)) %>%
  select(Group1, Plot)

age_tbl <- browsable( ## make objects render as HTML by default when printed at the console
  tagList(
    ## use this to set initial filter value
    ## https://stackoverflow.com/questions/72946933/set-default-filter-to-reactable-table-in-r
    htmlwidgets::onStaticRenderComplete("$(document).ready(() => Reactable.setFilter('age-plot-table', 'Group1', 'Total, all industries'));"),
    # custom Metric filter
    tags$span(
      style= "display:flex; flex-direction:row; flex-wrap:nowrap; align-items: baseline;",
      tags$label("Select Industry:", `for` = "industry-selector-age"),
      tags$select(
        id = "industry-selector-age",
        style = "padding: 0.3rem 0.5rem; margin:0.5rem; border:solid 0.85px;width:50%",
        onchange = "Reactable.setFilter('age-plot-table', 'Group1', this.value)",
        lapply(unique(age_plots$Group1), tags$option)
      )),
    reactable(age_plots, compact = TRUE, pagination = FALSE,
              elementId = "age-plot-table",
              columns = list(
                Group1 = colDef(show = FALSE),
                Plot = colDef(
                  header = JS('function(column) {return ""}'),
                  cell = function(value) div(value)
                )
              ))))

## Mean weekly overtime hours by gender ----
ot_plots <- plot_data %>% 
  filter(Metric == "Mean weekly overtime hours by gender") %>%
  mutate(Color = case_when(
    Group2 == "Men+" ~ RColorBrewer::brewer.pal(n = 4, name = "Set3")[1],
    Group2 == "Women+" ~ RColorBrewer::brewer.pal(n = 4, name = "Set3")[3])) %>%
  group_by(Group1) %>%
  nest() %>%
  mutate(Plot = map2(data, Group1, line_plot_1group)) %>%
  select(Group1, Plot)

ot_tbl <- browsable( ## make objects render as HTML by default when printed at the console
  tagList(
    ## use this to set initial filter value
    ## https://stackoverflow.com/questions/72946933/set-default-filter-to-reactable-table-in-r
    htmlwidgets::onStaticRenderComplete("$(document).ready(() => Reactable.setFilter('ot-plot-table', 'Group1', 'Total, all industries'));"),
    # custom Metric filter
    tags$span(
      style= "display:flex; flex-direction:row; flex-wrap:nowrap; align-items: baseline;",
      tags$label("Select Industry:", `for` = "industry-selector-ot"),
      tags$select(
        id = "industry-selector-ot",
        style = "padding: 0.3rem 0.5rem; margin:0.5rem; border:solid 0.85px;width:50%",
        onchange = "Reactable.setFilter('ot-plot-table', 'Group1', this.value)",
        lapply(unique(ot_plots$Group1), tags$option)
      )),
    reactable(ot_plots, compact = TRUE, pagination = FALSE,
              elementId = "ot-plot-table",
              columns = list(
                Group1 = colDef(show = FALSE),
                Plot = colDef(
                  header = JS('function(column) {return ""}'),
                  cell = function(value) div(value)
                )
              ))))


## Representation of women by compensation level ----
complvl_plot <- plot_data %>% 
  filter(Metric == "Representation of women by compensation level") %>%
  mutate(Color = case_when(
    Group2 == "Total employees, all wages" ~ RColorBrewer::brewer.pal(n = 6, name = "Set3")[1],
    Group2 == "Less than $12.00" ~ RColorBrewer::brewer.pal(n = 6, name = "Set3")[3],
    Group2 == "$12.00 to $19.99" ~ RColorBrewer::brewer.pal(n = 6, name = "Set3")[4],
    Group2 == "$20.00 to $29.99" ~ RColorBrewer::brewer.pal(n = 6, name = "Set3")[5],
    Group2 == "$30.00 or more" ~ RColorBrewer::brewer.pal(n = 6, name = "Set3")[6]),
    Group2 = fct_inorder(Group2)) %>%
  group_by(Group1) %>%
  nest() %>%
  mutate(Plot = map2(data, Group1, line_plot_1group)) %>%
  select(Group1, Plot)

## Work absences by gender and presence of children ----
wkabsence_plot <- plot_data %>%
  filter(Metric == "Work absences by gender and presence of children") %>%
  mutate(Color = case_when(
    Group1 == "Men+" ~ RColorBrewer::brewer.pal(n = 4, name = "Set3")[1],
    Group1 == "Women+" ~ RColorBrewer::brewer.pal(n = 4, name = "Set3")[3])) %>%
  line_plot_2groups()
  




