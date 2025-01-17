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
diverted_waste <- get_cansim("3810013801")
waste_disposal <- get_cansim("3810003201")
labour <- get_cansim("1410002301")
board_rep <- get_cansim("3310050101")
disability <- get_cansim("1310075701")
union <- get_cansim("1410006901")
pay <- get_cansim("1410006301")
overtime <- get_cansim("1410007601")
compensation_lvl <- get_cansim("1410011301")
absences <- get_cansim("1410019401")

# Energy use tables ----
## file names for the energy use data downloaded from Natural Resources Canada
ind_energyuse_1 <- "01_data/agg_bct_e_1.csv"
ind_energyuse_2 <- "01_data/agg_bct_e_2.csv"
agr_energyuse_1 <- "01_data/agr_bct_e_1.csv"

# Industry ordering file ----
## table used to provide an order to the industries in the summary tables
industry_order <- read_csv("01_data/industry_order.csv")


# Environmental indicators for summary tables----
## 1. Energy use per employee ----

## industrial sector
env1.1 <- read_csv(ind_energyuse_2, skip = 10, n_max = 13) %>%
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
env1.2 <- read_csv(agr_energyuse_1, skip = 10, n_max = 2) %>%
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
  adorn_totals("row", name = "Total, industrial and agriculture sectors") %>%
  pivot_longer(-Industry, names_pattern = "(Energy|Employees)_(.*)$", names_to = c(".value", "Year")) %>%
  ## calculate energy per employee
  mutate(Value = Energy*1e6/Employees,
         Unit = "GJ",
         Region = "British Columbia",
         Category = "Environmental",
         Metric = "Energy use per employee (gigajoules/employee)",
         Industry = str_to_sentence(Industry))

rm(env1.1, env1.2) ## env1.3 for ghg emissions

## 4. GHG emissions per employee ----

## industrial sector
env4.1 <- read_csv(ind_energyuse_2, skip = 10, n_max = 1, col_names = FALSE) %>%
  bind_rows(
    read_csv(ind_energyuse_2, skip = 39, n_max = 10, col_names = FALSE)
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
env4.2 <- read_csv(agr_energyuse_1, skip = 10, n_max = 1, col_names = FALSE) %>%
  bind_rows(
    read_csv(agr_energyuse_1, skip = 44, n_max = 1, col_names = FALSE)
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
  adorn_totals("row", name = "Total, industrial and agriculture sectors") %>%
  pivot_longer(-Industry, names_pattern = "(Emissions|Employees)_(.*)$", names_to = c(".value", "Year")) %>%
  ## calculate energy per employee
  mutate(Value = Emissions*1e6/Employees,
         Unit = "tCO<sub>2</sub>e",
         Region = "British Columbia",
         Category = "Environmental",
         Metric = "GHG emissions excluding electricity per employee (tCO<sub>2</sub>e/employee)",
         Industry = str_to_sentence(Industry))

# ** Note: Numbers for Forestry and Mining are out because excel spreadsheet is only dividing by Full-time **

rm(env4.1, env4.2, env1.3)

## 7. Diverted waste as a % of total non-hazardous waste ----
env7.1 <- diverted_waste %>%
  filter(GEO == "British Columbia") %>%
  filter(`Type of materials diverted` == "All materials diverted" & 
           `Sources of materials prepared for recycling` == "All sources of diverted materials") %>%
  select(Year = REF_DATE, Region = GEO, Diverted = val_norm)

env7.2 <- waste_disposal %>%
  filter(GEO == "British Columbia") %>%
  filter(`Sources of waste for disposal` == "All sources of waste for disposal") %>%
  select(Year = REF_DATE, Region = GEO, Total = val_norm)

env7 <- env7.1 %>%
  left_join(env7.2, by = c("Year", "Region")) %>%
  mutate(Value = 100*Diverted/Total,
         Unit = "%",
         Industry = "Total, all industries",
         Category = "Environmental",
         Metric = "Diverted waste as a % of total non-hazardous waste")

rm(env7.1, env7.2)

## 8. Non-residential waste as % of total non-hazardous waste ----
env8 <- waste_disposal %>%
  filter(GEO == "British Columbia") %>%
  select(Year = REF_DATE, Region = GEO, Value = val_norm, `Sources of waste for disposal`) %>%
  pivot_wider(names_from = "Sources of waste for disposal", values_from = "Value") %>%
  mutate(Value = 100*`Non-residential sources of waste for disposal`/`All sources of waste for disposal`,
         Unit = "%",
         Industry = "Total, all industries",
         Category = "Environmental",
         Metric = "Non-residential waste as % of total non-hazardous waste")

# Social indicators for summary tables----

labour_NAICS = c("[111-112, 1100, 1151-1152]","[113, 1153]", 
                 "[21, 2100]", "[22]", "[23]",
                 "[31-33]",
                 "[41, 44-45]", "[48-49]", 
                 "[51, 71]", "[52, 53]", "[54]", "[55, 56]", 
                 "[61]", "[62]", 
                 "[72]", "[81]", "[91]")

## 1. Percent of employees working full-time ----
soc1 <- labour %>%
  filter(GEO == "British Columbia") %>%
  filter(REF_DATE >= 2000) %>%
  filter(`Classification Code for North American Industry Classification System (NAICS)` %in% labour_NAICS |
           `North American Industry Classification System (NAICS)` == "Total, all industries") %>%
  #filter(`Hierarchy for North American Industry Classification System (NAICS)` %in% NAICS) %>%
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

## 2. Employment by age group ----
soc2 <- labour %>%
  filter(GEO == "British Columbia") %>%
  filter(REF_DATE >= 2000) %>%
  filter(`Classification Code for North American Industry Classification System (NAICS)` %in% labour_NAICS |
           `North American Industry Classification System (NAICS)` == "Total, all industries") %>%
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
         Metric = "Employment by age group",
         Industry = str_remove_all(Industry, "\\s\\[([:digit:]|-|,|\\s)+\\]"))

## 3. Representation of women on boards ----
## Executive = Directors
## Industries: Energy = 21 (Mining, quarrying, and oil and gas extraction) and 324 (Petroleum and coal product manufacturing)
soc3 <- board_rep %>%
  filter(GEO == "British Columbia" & UOM == "Percent") %>%
  filter(Gender == "Women") %>%
  filter(str_detect(`Type of corporation`, "Total") & str_detect(`Country of control`, "Total") & str_detect(`Size of enterprise`, "Total")) %>%
  filter(Executive == "Directors") %>%
  mutate(Industry = case_when(
    Industry == "Total all industries" ~ "Total, all industries",
    Industry == "Finance" ~ "Finance and insurance",
    Industry == "Distributive trade" ~ "Wholesale and retail trade",
    TRUE ~ Industry),
    Category = "Social",
    Metric = "Representation of women on boards of directors",
    Unit = "%") %>%
  rename(Year = REF_DATE,
         Region = GEO,
         Value = VALUE)

## 4. Percentage of employees with disabilities within workforce   ----
soc4 <- disability %>%
  filter(UOM == "Number") %>%
  filter(Sex == "Total, both sexes") %>%
  mutate(Industry = str_remove_all(`North American Industry Classification System (NAICS - 2012)`, "\\s\\[([:digit:]|-|,|\\s)+\\]") %>%
           str_remove_all(" \\(NAICS-2012\\)")) %>%
  mutate(Industry = case_when(
    Industry %in% c("Wholesale trade", "Retail trade") ~ "Wholesale and retail trade",
    Industry %in% c("Finance and insurance", "Real estate and rental and leasing") ~ "Finance, insurance, real estate, rental and leasing",
    Industry %in% c("Management of companies and enterprises", "Administrative and support, waste management and remediation services") ~ "Business, building and other support services",
    Industry %in% c("Information and cultural industries", "Arts, entertainment and recreation") ~ "Information, culture and recreation",
    TRUE ~ Industry)
  ) %>%
  rename(Year = REF_DATE,
         Region = GEO) %>%
  group_by(Year, Region, Industry, Disability) %>%
  summarize(Value = sum(VALUE), .groups = "drop") %>%
  pivot_wider(names_from = "Disability", values_from = "Value") %>%
  mutate(Value = case_when(is.na(`Persons with disabilities`) ~ 100-100*(`Persons without disabilities`/`Total population, with and without disabilities`),
                           TRUE ~ 100*(`Persons with disabilities`/`Total population, with and without disabilities`)),
         Unit = "%",
         Category = "Social",
         Metric = "Percentage of employees with disabilities within workforce")


## 5. Percentage of employees associated with a labour or trade union ----
union_NAICS <- append(labour_NAICS, c("[21, 113-114, 1153, 2100]", "[52-53]", "[55-56]"))

soc5 <- union %>%
  filter(REF_DATE >= 2000, GEO == "British Columbia") %>%
  filter(`Classification Code for North American Industry Classification System (NAICS)` %in% union_NAICS |
           `North American Industry Classification System (NAICS)` == "Total employees, all industries") %>%
  filter(Sex == "Both sexes" & `Age group` == "15 years and over") %>%
  rename(Region = GEO,
         Industry = `North American Industry Classification System (NAICS)`) %>%
  mutate(Year = str_sub(REF_DATE, end = 4),
         Industry = case_when(Industry == "Total employees, all industries" ~ "Total, all industries",
         TRUE ~ str_remove_all(Industry, "\\s\\[([:digit:]|-|,|\\s)+\\]"))) %>%
  group_by(Year, Region, Industry, `Union coverage`) %>%
  summarize(Value = mean(val_norm), .groups = "drop") %>%
  pivot_wider(names_from = "Union coverage", values_from = "Value") %>%
  mutate(Value = case_when(is.na(`Union coverage`) ~ 100-100*(`No union coverage`/`Total employees, covered and not covered by union`),
                           TRUE ~ 100*(`Union coverage`/`Total employees, covered and not covered by union`)),
         Unit = "%",
         Category = "Social",
         Metric = "Percentage of employees with union coverage")
  
## 7. Mean hourly pay gap (Canada) ----
soc7 <- pay %>%
  filter(REF_DATE >= 2000, GEO == "Canada") %>%
  filter(`North American Industry Classification System (NAICS)` == "Total employees, all industries") %>%
  filter(Wages == "Average hourly wage rate" & `Type of work` == "Both full- and part-time employees") %>%
  filter(Sex != "Both sexes", `Age group` == "15 years and over") %>%
  mutate(Year = str_sub(REF_DATE, end = 4)) %>%
  rename(Region = GEO,
         Industry = `North American Industry Classification System (NAICS)`) %>%
  group_by(Year, Region, Industry, Sex) %>%
  summarize(Value = mean(val_norm), .groups = "drop") %>%
  pivot_wider(names_from = "Sex", values_from = "Value") %>%
  mutate(Value = 100*(Males - Females)/Males,
         Unit = "%",
         Metric = "Mean hourly pay gap, Canada",
         Category = "Social",
         Industry = "Total, all industries")

## 8. Mean hourly pay gap (BC and industries) ----
soc8 <- pay %>%
  filter(REF_DATE >= 2000, GEO == "British Columbia") %>%
  filter(`Classification Code for North American Industry Classification System (NAICS)` %in% union_NAICS |
           `North American Industry Classification System (NAICS)` == "Total employees, all industries") %>%
  filter(Wages == "Average hourly wage rate" & `Type of work` == "Both full- and part-time employees") %>%
  filter(Sex != "Both sexes", `Age group` == "15 years and over") %>%
  mutate(Year = str_sub(REF_DATE, end = 4)) %>%
  rename(Region = GEO,
         Industry = `North American Industry Classification System (NAICS)`) %>%
  group_by(Year, Region, Industry, Sex) %>%
  summarize(Value = mean(val_norm), .groups = "drop") %>%
  pivot_wider(names_from = "Sex", values_from = "Value") %>%
  mutate(Value = 100*(Males - Females)/Males,
         Unit = "%",
         Metric = "Mean hourly pay gap",
         Category = "Social",
         Industry = case_when(Industry == "Total employees, all industries" ~ "Total, all industries",
                              TRUE ~ str_remove_all(Industry, "\\s\\[([:digit:]|-|,|\\s)+\\]")))

## 10. Mean weekly overtime paid hours by gender ----
soc10 <- overtime %>%
  filter(REF_DATE >= 2000, GEO == "British Columbia") %>%
  filter(`Classification Code for North American Industry Classification System (NAICS)` %in% union_NAICS |
           `North American Industry Classification System (NAICS)` == "Total employees at work") %>%
  filter(Overtime == "Average overtime hours of all employees") %>%
  filter(`Age group` == "15 years and over") %>%
  rename(Year = REF_DATE,
         Region = GEO,
         Industry = `North American Industry Classification System (NAICS)`,
         Value = val_norm) %>%
  mutate(Industry = case_when(Industry == "Total employees at work" ~ "Total, all industries",
                              TRUE ~ str_remove_all(Industry, "\\s\\[([:digit:]|-|,|\\s)+\\]")),
         Gender = case_when(Sex == "Males" ~ "Men", Sex == "Females" ~ "Women", TRUE ~ "Both genders"),
         Unit = "Hours",
         Metric = "Mean weekly overtime hours of all employees",
         Category = "Social")

## 11. Gender representation by compensation level ----
soc11 <- compensation_lvl %>%
  filter(REF_DATE >= 2000) %>%
  filter(str_detect(`Type of work`, "Both")) %>%
  filter(`North American Industry Classification System (NAICS)` == "Total employees, all industries") %>%
  rename(Region = GEO) %>%
  mutate(Industry = "Total, all industries",
         Year = str_sub(REF_DATE, end = 4)) %>%
  group_by(Region, Industry, Year, `Hourly wages`, Sex) %>%
  summarize(mean_val = mean(val_norm), .groups = "drop") %>%
  pivot_wider(names_from = "Sex", values_from = "mean_val") %>%
  mutate(Value = 100*Females/(Males + Females),
         Unit = "%",
         Metric = "Representation of women by compensation level",
         Category = "Social")

# Combine data for summary tables ----

format_for_tables <- function(data) {
  
  columns <- c("Category", "Metric", "Industry", "Value", "Unit", "Year", "Region")
  
  if(unique(data$Metric == "Employment by age group"))
    columns <- append(columns, "Age")
  
  if(unique(data$Metric == "Mean weekly overtime hours of all employees"))
    columns <- append(columns, "Gender")
  
  if(unique(data$Metric == "Representation of women by compensation level"))
    columns <- append(columns, "Hourly wages")
  
  data %>%
    filter(Year == max(Year)) %>%
    select(all_of(columns)) %>%
    mutate(Value = round_half_up(Value, digits = 1))
}

table_data <- map_dfr(list(env1, env4, env7, env8, soc1, soc2, soc3, soc4, soc5, soc7, soc8, soc10, soc11), format_for_tables)

## Order industries
table_data <- table_data %>% 
  left_join(industry_order, by = "Industry") %>%
  arrange(Category, Industry_Order) %>%
  mutate(Industry = fct_inorder(Industry))

saveRDS(table_data, "01_data/table_data.rds")

# Environmental indicators for plots ----
## Energy use ----
### Total energy use by industry ----
en_total_ind <- read_csv(ind_energyuse_2, skip = 10, n_max = 13) %>%
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
         Statistic = "Total",
         Metric = "Total energy use by industry", 
         Region = "B.C. and Territories",
         Unit = "Petajoules") %>%
  select(Topic, Statistic, Variable, Metric, Region, Group, Year, Value, Unit)

### Share of energy use by industry ----
en_share_ind <- bind_rows(
  read_csv(ind_energyuse_2, skip = 10, n_max = 1, col_names = FALSE),
  read_csv(ind_energyuse_2, skip = 26, n_max = 10, col_names = FALSE)
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
         Statistic = "Shares",
         Metric = "Share of energy use by industry",
         Region = "B.C. and Territories",
         Unit = "%") %>%
  select(Topic, Statistic, Variable, Metric, Region, Group, Year, Value, Unit)

### Total energy use by energy source ----
en_total_source <- bind_rows(
  read_csv(ind_energyuse_1, skip = 10, n_max = 1, col_names = FALSE) ,
  read_csv(ind_energyuse_1, skip = 14, n_max = 10, col_names = FALSE, na=c("", "X", "NA"))
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
         Statistic = "Total",
         Metric = "Total energy use by energy source",
         Region = "B.C. and Territories",
         Unit = "Petajoules") %>%
  select(Topic, Statistic, Variable, Metric, Region, Group, Year, Value, Unit)

### Share of energy use by energy source ----
en_share_source <- bind_rows(
  read_csv(ind_energyuse_1, skip = 10, n_max = 1, col_names = FALSE) ,
  read_csv(ind_energyuse_1, skip = 26, n_max = 10, col_names = FALSE, na=c("", "X", "NA"))
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
         Statistic = "Shares",
         Metric = "Share of energy use by energy source",
         Region = "B.C. and Territories",
         Unit = "%") %>%
  select(Topic, Statistic, Variable, Metric, Region, Group, Year, Value, Unit)

## GHG emissions ----
### Total GHG emissions by industry ----
ghg_total_ind <- bind_rows(
  read_csv(ind_energyuse_2, skip = 10, n_max = 1, col_names = FALSE),
  read_csv(ind_energyuse_2, skip = 39, n_max = 10, col_names = FALSE)
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
         Statistic = "Total",
         Metric = "Total GHG emissions by industry",
         Region = "B.C. and Territories",
         Unit = "Mt of CO2e") %>%
  select(Topic, Statistic, Variable, Metric, Region, Group, Year, Value, Unit)

### Share of GHG emissions by industry ----
ghg_share_ind <- bind_rows(
  read_csv(ind_energyuse_2, skip = 10, n_max = 1, col_names = FALSE),
  read_csv(ind_energyuse_2, skip = 51, n_max = 10, col_names = FALSE)
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
         Statistic = "Shares",
         Metric = "Share of GHG emissions by industry",
         Region = "B.C. and Territories",
         Unit = "%") %>%
  select(Topic, Statistic, Variable, Metric, Region, Group, Year, Value, Unit)

### Total GHG emissions by energy source ----
ghg_total_source <- bind_rows(
  read_csv(ind_energyuse_1, skip = 10, n_max = 1, col_names = FALSE) ,
  read_csv(ind_energyuse_1, skip = 40, n_max = 9, col_names = FALSE, na=c("", "X", "NA"))
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
         Statistic = "Total",
         Metric = "Total GHG emissions by energy source",
         Region = "B.C. and Territories",
         Unit = "Mt CO2e") %>%
  select(Topic, Statistic, Variable, Metric, Region, Group, Year, Value, Unit)

### Share of GHG emissions by energy source ----
ghg_share_source <- bind_rows(
  read_csv(ind_energyuse_1, skip = 10, n_max = 1, col_names = FALSE) ,
  read_csv(ind_energyuse_1, skip = 52, n_max = 10, col_names = FALSE, na=c("", "X", "NA"))
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
         Statistic = "Shares",
         Metric = "Share of GHG emissions by energy source",
         Region = "B.C. and Territories",
         Unit = "%") %>%
  select(Topic, Statistic, Variable, Metric, Region, Group, Year, Value, Unit)

## combine ----
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

# Social indicators for plots ----

## Employment by age group ----
emp <- soc2 %>%
  select(Metric, Region, Group1 = Industry, Group2 = Age, Year, Value, Unit) %>%
  filter(Group2 != "15 years and over") %>%
  mutate(Unit = "Percentage") 
  

## Mean weekly overtime hours by gender ----
ot <- soc10 %>%
  select(Metric, Region, Group1 = Industry, Group2 = Gender, Year, Value, Unit) %>%
  filter(Group2 != "Both genders") %>%
  mutate(Metric = "Mean weekly overtime hours by gender")

## Representation of women by compensation level ----
complvl <- soc11 %>%
  select(Metric, Region, Group1 = Industry, Group2 = `Hourly wages`, Year, Value, Unit) %>%
  mutate(Unit = "Percentage")

## Work absences by gender and presence of children ----
wkabsence <- absences %>%
    filter(REF_DATE >= 2000 & Sex != "Both sexes") %>%
    filter(str_detect(`Presence of children`,"With")) %>% ## filter for With and Without children only
    filter(`Work absence statistics` == "Total days lost per worker in a year") %>%
    mutate(Gender = ifelse(Sex == "Females", "Women", "Men"),
           Metric = "Work absences by gender and presence of children",
           Unit = "Total Days per Worker") %>%
    select(Metric, Region = GEO, Group1 = Gender, Group2 = `Presence of children`, Value = val_norm, Unit, Year = REF_DATE)

## combine ----
bind_rows(emp, ot, complvl, wkabsence) %>%
  ## Changing this to say public admin instead because 
  ## filtering the table later for "Public administration" picks up both 
  ## Public administration and Other service (except public administration)
  mutate(Group1 = ifelse(Group1 == "Other services (except public administration)", "Other services (except public admin)", Group1),
         Year = as.numeric(Year)) %>%
  saveRDS("01_data/soc_plot_data.rds")
