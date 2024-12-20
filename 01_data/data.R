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
# 
# library(tidyverse)
# library(janitor)
# library(cansim)
# 
# # Cansim tables ----
# diverted_waste <- get_cansim(3810013801)
# waste_disposal <- get_cansim(3810003201)
# labour <- get_cansim(1410002301)
# board_rep <- get_cansim(3310050101)
# disability <- get_cansim(1310075701)
# union <- get_cansim(1410006901)
# pay <- get_cansim(1410006301)
# overtime <- get_cansim(1410007601)

# Environmental indicators ----

## 1. Energy use per employee ----

## industrial sector
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

## 2. Share of energy use for industry sector ----

## 3. Total GHG emissions ----

## 4. GHG emissions per employee ----

## industrial sector
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

## 5. Share of GHG emissions for industry sector ----

## 6. Percentage of GHG emissions by fuels source ----

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

## 9. Water consumption in the manufacturing sector (cubic liters per employee) ----

# Social indicators ----

labour_NAICS = c("[111-112, 1100, 1151-1152]","[113, 1153]", 
                 "[21, 2100]", "[22]", "[23]",
                 "[31-33]",
                 "[41, 44-45]", "[48-49]", 
                 "[51, 71]", "[52, 53]", "[54]", "[55, 56]", 
                 "[61]", "[62]", 
                 "[72]", "[81]", "[91]")

# labour_NAICS_hierarchy <- c("1", "1.2.3", "1.2.4.5", "1.2.4.7", "1.2.8", "1.2.9", "1.2.10",
#            "1.13.14", "1.13.17", "1.13.18", "1.13.21", "1.13.22", "1.13.23",
#            "1.13.24", "1.13.25", "1.13.26", "1.13.27", "1.13.28")

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

## Combine data for summary tables ----

format_for_tables <- function(data) {
  
  columns <- c("Category", "Metric", "Industry", "Value", "Unit", "Year", "Region")
  
  if(unique(data$Metric == "Employment by age group"))
    columns <- append(columns, "Age")
  
  if(unique(data$Metric == "Mean weekly overtime hours of all employees"))
    columns <- append(columns, "Gender")
  
  data %>%
    filter(Year == max(Year)) %>%
    select(all_of(columns)) %>%
    mutate(Value = round_half_up(Value, digits = 1))
}

table_data <- map_dfr(list(env1, env4, env7, env8, soc1, soc2, soc3, soc4, soc5, soc7, soc8, soc10), format_for_tables)

## Order industries

industry_order <-  tibble::tribble(
            ~Industry_Order,                                                  ~Industry,
                         1L,                "Total, industrial and agriculture sectors",
                         2L,                                    "Total, all industries",
                         3L,               "Agriculture, forestry, fishing and hunting",
                         4L,                                              "Agriculture",
                         5L,                                                 "Forestry",
                         6L, "Forestry and logging and support activities for forestry",
                         7L,        "Forestry, fishing, mining, quarrying, oil and gas",
                         8L,            "Mining, quarrying, and oil and gas extraction",
                         9L,                                                   "Energy",
                        10L,                                                "Utilities",
                        11L,                                             "Construction",
                        12L,                                            "Manufacturing",
                        13L,                               "Wholesale and retail trade",
                        14L,                           "Transportation and warehousing",
                        15L,      "Finance, insurance, real estate, rental and leasing",
                        16L,                                    "Finance and insurance",
                        17L,          "Professional, scientific and technical services",
                        18L,            "Business, building and other support services",
                        19L,                  "Management of companies and enterprises",
                        20L,                                     "Educational services",
                        21L,                        "Health care and social assistance",
                        22L,                      "Information, culture and recreation",
                        23L,                          "Accommodation and food services",
                        24L,            "Other services (except public administration)",
                        25L,                                    "Public administration",
                        26L,                                           "Other industry",
                        27L,                                    "Unclassified industry"
                     )

table_data <- table_data %>% 
  left_join(industry_order, by = "Industry") %>%
  arrange(Category, Industry_Order) %>%
  mutate(Industry = fct_inorder(Industry)) %>%
  select(-Industry_Order)

saveRDS(table_data, "01_data/table_data.rds")


