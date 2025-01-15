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
library(plotly)
library(reactable)
library(htmltools)

## read in data
plot_data <- readRDS("../01_data/env_plot_data.rds")

## for testing
data <- plot_data %>% filter(Topic == "Energy use", Metric == "Total", Variable == "Industry")
data <- plot_data %>% filter(Topic == "Energy use", Metric == "Total", Variable == "Energy source")

## plotly code

# layout options to use for all charts
plotly_custom_layout <- function(plot) {
  
  plot %>%
    layout(
      title = list(x = 0), ## left justified title
      xaxis = list(tickformat = "d"), ## integers only
      legend = list(orientation = "h", traceorder = "reversed"),
      hoverlabel = list(namelength = -1),  ## shows full hover label regardless of length
      dragmode = FALSE,  # remove drag zoom
      modebar = list(remove = list("autoscale","hoverCompareCartesian", "lasso", "pan", 
                                   "resetscale", "select", "zoom", "zoomin", "zoomout"))#,
     # margin = list(b = 0)
    )
}

## line plots
line_plot <- function(data) {
  
  if(unique(data$Variable) == "Industry") {
    data$Group <- factor(data$Group, levels = c("Construction", "Forestry", "Mining, Quarrying, and Oil and Gas Extraction", "Manufacturing"))
  }
  
  if(unique(data$Variable) == "Energy source") {
    data$Group <- factor(data$Group, levels = c("Electricity", "Natural Gas", "Diesel Fuel Oil, Light Fuel Oil and Kerosene",
                                                "Heavy Fuel Oil", "Still Gas and Petroleum Coke", "LPG and Gas Plant NGL",
                                                "Coal", "Wood Waste and Pulping Liquor", "Other"))
    
    ## fct_drop to drop unused levels
    ## actually want to factor based on values
    ## create a color vector to color the energy sources the same across all charts
  }
  
  plot_ly(data, x = ~Year, y = ~Value, color = ~Group, 
          colors = "Set2", type = 'scatter', mode = 'lines+markers') %>%
    layout(
      title = list(text = unique(data$Title)),
      xaxis = list(title = ""),
      yaxis = list(title = unique(data$Unit)),
      hovermode = "x unified" # Unified hover mode
    ) %>%
    plotly_custom_layout()
  
}


## stacked area plots

