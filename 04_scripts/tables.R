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
library(reactable)
library(htmltools)
library(tippy)

table_data <- readRDS("../01_data/table_data.rds")

## Summary: Total ----
total_data <- table_data %>% filter(str_detect(Industry, "Total")) %>% select(-Industry_Order)
total_outer <- total_data %>% filter((is.na(Age) | Age == "15 years and over") & (is.na(Gender) | Gender == "Both genders"))
total_age <- total_data %>% filter(!is.na(Age) & Age != "15 years and over")
total_gender <- total_data %>% filter(!is.na(Gender) & Gender != "Both genders")

t_total <- reactable(total_outer,
                     # add desired functionality
                     compact = TRUE, highlight = TRUE, pagination = FALSE, onClick = "expand", 
                     ## default column formatting
                  #   defaultColDef = colDef(html = TRUE), ## this makes the nested tables not work
                     # Special column formatting
                     columns = list(
                       # set widths
                       Category = colDef(minWidth = 100),
                       Metric = colDef(minWidth = 250, html = TRUE),
                       Industry = colDef(minWidth = 125),
                       Value = colDef(minWidth = 75),
                       Unit = colDef(minWidth = 50, html = TRUE),
                       Year = colDef(minWidth = 50),
                       Region = colDef(minWidth = 100),
                       Age = colDef(show = FALSE),
                       Gender = colDef(show = FALSE)),
                     # expandable details
                     details = function(index) {
                       # Employment by age table
                       t_age <- total_age %>%
                         filter(Metric == total_outer$Metric[index]) %>%
                         select(Age, Value, Unit)
                       
                       # Average overtime hours of all employees table
                       t_gender <- total_gender %>%
                         filter(Metric == total_outer$Metric[index]) %>%
                         select(Gender, Value, Unit)
                       
                       ## show nested table only for employment by age
                       if(total_outer$Metric[index] == "Employment by age group") {
                         ## wrap table in div to add padding
                         htmltools::div(style = "padding-left: 2rem",
                                        reactable(t_age, outlined = TRUE)
                         )
                       ## show nested table only for overtime
                       } else if(total_outer$Metric[index] == "Mean weekly overtime hours of all employees"){
                         ## wrap table in div to add padding
                         htmltools::div(style = "padding-left: 2rem",
                                        reactable(t_gender, outlined = TRUE)
                         )
                       }
                     })

## Summary: Environmental ----
env_data <- table_data %>% 
  filter(!str_detect(Industry, "Total") & Category == "Environmental") %>%
  select(Industry_Order, Industry, Metric, Value, Unit, Year, Region) %>%
  ## create a label variable for the "filter metric" select input as option tags cannot have html tags in them
  mutate(select_label = str_remove_all(Metric, "</?sub>"))

t_env <- browsable( ## make objects render as HTML by default when printed at the console
  tagList(
    tags$span( ## use span as it is a container for in-line content
      style="display:flex; flex-direction:row; flex-wrap:wrap;", ## use flex-box layout to handle changes in screen size
      tags$span( ## new span container for label and input to prevent wrapping on screen changes
        style= "display:flex; flex-direction:row; flex-wrap:nowrap; align-items: baseline;",
        # custom Industry search
        tags$label("Filter Industries:", `for` = "industry-search"),
        tags$input(
          id = "industry-search",
          placeholder = "All industries",
          type = "text",
          style = "padding: 0.25rem 0.5rem; margin: 0.5rem; border:solid 0.85px;",
          oninput = "Reactable.setSearch('expansion-table-env', this.value)"
          )),
      
      # custom Metric filter
      tags$span(
        style= "display:flex; flex-direction:row; flex-wrap:nowrap; align-items: baseline;",
        tags$label("Filter Metrics:", `for` = "metric-filter"),
        tags$select(
          id = "metric-filter",
          style = "padding: 0.3rem 0.5rem; margin:0.5rem; border:solid 0.85px;width:50%",
          onchange = "Reactable.setFilter('expansion-table-env', 'Metric', this.value)",
          tags$option("All metrics", value = ""),
          map2(unique(env_data$Metric), unique(env_data$select_label), ~tags$option(.y, value = .x))
          ))),
    
    tags$span(
      # expand/ collapse all button
      tags$button(
        "Expand/collapse all",
        class = "bcds-react-aria-Button",
        onclick = "Reactable.toggleAllRowsExpanded('expansion-table-env')"),
      
      # download button
      tags$button(
        "Download table as CSV",
        class = "bcds-react-aria-Button",
        onclick = "Reactable.downloadDataCSV('expansion-table-env', 'environmental_metrics_summary.csv')"
        )),
    
    # table
    reactable(env_data, groupBy = "Industry_Order", elementId = "expansion-table-env",
              # add desired functionality
              compact = TRUE, highlight = TRUE, pagination = FALSE, onClick = "expand",
              # Special column formatting
              columns = list(
                # set widths
                Industry_Order = colDef(header = "",
                                        maxWidth = 55,
                                        align = "right",
                                        # display only the number of nested rows (i.e., metrics)
                                        grouped = JS("function(cellInfo) { return '(' + cellInfo.subRows.length + ')' }")),
                Industry = colDef(minWidth = 250,
                                  # create "aggregate" value of industry to display in the collapsed table
                                  aggregate = "unique"),
                Metric = colDef(minWidth = 250, html = TRUE),
                Value = colDef(minWidth = 50),
                Unit = colDef(minWidth = 50, html = TRUE),
                Year = colDef(minWidth = 50),
                Region = colDef(minWidth = 100),
                select_label = colDef(show = FALSE)))
    ))
    
## Summary: Social ----
soc_data <- table_data %>% filter(!str_detect(Industry, "Total") & Category == "Social") %>% select(Industry_Order, Industry, Metric, everything(), -Category) 
soc_outer <- soc_data %>% filter((is.na(Age) | Age == "15 years and over") & (is.na(Gender) | Gender == "Both genders"))
soc_age <- soc_data %>% filter(!is.na(Age) & Age != "15 years and over")
soc_gender <- soc_data %>% filter(!is.na(Gender) & Gender != "Both genders")

t_soc <- browsable( ## make objects render as HTML by default when printed at the console
  tagList(
    tags$span(
      style="display:flex; flex-direction:row; flex-wrap:wrap;",
    tags$span(
      style= "display:flex; flex-direction:row; flex-wrap:nowrap; align-items: baseline;",
    # custom Industry search
      tags$label("Filter Industries:", `for` = "industry-search"),
      tags$input(
        id = "industry-search",
        placeholder = "All industries",
        type = "text",
        style = "padding: 0.25rem 0.5rem; margin: 0.5rem; border:solid 0.85px;",
        oninput = "Reactable.setSearch('expansion-table-soc', this.value)"
    )),
    
    # custom Metric filter
    tags$span(
      style= "display:flex; flex-direction:row; flex-wrap:nowrap; align-items: baseline;",
      tags$label("Filter Metrics:", `for` = "metric-filter"),
      tags$select(
        id = "metric-filter",
        style = "padding: 0.3rem 0.5rem; margin:0.5rem; border:solid 0.85px;width:50%",
        onchange = "Reactable.setFilter('expansion-table-soc', 'Metric', this.value)",
        tags$option("All metrics", value = ""),
        lapply(unique(soc_outer$Metric), tags$option)
        ))),
    
    tags$span(
    # expand/ collapse all button
    tags$button(
      "Expand/collapse all",
      class = "bcds-react-aria-Button",
      onclick = "Reactable.toggleAllRowsExpanded('expansion-table-soc')"),
    
    # download button
    tags$button(
      "Download table as CSV",
      class = "bcds-react-aria-Button",
      onclick = "Reactable.downloadDataCSV('expansion-table-soc', 'social_metrics_summary.csv')"
    )),
    
    # table
    reactable(soc_outer, groupBy = "Industry_Order", elementId = "expansion-table-soc",
              # add desired functionality
              compact = TRUE, highlight = TRUE, pagination = FALSE, onClick = "expand",
              # Special column formatting
              columns = list(
                # set widths
                Industry_Order = colDef(header = "",
                                        maxWidth = 55,
                                        align = "right",
                                        # display only the number of nested rows (i.e., metrics)
                                        grouped = JS("function(cellInfo) { return '(' + cellInfo.subRows.length + ')' }")),
                Industry = colDef(minWidth = 250,
                                  html = TRUE,
                                  # create "aggregate" value of industry to display in the collapsed table
                                  aggregate = "unique"),
                Metric = colDef(minWidth = 250, html = TRUE),
                Value = colDef(minWidth = 50),
                Unit = colDef(minWidth = 50, html = TRUE),
                Year = colDef(minWidth = 50),
                Region = colDef(minWidth = 100),
                Age = colDef(show = FALSE),
                Gender = colDef(show = FALSE)),
              # expandable details
              details = colDef(
                width = 20,
                details = function(index) {
                # Employment by age table
                t_age <- soc_age %>%
                  filter(Industry == soc_outer$Industry[index]) %>%
                  filter(Metric == soc_outer$Metric[index]) %>%
                  select(Age, Value, Unit)
                
                # Average overtime hours of all employees table
                t_gender <- soc_gender %>%
                  filter(Industry == soc_outer$Industry[index]) %>%
                  filter(Metric == soc_outer$Metric[index]) %>%
                  select(Gender, Value, Unit)
                
                ## show nested table only for employment by age
                if(soc_outer$Metric[index] == "Employment by age group") {
                  reactable(t_age, outlined = TRUE)
                  
                ## show nested table only for overtime
                } else if(soc_outer$Metric[index] == "Mean weekly overtime hours of all employees"){
                  reactable(t_gender, outlined = TRUE)
                }
              }))))

