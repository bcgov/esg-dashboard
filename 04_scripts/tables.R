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
total_data <- table_data %>% filter(str_detect(Industry, "Total"))
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
  select(-Category, -Age, -Gender)

t_env <- htmltools::browsable(
  tagList(
    tags$button(
      class = "bcds-react-aria-Button",
      "Expand/collapse all",
      onclick = "Reactable.toggleAllRowsExpanded('expansion-table-env')"
    ),
    
    reactable(env_data, groupBy = "Industry", elementId = "expansion-table-env",
              # add desired functionality
              compact = TRUE, highlight = TRUE, pagination = FALSE, onClick = "expand", filterable = TRUE,
              ## default column formatting
              defaultColDef = colDef(html = TRUE),
              # Special column formatting
              columns = list(
                # set widths
                Industry = colDef(minWidth = 250),
                Metric = colDef(minWidth = 250),
                Value = colDef(minWidth = 50),
                Unit = colDef(minWidth = 50, html = TRUE),
                Year = colDef(minWidth = 50),
                Region = colDef(minWidth = 100)))
    ))
    
## Summary: Social ----
soc_data <- table_data %>% filter(!str_detect(Industry, "Total") & Category == "Social") %>% select(-Category)
soc_outer <- soc_data %>% filter((is.na(Age) | Age == "15 years and over") & (is.na(Gender) | Gender == "Both genders"))
soc_age <- soc_data %>% filter(!is.na(Age) & Age != "15 years and over")
soc_gender <- soc_data %>% filter(!is.na(Gender) & Gender != "Both genders")

## tooltip function for non-grouped cells
# See the ?tippy documentation to learn how to customize tooltips
with_tooltip <- function(value, tooltip, ...) {
  div(style = "text-decoration: underline; text-decoration-style: dotted; cursor: help",
      tippy(value, tooltip, ...))
}

t_soc <- htmltools::tagList(
    tags$script(HTML("document.addEventListener('DOMContentLoaded', function() {
                        tippy('.tooltip-cell');
                      });")),
    tags$button(
      "Expand/collapse all",
      class = "bcds-react-aria-Button",
      onclick = "Reactable.toggleAllRowsExpanded('expansion-table-soc')"),
    reactable(soc_outer, groupBy = "Industry", elementId = "expansion-table-soc",
              # add desired functionality
              compact = TRUE, highlight = TRUE, pagination = FALSE, onClick = "expand", filterable = TRUE,
              ## default column formatting
             # defaultColDef = colDef(html = TRUE),
              # Special column formatting
              columns = list(
                # set widths
                Industry = colDef(minWidth = 250,
                                  html = TRUE,
                                  grouped = JS("function(cellInfo) {
                                                 const cellValue = cellInfo.value;
                                                 if (cellValue === 'Energy') {
                                                   const tooltip = `This combines the North American Industry Classification System (NAICS) codes 211, 212, 213 and 324.`;
                                                   return `<span class='tooltip-cell' style='text-decoration: underline; text-decoration-style: dotted; cursor: help' data-tippy-content='${tooltip}'>${cellInfo.value + ' (' + cellInfo.subRows.length + ')'}</span>`;
                                                 }
                                                 return cellInfo.value + ' (' + cellInfo.subRows.length + ')';
                                                }")),
                Metric = colDef(minWidth = 250, html = TRUE),
                Value = colDef(minWidth = 50),
                Unit = colDef(minWidth = 50, html = TRUE),
                Year = colDef(minWidth = 50),
                Region = colDef(minWidth = 100),
                Age = colDef(show = FALSE),
                Gender = colDef(show = FALSE)),
              # expandable details
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
                  ## wrap table in div to add padding
                  htmltools::div(style = "padding-left: 2rem",
                                 reactable(t_age, outlined = TRUE)
                  )
                ## show nested table only for overtime
                } else if(soc_outer$Metric[index] == "Mean weekly overtime hours of all employees"){
                  ## wrap table in div to add padding
                  htmltools::div(style = "padding-left: 2rem",
                                 reactable(t_gender, outlined = TRUE)
                  )
                }
              }))



# 
# ## event listener for tooltips to work
# tags$script(HTML("
# document.addEventListener('DOMContentLoaded', function() {
#   tippy('.tooltip-cell');
# });
# "))

# ## create tooltips for the table
# tooltip_soc_industry <- "
# function(cellInfo) {
#   const cellValue = cellInfo.value;
#   if (cellValue === 'Energy') {
#     const tooltip = `This combines the North American Industry Classification System (NAICS) codes 211, 212, 213 and 324.`;
#     return `<span class='tooltip-cell' style='text-decoration: underline; text-decoration-style: dotted; cursor: help' data-tippy-content='${tooltip}'>${cellValue}</span>`;
#   }
#   return cellValue;
# }
# "
# t_soc <- htmltools::browsable(
#   tagList(
#     tags$button(
#       class = "bcds-react-aria-Button",
#       "Expand/collapse all",
#       onclick = "Reactable.toggleAllRowsExpanded('expansion-table-soc')"
#     ),
# 
#     reactable(soc_outer, groupBy = "Industry", elementId = "expansion-table-soc",
#               # add desired functionality
#               compact = TRUE, highlight = TRUE, pagination = FALSE, onClick = "expand", filterable = TRUE,
#               # Special column formatting
#               columns = list(
#                 # set widths
#                 Industry = colDef(minWidth = 250,
#                                   grouped = JS(tooltip_soc_industry)),
#                 Metric = colDef(minWidth = 250,
#                                 cell = function(value){
#                                   if(value == "Employment by age")
#                                     with_tooltip(value, "Miles per US gallon")
#                                   else
#                                     value
#                                   }),
#                 Value = colDef(minWidth = 50),
#                 Unit = colDef(minWidth = 50, html = TRUE),
#                 Year = colDef(minWidth = 50),
#                 Region = colDef(minWidth = 100),
#                 Age = colDef(show = FALSE),
#                 Gender = colDef(show = FALSE)),
#               # expandable details
#               details = function(index) {
#                 # Employment by age table
#                 t_age <- soc_age %>%
#                   filter(Industry == soc_outer$Industry[index]) %>%
#                   filter(Metric == soc_outer$Metric[index]) %>%
#                   select(Age, Value, Unit)
# 
#                 # Average overtime hours of all employees table
#                 t_gender <- soc_gender %>%
#                   filter(Industry == soc_outer$Industry[index]) %>%
#                   filter(Metric == soc_outer$Metric[index]) %>%
#                   select(Gender, Value, Unit)
# 
#                 ## show nested table only for employment by age
#                 if(soc_outer$Metric[index] == "Employment by age") {
#                   ## wrap table in div to add padding
#                   htmltools::div(style = "padding-left: 2rem",
#                                  reactable(t_age, outlined = TRUE)
#                   )
#                 } else if(soc_outer$Metric[index] == "Average overtime hours of all employees"){
#                   ## wrap table in div to add padding
#                   htmltools::div(style = "padding-left: 2rem",
#                                  reactable(t_gender, outlined = TRUE)
#                   )
#                   }
#                 })
#   ))


# 
# 
# 
# 
# data_outer <- tab1 %>% filter(Age == "15 years and over") %>% filter(Industry != "Total, all industries") %>% select(-Category)
# data_inner <- tab1 %>% filter(Age != "15 years and over") %>% filter(Industry != "Total, all industries") %>% select(-Category)
# 
# ## wrap reactable table in htmltools::browsable to add "expand all" button
# t_soc <- htmltools::browsable(
#   tagList(
#     tags$button(
#       class = "bcds-react-aria-Button",
#       "Expand/collapse all",
#       onclick = "Reactable.toggleAllRowsExpanded('expansion-table-soc')"
#     ),
#     
#     reactable(data_outer, groupBy = "Industry", elementId = "expansion-table-soc",
#               # add desired functionality
#               compact = TRUE, highlight = TRUE, pagination = FALSE, filterable = TRUE, onClick = "expand", 
#               # Special column formatting
#               columns = list(
#                 # Render grouped cells without the row count
#                 Industry = colDef(grouped = JS("function(cellInfo) { return cellInfo.value }"), minWidth = 250),
#                 Metric = colDef(minWidth = 250),
#                 Value = colDef(minWidth = 50),
#                 Unit = colDef(minWidth = 50),
#                 Year = colDef(minWidth = 50),
#                 Region = colDef(minWidth = 100),
#                 # Hide age column (display in nested table only)
#                 Age = colDef(show = FALSE)),
#               # add nested table for ages
#               details = function(index) {
#                 data_inner <- data_inner %>% 
#                   filter(Metric == data_outer$Metric[index] &
#                            Industry == data_outer$Industry[index]) %>%
#                   select(Age, Value, Unit)
#                 ## show nested table only for employment by Age
#                 if(data_outer$Metric[index] == "Percent of Employment by Age")
#                   ## wrap table in div to add padding
#                   htmltools::div(style = "padding-left: 2rem",
#                                  reactable(data_inner, outlined = TRUE, width = "440px")
#                   )
#               })
#   )
# )
# 
# # htmltools::div(style = "padding: 1rem",
# #                reactable(plant_data, outlined = TRUE)
# # )
# 


