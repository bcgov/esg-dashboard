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

## Summary: Total ----
data_outer <- tab1 %>% filter(Age == "15 years and over") %>% filter(Industry == "Total, all industries")
data_inner <- tab1 %>% filter(Age != "15 years and over") %>% filter(Industry == "Total, all industries")

t_total <- reactable(data_outer %>% select(Metric, everything()),
                     # add desired functionality
                     compact = TRUE, highlight = TRUE, pagination = FALSE, onClick = "expand", 
                     # Special column formatting
                     columns = list(
                       # Render grouped cells without the row count
                       Metric = colDef(grouped = JS("function(cellInfo) { return cellInfo.value }"), minWidth = 250),
                       Category = colDef(minWidth = 75),
                       Industry = colDef(minWidth = 125),
                       Value = colDef(minWidth = 75),
                       Unit = colDef(minWidth = 75),
                       Year = colDef(minWidth = 50),
                       Region = colDef(minWidth = 100),
                       # Hide age colum (display in nested table only)
                       Age = colDef(show = FALSE)),
                     ## add nested table for ages
                     details = function(index) {
                       data_inner <- data_inner %>% 
                         filter(Metric == data_outer$Metric[index]) %>%
                         select(Age, Value, Unit)
                       ## show nested table only for employment by Age
                       if(data_outer$Metric[index] == "Percent of Employment by Age")
                         ## wrap table in div to add padding
                         htmltools::div(style = "padding-left: 2rem",
                                        reactable(data_inner, outlined = TRUE, width = "440px")
                         )
                     })

## Summary: Environmental ----
## Summary: Social ----
data_outer <- tab1 %>% filter(Age == "15 years and over") %>% filter(Industry != "Total, all industries") %>% select(-Category)
data_inner <- tab1 %>% filter(Age != "15 years and over") %>% filter(Industry != "Total, all industries") %>% select(-Category)

## wrap reactable table in htmltools::browsable to add "expand all" button
t_soc <- htmltools::browsable(
  tagList(
    tags$button(
      class = "bcds-react-aria-Button",
      "Expand/collapse all",
      onclick = "Reactable.toggleAllRowsExpanded('expansion-table')"
    ),
    
    reactable(data_outer, groupBy = "Industry", elementId = "expansion-table",
              # add desired functionality
              compact = TRUE, highlight = TRUE, pagination = FALSE, filterable = TRUE, onClick = "expand", 
              # Special column formatting
              columns = list(
                # Render grouped cells without the row count
                Industry = colDef(grouped = JS("function(cellInfo) { return cellInfo.value }"), minWidth = 250),
                Metric = colDef(minWidth = 250),
                Value = colDef(minWidth = 50),
                Unit = colDef(minWidth = 50),
                Year = colDef(minWidth = 50),
                Region = colDef(minWidth = 100),
                # Hide age colum (display in nested table only)
                Age = colDef(show = FALSE)),
              # add nested table for ages
              details = function(index) {
                data_inner <- data_inner %>% 
                  filter(Metric == data_outer$Metric[index] &
                           Industry == data_outer$Industry[index]) %>%
                  select(Age, Value, Unit)
                ## show nested table only for employment by Age
                if(data_outer$Metric[index] == "Percent of Employment by Age")
                  ## wrap table in div to add padding
                  htmltools::div(style = "padding-left: 2rem",
                                 reactable(data_inner, outlined = TRUE, width = "440px")
                  )
              })
  )
)

# htmltools::div(style = "padding: 1rem",
#                reactable(plant_data, outlined = TRUE)
# )



