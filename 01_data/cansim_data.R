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
library(cansim)
library(janitor)

data <- cansim::get_cansim(1410002301)

data <- data %>% 
  filter(GEO == "British Columbia") %>%
  filter(REF_DATE >= 2000) %>%
  select(REF_DATE, GEO, UOM, SCALAR_FACTOR, VALUE, 
         Characteristic = `Labour force characteristics`,
         NAICS_CODE = `Hierarchy for North American Industry Classification System (NAICS)`,
         Industry = `North American Industry Classification System (NAICS)`,
         Gender, Age = `Age group`)

ind_data <- data %>%
  filter(NAICS_CODE %in% c("1", "1.2.3", "1.2.4.5", "1.2.4.7", "1.2.8", "1.2.9", "1.2.10",
                           "1.13.14", "1.13.17", "1.13.18", "1.13.21", "1.13.22", "1.13.23",
                           "1.13.24", "1.13.25", "1.13.26", "1.13.27", "1.13.28")) %>%
  mutate(NAICS_CODE = factor(NAICS_CODE, levels = c("1", "1.2.3", "1.2.4.5", "1.2.4.7", "1.2.8", "1.2.9", "1.2.10",
                                                    "1.13.14", "1.13.17", "1.13.18", "1.13.21", "1.13.22", "1.13.23",
                                                    "1.13.24", "1.13.25", "1.13.26", "1.13.27", "1.13.28")),
         Industry = str_remove_all(Industry, "\\s\\[([:digit:]|-|,|\\s)+\\]")) %>%
  arrange(NAICS_CODE) %>%
  mutate(Industry = fct_inorder(Industry))

## table data
tab1 <- ind_data %>%
  filter(Gender == "Total - Gender") %>%
  filter(Characteristic == "Employment" | (Characteristic == "Full-time employment" & Age == "15 years and over")) %>%
  group_by(Characteristic) %>%
  filter(REF_DATE == max(REF_DATE)) %>%
  ungroup() %>%
  mutate(Metric = case_when(
    Age != "15 years and over" ~ "Percent of Employment by Age",
    Characteristic != "Employment" ~ "Percent Full-Time",
    TRUE ~ "Employment"),
    Category = "Social")  %>% 
  select(-Characteristic) %>%
  pivot_wider(names_from = "Metric", values_from = "VALUE") %>%
  fill(Employment) %>%
  mutate(`Percent of Employment by Age` = round_half_up(100*`Percent of Employment by Age`/Employment),
         `Percent Full-Time` = round_half_up(100*`Percent Full-Time`/Employment)) %>%
  select(-Employment) %>%
  pivot_longer(c(`Percent of Employment by Age`,`Percent Full-Time`),
               names_to = "Metric", values_to = "Value") %>%
  mutate(Unit = "%",
         Value = ifelse(is.na(Value) & Metric == "Percent of Employment by Age", 100, Value)) %>%
  filter(!is.na(Value)) %>%
  select(Category, Metric, Industry, Value, Unit, Year = REF_DATE, Region = GEO, Age)

## chart data
full_time <- ind_data %>%
  filter(Characteristic %in% c("Employment","Full-time employment") & Gender == "Total - Gender" & Age == "15 years and over") %>%
  select(REF_DATE, NAICS_CODE, Industry, Characteristic, VALUE) %>%
  pivot_wider(names_from = "Characteristic", values_from = "VALUE") %>%
  mutate(perc_ft = `Full-time employment`/Employment)

age <- ind_data %>%
  filter(Characteristic == "Employment" & Gender == "Total - Gender") %>%
  select(REF_DATE, NAICS_CODE, Industry, Age, VALUE) %>%
  pivot_wider(names_from = "Age", values_from = "VALUE") %>%
  mutate(perc_15_24 = `15 to 24 years`/`15 years and over`,
         perc_25_54 = `25 to 54 years`/`15 years and over`,
         perc_55 = `55 years and over`/`15 years and over`)







