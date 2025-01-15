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

# Energy use ----
## Total energy use by industry ----
en_total_ind <- read_csv("01_data/agg_bct_e_2.csv", skip = 10, n_max = 13) %>%
  remove_empty(which = c("rows", "cols")) %>%
  rename(Group = 1) %>%
  ## Remove Total and header rows - Total to be recalculated with the addition of Agriculture
  filter(!str_detect(Group, "PJ")) %>%
  ## Combine all manufacturing industries
  mutate(
    Group = case_when(
      str_detect(Group, "Construction|Mining|Forestry") ~ Group,
      TRUE ~ "Manufacturing")) %>%
  group_by(Group) %>%
  summarize_all(sum) %>%
  pivot_longer(-Group, names_to = "Year", values_to = "Value", names_transform = as.numeric) %>%
  mutate(Topic = "Energy use",
         Variable = "Industry",
         Metric = "Total",
         Title = "Total energy use by industry",
         Unit = "Petajoules") %>%
  select(Topic, Metric, Variable, Title, Group, Year, Value, Unit)

## Share of energy use by industry ----
en_share_ind <- bind_rows(
  read_csv("01_data/agg_bct_e_2.csv", skip = 10, n_max = 1, col_names = FALSE),
  read_csv("01_data/agg_bct_e_2.csv", skip = 26, n_max = 10, col_names = FALSE)
  ) %>%
  remove_empty(which = c("rows", "cols")) %>%
  row_to_names(1) %>%
  rename(Group = 1) %>%
  ## Combine all manufacturing industries
  mutate(
    Group = case_when(
      str_detect(Group, "Construction|Mining|Forestry") ~ Group,
      TRUE ~ "Manufacturing")) %>%
  group_by(Group) %>%
  summarize_all(sum) %>%
  pivot_longer(-Group, names_to = "Year", values_to = "Value", names_transform = as.numeric) %>%
  mutate(Topic = "Energy use",
         Variable = "Industry",
         Metric = "Shares",
         Title = "Share of energy use by industry",
         Unit = "%") %>%
  select(Topic, Metric, Variable, Title, Group, Year, Value, Unit)

## Total energy use by energy source ----
en_total_source <- bind_rows(
  read_csv("01_data/agg_bct_e_1.csv", skip = 10, n_max = 1, col_names = FALSE) ,
  read_csv("01_data/agg_bct_e_1.csv", skip = 14, n_max = 10, col_names = FALSE, na=c("", "X", "NA"))
  ) %>%
  remove_empty(which = c("rows", "cols")) %>%
  row_to_names(1) %>%
  rename(Group = 1) %>%
  pivot_longer(-Group, names_to = "Year", values_to = "Value", names_transform = as.numeric) %>%
  ## remove na values so they are not plotted as zero
  filter(!is.na(Value)) %>%
  ## collapse energy sources
  mutate(Group = case_when(
    Group %in% c("Heavy Fuel Oil",
                 "Coke and Coke Oven Gas",
                 "Other2") ~ "Other",
    TRUE ~ Group)) %>%
  group_by(Group, Year) %>%
  summarize(Value = sum(Value, na.rm = TRUE), .groups = "drop") %>%
  mutate(Topic = "Energy use",
         Variable = "Energy source",
         Metric = "Total",
         Title = "Total energy use by energy source",
         Unit = "Petajoules") %>%
  select(Topic, Metric, Variable, Title, Group, Year, Value, Unit)

## Share of energy use by energy source ----
en_share_source <- bind_rows(
  read_csv("01_data/agg_bct_e_1.csv", skip = 10, n_max = 1, col_names = FALSE) ,
  read_csv("01_data/agg_bct_e_1.csv", skip = 26, n_max = 10, col_names = FALSE, na=c("", "X", "NA"))
) %>%
  remove_empty(which = c("rows", "cols")) %>%
  row_to_names(1) %>%
  rename(Group = 1) %>%
  pivot_longer(-Group, names_to = "Year", values_to = "Value", names_transform = as.numeric) %>%
  ## remove na values so they are not plotted as zero
  filter(!is.na(Value)) %>%
  ## collapse energy sources
  mutate(Group = case_when(
    Group %in% c("Heavy Fuel Oil",
                 "Coke and Coke Oven Gas",
                 "Other2") ~ "Other",
    TRUE ~ Group)) %>%
  group_by(Group, Year) %>%
  summarize(Value = sum(Value, na.rm = TRUE), .groups = "drop") %>%
  ## calculate the % suppressed
  group_by(Year) %>%
  ## add a row for each year to represent the % suppressed (100-sum(unsuppressed), with minimum of 0)
  bind_rows(summarise(., 
                      across(Group, ~"Suppressed"),
                      across(Value, ~max(0, 100-sum(.x))))) %>%
  ungroup() %>%
  mutate(Topic = "Energy use",
         Variable = "Energy source",
         Metric = "Shares",
         Title = "Share of energy use by energy source",
         Unit = "%") %>%
  select(Topic, Metric, Variable, Title, Group, Year, Value, Unit)


# GHG emissions ----
## Total GHG emissions by industry ----
ghg_total_ind <- bind_rows(
  read_csv("01_data/agg_bct_e_2.csv", skip = 10, n_max = 1, col_names = FALSE),
  read_csv("01_data/agg_bct_e_2.csv", skip = 39, n_max = 10, col_names = FALSE)
  ) %>%
  remove_empty(which = c("rows", "cols")) %>%
  row_to_names(1) %>%
  rename(Group = 1) %>%
  ## Combine all manufacturing industries
  mutate(
    Group = case_when(
      str_detect(Group, "Construction|Mining|Forestry") ~ Group,
      TRUE ~ "Manufacturing")) %>%
  group_by(Group) %>%
  summarize_all(sum) %>%
  pivot_longer(-Group, names_to = "Year", values_to = "Value", names_transform = as.numeric) %>%
  mutate(Topic = "GHG emissions",
         Variable = "Industry",
         Metric = "Total",
         Title = "Total GHG emissions by industry",
         Unit = "Mt of CO2e") %>%
  select(Topic, Metric, Variable, Title, Group, Year, Value, Unit)

## Share of GHG emissions by industry ----
ghg_share_ind <- bind_rows(
  read_csv("01_data/agg_bct_e_2.csv", skip = 10, n_max = 1, col_names = FALSE),
  read_csv("01_data/agg_bct_e_2.csv", skip = 51, n_max = 10, col_names = FALSE)
  ) %>%
  remove_empty(which = c("rows", "cols")) %>%
  row_to_names(1) %>%
  rename(Group = 1) %>%
  ## Combine all manufacturing industries
  mutate(
    Group = case_when(
      str_detect(Group, "Construction|Mining|Forestry") ~ Group,
      TRUE ~ "Manufacturing")) %>%
  group_by(Group) %>%
  summarize_all(sum) %>%
  pivot_longer(-Group, names_to = "Year", values_to = "Value", names_transform = as.numeric) %>%
  mutate(Topic = "GHG emissions",
         Variable = "Industry",
         Metric = "Shares",
         Title = "Share of GHG emissions by industry",
         Unit = "%") %>%
  select(Topic, Metric, Variable, Title, Group, Year, Value, Unit)
 
## Total GHG emissions by energy source ----
ghg_total_source <- bind_rows(
  read_csv("01_data/agg_bct_e_1.csv", skip = 10, n_max = 1, col_names = FALSE) ,
  read_csv("01_data/agg_bct_e_1.csv", skip = 40, n_max = 9, col_names = FALSE, na=c("", "X", "NA"))
  ) %>%
  remove_empty(which = c("rows", "cols")) %>%
  row_to_names(1) %>%
  rename(Group = 1)  %>%
  pivot_longer(-Group, names_to = "Year", values_to = "Value", names_transform = as.numeric) %>%
  ## remove na values so they are not plotted as zero
  filter(!is.na(Value)) %>%
  ## collapse energy sources
  mutate(Group = case_when(
    Group %in% c("Coke and Coke Oven Gas",
                 "Other2") ~ "Other",
    TRUE ~ Group)) %>%
  group_by(Group, Year) %>%
  summarize(Value = sum(Value, na.rm = TRUE), .groups = "drop") %>%
  mutate(Topic = "GHG emissions",
         Variable = "Energy source",
         Metric = "Total",
         Title = "Total GHG emissions by energy source",
         Unit = "Mt CO2e") %>%
  select(Topic, Metric, Variable, Title, Group, Year, Value, Unit)

## Share of GHG emissions by energy source ----
ghg_share_source <- bind_rows(
  read_csv("01_data/agg_bct_e_1.csv", skip = 10, n_max = 1, col_names = FALSE) ,
  read_csv("01_data/agg_bct_e_1.csv", skip = 52, n_max = 10, col_names = FALSE, na=c("", "X", "NA"))
) %>%
  remove_empty(which = c("rows", "cols")) %>%
  row_to_names(1) %>%
  rename(Group = 1) %>%
  pivot_longer(-Group, names_to = "Year", values_to = "Value", names_transform = as.numeric) %>%
  ## remove na values so they are not plotted as zero
  filter(!is.na(Value)) %>%
  ## collapse energy sources
  mutate(Group = case_when(
    Group %in% c("Coke and Coke Oven Gas",
                 "Other2") ~ "Other",
    TRUE ~ Group)) %>%
  group_by(Group, Year) %>%
  summarize(Value = sum(Value, na.rm = TRUE), .groups = "drop") %>%
  ## calculate the % suppressed
  group_by(Year) %>%
  ## add a row for each year to represent the % suppressed (100-sum(unsuppressed), with minimum of 0)
  bind_rows(summarise(., 
                      across(Group, ~"Suppressed"),
                      across(Value, ~max(0, 100-sum(.x))))) %>%
  ungroup() %>%
  mutate(Topic = "GHG emissions",
         Variable = "Energy source",
         Metric = "Shares",
         Title = "Share of GHG emissions by energy source",
         Unit = "%") %>%
  select(Topic, Metric, Variable, Title, Group, Year, Value, Unit)

# combine ----
bind_rows(
  en_total_ind,
  en_share_ind,
  en_total_source,
  en_share_source,
  ghg_total_ind,
  ghg_share_ind,
  ghg_total_source,
  ghg_share_source
) %>% 
  saveRDS("01_data/env_plot_data.rds")




