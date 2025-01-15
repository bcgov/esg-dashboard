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

library(tidyverse)
library(janitor)
library(plotly)
library(reactable)
library(htmltools)

## read in data
plot_data <- readRDS("../01_data/env_plot_data.rds")

## for testing
# data <- plot_data %>% filter(Topic == "Energy use", Metric == "Total", Variable == "Industry")
# data <- plot_data %>% filter(Topic == "Energy use", Metric == "Total", Variable == "Energy source")
# data <- plot_data %>% filter(Topic == "Energy use", Metric == "Shares", Variable == "Energy source")
# data <- plot_data %>% filter(Topic == "Energy use", Metric == "Shares", Variable == "Industry")

## plotly code

# layout options to use for all charts
plotly_custom_layout <- function(plot) {
  
  plot %>%
    layout(
      title = list(x = 0), ## left justified title
      xaxis = list(tickformat = "d"), ## integers only
      legend = list(orientation = "h"),
      hoverlabel = list(namelength = -1),  ## shows full hover label regardless of length
      dragmode = FALSE,  # remove drag zoom
      modebar = list(remove = list("autoscale","hoverCompareCartesian", "lasso", "pan", 
                                   "resetscale", "select", "zoom", "zoomin", "zoomout"))#,
     # margin = list(b = 0)
    )
}

# Make data$Group into a factor for plotting
plot_order <- function(data, Variable) {
  if(Variable == "Industry") {
    data$Group <- factor(data$Group, levels = c("Manufacturing", "Mining, Quarrying, and Oil and Gas Extraction", "Forestry", "Construction"))
  }
  
  if(Variable == "Energy source") {
    data$Group <- factor(data$Group, levels = c("Electricity", "Natural Gas", "Diesel Fuel Oil, Light Fuel Oil and Kerosene",
                                                "Heavy Fuel Oil", "Still Gas and Petroleum Coke", "LPG and Gas Plant NGL",
                                                "Coal", "Wood Waste and Pulping Liquor", "Other", "Suppressed"))
  }

  data
}

# Define colors to use for plot
plot_colors <- function(data, Variable) {
  if(Variable == "Industry") {
    plot_colors <- RColorBrewer::brewer.pal(n = 5, name = "Set3")[-2] ## remove the yellows
    names(plot_colors) <- c("Manufacturing", "Mining, Quarrying, and Oil and Gas Extraction", "Forestry", "Construction")
    
  }
  
  if(Variable == "Energy source") {
    plot_colors <- RColorBrewer::brewer.pal(n = 12, name = "Set3")[-c(2,12)] ## remove the yellows
    names(plot_colors) <- c("Electricity", "Natural Gas", "Diesel Fuel Oil, Light Fuel Oil and Kerosene",
                            "Heavy Fuel Oil", "Still Gas and Petroleum Coke", "LPG and Gas Plant NGL",
                            "Coal", "Wood Waste and Pulping Liquor", "Other", "Suppressed")
  }
  
  plot_colors
}

## line plots
line_plot <- function(data, Variable) {
  
   data <- plot_order(data, Variable)
   colors <- plot_colors(data, Variable)
  
  plot_ly(data, x = ~Year, y = ~Value, color = ~Group, 
          colors = colors,
          type = 'scatter', mode = 'lines+markers',
          text = ~paste0(Group, ": ", format(round_half_up(Value, digits = 1), nsmall = 1)),
          textposition = "none",
          hoverinfo = "text",
          hovertemplate = "%{text}<extra></extra>") %>%
    layout(
      title = list(text = unique(data$Title)),
      xaxis = list(title = ""),
      yaxis = list(title = unique(data$Unit)),
      hovermode = FALSE
      #hovermode = "x unified" # Unified hover mode
    ) %>%
    plotly_custom_layout()
}

## stacked area plots
area_plot <- function(data, Variable){
  data <- plot_order(data, Variable) %>% mutate(Group = fct_rev(Group))
  colors <- plot_colors(data, Variable)
  
  plot_ly(data, x = ~Year, y = ~Value, color = ~Group, 
          colors = colors, type = 'scatter', mode = 'none',
          ## make chart stacked
          stackgroup='one', fill = 'tonexty',
          text = ~paste0(Group, ": ", format(round_half_up(Value, digits = 1), nsmall = 1)),
          textposition = "none",
          hoverinfo = "text",
          hovertemplate = "%{text}<extra></extra>") %>%
    layout(
      #legend = list(traceorder = "reversed"),
      title = list(text = unique(data$Title)),
      xaxis = list(title = ""),
      yaxis = list(title = "Share (%)", range = c(0, 100)),
      hovermode = FALSE
      #hovermode = "x unified" # Unified hover mode
    ) %>%
    plotly_custom_layout()
}

## create plots
Charts <- plot_data %>%
  group_by(Topic, Metric, Variable) %>%
  nest() %>%
  mutate(Plot = case_when(
    Metric == "Total" ~ map2(data, Variable, line_plot),
    Metric == "Shares" ~map2(data, Variable, area_plot)))
  
##Charts[8,"Plot"][[1]]
 


