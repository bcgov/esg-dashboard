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
library(tidyverse)
library(janitor)
library(cansim)

# absences <- get_cansim("1410019401")

## 6. Work absences - total days lost per worker per year ----
soc6 <- absences %>%
  filter(REF_DATE >= 2000 & Sex != "Both sexes") %>%
  filter(str_detect(`Presence of children`,"With")) %>%
  filter(`Work absence statistics` == "Total days lost per worker in a year") %>%
  mutate(Gender = ifelse(Sex == "Females", "Women", "Men"),
         Metric = "Work absences - total days lost per worker per year",
         Unit = "Days") %>%
  select(Metric, Value = val_norm, Unit, Year = REF_DATE, Region = GEO, Group1 = Gender, Group2 = `Presence of children`)
