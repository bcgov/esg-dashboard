# Copyright 2024 Province of British Columbia
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
library(scales)

## Full time ----

p_fulltime <- plot_ly(data = full_time %>% filter(Industry == "Total, all industries"),
        x = ~REF_DATE,
        y = ~perc_ft,
        color = ~Industry,
        type = "scatter",
        mode = "lines+markers",
        text = ~ paste0(Industry, ": ", percent(perc_ft, accuracy = 0.1)),
        textposition = "none",
        hovertemplate = "%{x} %{text}<extra></extra>") %>%
  add_trace(data = full_time %>% filter(Industry != "Total, all industries"),
            x = ~REF_DATE, 
            y = ~perc_ft,
            color = ~Industry,
            type = "scatter",
            mode = "lines+markers",
            visible = "legendonly") %>%
  layout(yaxis = list(title = "", tickformat = "0%"),
         xaxis = list(title = "", hoverformat = "%Y", tickformat = "%Y"),
         legend = list(orientation = "h"),
         hovermode = "x unified",
         #hovermode = FALSE, ## can turn hover on with menu option on live chart
         modebar = list(remove = list("autoscale","hoverCompareCartesian", "lasso", "pan", 
                                      "resetscale", "select", "zoom", "zoomin", "zoomout")),
         margin = list(l = 0))

## Age ----
age_plot <- function(data) {
  plot_ly(data, 
          x = ~REF_DATE, 
          y = ~perc_15_24, 
          name = '15 to 24 years', 
          type = 'scatter', 
          mode = 'lines+markers', 
          text = ~ paste0(Industry, ": ", percent(perc_15_24, accuracy = 0.1)),
          textposition = "none",
          hovertemplate = "%{x} %{text}<extra></extra>") %>%
    add_trace(y = ~perc_25_54, 
              name = "25 to 54 years", 
              type = 'scatter', 
              mode = 'lines+markers', 
              text = ~ paste0(Industry, ": ", percent(perc_15_24, accuracy = 0.1)),
              textposition = "none",
              hovertemplate = "%{x} %{text}<extra></extra>") %>%
    add_trace(y = ~perc_55, 
              name = "55 years and over", 
              type = 'scatter',
              mode = 'lines+markers', 
              text = ~ paste0(Industry, ": ", percent(perc_15_24, accuracy = 0.1)),
              textposition = "none",
              hovertemplate = "%{x} %{text}<extra></extra>") %>%
    layout(yaxis = list(title = "", tickformat = "0%"),
           xaxis = list(title = "", hoverformat = "%Y", tickformat = "%Y"),
           legend = list(orientation = "h"),
           hovermode = "x unified",
           #hovermode = FALSE, ## can turn hover on with menu option on live chart
           modebar = list(remove = list("autoscale","hoverCompareCartesian", "lasso", "pan", 
                                        "resetscale", "select", "zoom", "zoomin", "zoomout")),
           margin = list(l = 0))
}

p_age_tot <- age %>% 
  filter(Industry == "Total, all industries") %>%
  age_plot()

p_age_agr <- age %>% 
  filter(Industry == "Agriculture") %>%
  age_plot()


