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
library(janitor)
library(cansim)

# Cansim tables ----
labour <- get_cansim(1410002301)
board_rep <- get_cansim(3310050101)
disability <- get_cansim(1310075701)
union <- get_cansim(1410006901)
pay <- get_cansim(1410006301)
overtime <- get_cansim(1410007601)

# Environmental indicators ----

## Energy use per employee ----

## industry sector
env1.1 <- read_csv("01_data/agg_bct_e_2.csv", skip = 10, n_max = 13) %>%
  remove_empty() %>%
  rename(Industry = 1) %>%
  ## Remove Total and header rows - Total to be recalculated with the addition of Agriculture
  filter(!str_detect(Industry, "PJ")) %>%
  mutate(Industry = case_when(
    str_detect(Industry, "Construction|Mining|Forestry") ~ Industry,
    TRUE ~ "Manufacturing")) %>%
  group_by(Industry) %>%
  summarize_all(sum)

## agriculture sector
env1.2 <- read_csv("01_data/agr_bct_e_1.csv", skip = 10, n_max = 2) %>%
  remove_empty() %>%
  rename(Industry = 1) %>%
  mutate(Industry = "Agriculture")

## labour statistics
env1.3 <- labour %>% 
  filter(VECTOR %in% c("v2368490", "v2368486", "v2368488", "v2368491", "v2368484")) %>%
  select(Year = REF_DATE, VECTOR, Employees = val_norm, NAICS = `North American Industry Classification System (NAICS)`) %>%
  mutate(Industry = case_when(
    VECTOR == "v2368490" ~ "Construction",
    VECTOR == "v2368486" ~ "Forestry",
    VECTOR == "v2368488" ~ "Mining, Quarrying, and Oil and Gas Extraction",
    VECTOR == "v2368491" ~ "Manufacturing",
    VECTOR == "v2368484" ~ "Agriculture"))

env1 <- bind_rows(env1.1, env1.2) %>%
  pivot_longer(-Industry, names_to = "Year", values_to = "Energy") %>%
  left_join(env1.3 %>% select(Industry, Year, Employees), by = c("Industry", "Year")) %>%
  ## add totals
  pivot_wider(names_from = "Year", values_from = c("Energy", "Employees")) %>%
  adorn_totals("row") %>%
  pivot_longer(-Industry, names_pattern = "(Energy|Employees)_(.*)$", names_to = c(".value", "Year")) %>%
  ## calculate energy per employee
  mutate(Value = Energy*1e6/Employees,
         Unit = "gigajoules",
         Region = "British Columbia",
         Category = "Environmental",
         Metric = "Energy Use per Employee")

rm(env1.1, env1.2) ## env1.3 for ghg emissions

## Share of energy use for industry sector ----

## Total GHG emissions ----

## GHG emissions per employee ----

## industry sector
env4.1 <- read_csv("01_data/agg_bct_e_2.csv", skip = 10, n_max = 1, col_names = FALSE) %>%
  bind_rows(
    read_csv("01_data/agg_bct_e_2.csv", skip = 39, n_max = 10, col_names = FALSE)
  ) %>%
  remove_empty() %>%
  row_to_names(1) %>%
  rename(Industry = 1) %>%
  mutate(Industry = case_when(
    str_detect(Industry, "Construction|Mining|Forestry") ~ Industry,
    TRUE ~ "Manufacturing")) %>%
  group_by(Industry) %>%
  summarize_all(sum)

## agriculture sector
env4.2 <- read_csv("01_data/agr_bct_e_1.csv", skip = 10, n_max = 1, col_names = FALSE) %>%
  bind_rows(
    read_csv("01_data/agr_bct_e_1.csv", skip = 44, n_max = 1, col_names = FALSE)
    ) %>%
  remove_empty() %>%
  row_to_names(1) %>%
  rename(Industry = 1) %>%
  mutate(Industry = "Agriculture")


env4 <- bind_rows(env4.1, env4.2) %>%
  pivot_longer(-Industry, names_to = "Year", values_to = "Emissions") %>%
  left_join(env1.3 %>% select(Industry, Year, Employees), by = c("Industry", "Year")) %>%
  ## add totals
  pivot_wider(names_from = "Year", values_from = c("Emissions", "Employees")) %>%
  adorn_totals("row") %>%
  pivot_longer(-Industry, names_pattern = "(Emissions|Employees)_(.*)$", names_to = c(".value", "Year")) %>%
  ## calculate energy per employee
  mutate(Value = Emissions*1e6/Employees,
         Unit = "tCO<sub>2</sub>e",
         Region = "British Columbia",
         Category = "Environmental",
         Metric = "GHG emissions per employee (excluding electricity)")

# ** Note: Numbers for Forestry and Mining are out because excel spreadsheet is only dividing by Full-time **

rm(env4.1, env4.2, env1.3)

## Share of GHG emissions for industry sector ----

# Social indicators ----

NAICS <- c("1", "1.2.3", "1.2.4.5", "1.2.4.7", "1.2.8", "1.2.9", "1.2.10",
           "1.13.14", "1.13.17", "1.13.18", "1.13.21", "1.13.22", "1.13.23",
           "1.13.24", "1.13.25", "1.13.26", "1.13.27", "1.13.28")

## Percent of employees working full-time ----
soc1 <- labour %>%
  filter(GEO == "British Columbia") %>%
  filter(REF_DATE >= 2000) %>%
  filter(`Hierarchy for North American Industry Classification System (NAICS)` %in% NAICS) %>%
  filter(`Labour force characteristics` %in% c("Employment", "Full-time employment")) %>%
  filter(Sex == "Both sexes" & `Age group` == "15 years and over") %>% 
  select(Year = REF_DATE, Region = GEO, Industry = `North American Industry Classification System (NAICS)`,
         `Labour force characteristics`, val_norm) %>%
  pivot_wider(names_from = "Labour force characteristics", values_from = "val_norm") %>%
  mutate(Value = 100*`Full-time employment`/Employment,
         Unit = "%",
         Category = "Social",
         Metric = "Percentage of employees working full-time",
         Industry = str_remove_all(Industry, "\\s\\[([:digit:]|-|,|\\s)+\\]"))

## Employment by age ----
soc2 <- labour %>%
  filter(GEO == "British Columbia") %>%
  filter(REF_DATE >= 2000) %>%
  filter(`Hierarchy for North American Industry Classification System (NAICS)` %in% NAICS) %>%
  filter(`Labour force characteristics` == "Employment" & Sex == "Both sexes") %>%
  select(Year = REF_DATE, Region = GEO, Industry = `North American Industry Classification System (NAICS)`,
         `Age group`, val_norm) %>%
  pivot_wider(names_from = "Age group", values_from = "val_norm") %>%
  mutate(`15 to 24 years` = 100*`15 to 24 years`/`15 years and over`,
         `25 to 54 years` = 100*`25 to 54 years`/`15 years and over`,
         `55 years and over` = 100*`55 years and over`/`15 years and over`,
         `15 years and over` = 100) %>%
  pivot_longer(c(`15 years and over`, `15 to 24 years`, `25 to 54 years`, `55 years and over`),
               names_to = "Age", values_to = "Value") %>%
  mutate(Unit = "%",
         Category = "Social",
         Metric = "Employment by Age",
         Industry = str_remove_all(Industry, "\\s\\[([:digit:]|-|,|\\s)+\\]"))

## Representation of women on boards ----
 

## Percentage of employees with disabilities within workforce   ----
## Percentage of employees associated with a labour or trade union ----
## Mean hourly pay gap (BC and industries) ----
## Mean weekly overtime paid hours by gender ----






