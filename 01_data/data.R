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

bar_data <- tibble::tribble(
                       ~Topic, ~Type,                                                    ~Indicator,                                       ~Variable,     ~`2019`,     ~`2020`,     ~`2021`,
                 "Energy Use", "bar",    "Energy Use per Employee by Industry in Gigajoules (B.C.)",                                  "Construction", 79.31453018, 66.30462238, 67.58278892,
                 "Energy Use", "bar",    "Energy Use per Employee by Industry in Gigajoules (B.C.)",                                      "Forestry", 468.3840749, 415.7463947, 399.7914132,
                 "Energy Use", "bar",    "Energy Use per Employee by Industry in Gigajoules (B.C.)", "Mining, Quarrying, and\nOil and Gas Extraction", 3939.408843, 4201.455791, 3465.114095,
              "GHG Emissions", "bar", "GHG Emissions per Employee by Industry in Mt of CO2e (B.C.)",                                  "Construction", 5.407808876, 4.420308159, 4.621045396,
              "GHG Emissions", "bar", "GHG Emissions per Employee by Industry in Mt of CO2e (B.C.)",                                      "Forestry", 30.02462019, 25.98414967, 28.97039226,
              "GHG Emissions", "bar", "GHG Emissions per Employee by Industry in Mt of CO2e (B.C.)", "Mining, Quarrying, and\nOil and Gas Extraction", 231.1513303, 246.1999572, 201.8968917,
                    NA, "bar",                    "% of Total Energy Use by Industry (B.C.)",                                         "Construction",       0.032,       0.029,       0.032,
                    NA, "bar",                    "% of Total Energy Use by Industry (B.C.)",                                             "Forestry",       0.019,       0.018,       0.019,
                    NA, "bar",                    "% of Total Energy Use by Industry (B.C.)",        "Mining, Quarrying, and\nOil and Gas Extraction",       0.197,       0.217,         0.2
              )
  
line_data <- tibble::tribble(
           ~Topic,  ~Type,                                            ~Indicator,                                      ~Variable, ~`2011`, ~`2012`, ~`2013`, ~`2014`, ~`2015`, ~`2016`, ~`2017`, ~`2018`, ~`2019`, ~`2020`, ~`2021`,
     "Energy Use", "Line", "Percentage of Energy Consumed by Fuel Source (B.C.)",                                  "Electricity",   0.217,   0.229,   0.236,   0.212,   0.193,   0.227,   0.233,   0.224,   0.232,   0.223,   0.211,
     "Energy Use", "Line", "Percentage of Energy Consumed by Fuel Source (B.C.)",                                  "Natural Gas",   0.206,   0.228,   0.222,   0.205,   0.213,   0.239,   0.233,    0.25,   0.247,   0.276,   0.259,
     "Energy Use", "Line", "Percentage of Energy Consumed by Fuel Source (B.C.)", "Diesel Fuel Oil, Light Fuel Oil and Kerosene",   0.096,   0.101,   0.115,   0.097,   0.109,   0.104,      NA,   0.125,   0.123,   0.124,   0.125,
     "Energy Use", "Line", "Percentage of Energy Consumed by Fuel Source (B.C.)",                               "Heavy Fuel Oil",   0.011,   0.008,   0.006,   0.004,   0.002,   0.002,      NA,   0.001,   0.001,   0.001,   0.001,
     "Energy Use", "Line", "Percentage of Energy Consumed by Fuel Source (B.C.)",                 "Still Gas and Petroleum Coke",      NA,      NA,      NA,      NA,      NA,      NA,      NA,   0.031,   0.021,   0.016,   0.018,
     "Energy Use", "Line", "Percentage of Energy Consumed by Fuel Source (B.C.)",                        "LPG and Gas Plant NGL",   0.007,   0.007,   0.006,   0.005,   0.005,   0.009,   0.006,   0.006,   0.006,   0.006,   0.006,
     "Energy Use", "Line", "Percentage of Energy Consumed by Fuel Source (B.C.)",                                         "Coal",      NA,      NA,      NA,   0.016,   0.015,      NA,      NA,   0.013,   0.015,   0.012,   0.009,
     "Energy Use", "Line", "Percentage of Energy Consumed by Fuel Source (B.C.)",                       "Coke and Coke Oven Gas",       0,       0,       0,   0.001,      NA,      NA,      NA,   0.001,   0.001,   0.001,   0.001,
     "Energy Use", "Line", "Percentage of Energy Consumed by Fuel Source (B.C.)",                "Wood Waste and Pulping Liquor",   0.398,   0.377,   0.374,   0.428,   0.429,   0.364,   0.366,   0.349,   0.355,   0.342,    0.37,
  "GHG Emissions", "Line",  "Percentage of  GHG Emissions by Fuel Source (B.C.)",                                  "Natural Gas",   0.459,   0.506,   0.498,   0.494,   0.489,   0.513,   0.511,   0.514,   0.528,   0.573,   0.556,
  "GHG Emissions", "Line",  "Percentage of  GHG Emissions by Fuel Source (B.C.)", "Diesel Fuel Oil, Light Fuel Oil and Kerosene",    0.28,   0.296,    0.34,    0.31,   0.331,    0.29,      NA,   0.331,    0.34,   0.333,   0.348,
  "GHG Emissions", "Line",  "Percentage of  GHG Emissions by Fuel Source (B.C.)",                               "Heavy Fuel Oil",   0.033,   0.026,   0.019,   0.014,   0.007,   0.006,      NA,   0.003,   0.003,   0.001,   0.002,
  "GHG Emissions", "Line",  "Percentage of  GHG Emissions by Fuel Source (B.C.)",                 "Still Gas and Petroleum Coke",      NA,      NA,      NA,      NA,      NA,      NA,      NA,   0.086,   0.055,   0.034,   0.041,
  "GHG Emissions", "Line",  "Percentage of  GHG Emissions by Fuel Source (B.C.)",                        "LPG and Gas Plant NGL",   0.019,   0.017,   0.016,   0.014,   0.013,   0.023,   0.016,   0.015,   0.015,   0.014,   0.015,
  "GHG Emissions", "Line",  "Percentage of  GHG Emissions by Fuel Source (B.C.)",                                         "Coal",      NA,      NA,      NA,   0.064,   0.053,      NA,      NA,   0.043,   0.049,   0.034,   0.028,
  "GHG Emissions", "Line",  "Percentage of  GHG Emissions by Fuel Source (B.C.)",                       "Coke and Coke Oven Gas",      NA,      NA,      NA,   0.005,      NA,      NA,      NA,   0.004,   0.004,   0.005,   0.005,
  "GHG Emissions", "Line",  "Percentage of  GHG Emissions by Fuel Source (B.C.)",                "Wood Waste and Pulping Liquor",   0.007,   0.005,   0.006,    0.01,    0.01,   0.006,   0.006,   0.006,   0.005,   0.005,   0.005
  )


## pivot data
bar_data <- bar_data %>%
  pivot_longer(-c(Topic, Type, Indicator, Variable), names_to = "Year", values_to = "Value")

line_data <- line_data %>%
  pivot_longer(-c(Topic, Type, Indicator, Variable), names_to = "Year", values_to = "Value")

## combine data
data <- bind_rows(
  bar_data,
  line_data
)

## transform Year
data <- data %>%
  mutate(Year = as.numeric(Year))

## waste data
diverted_perc <- tibble::tribble(
                   ~Year,      ~Value,
                   2018L,  0.64073118,
                   2020L, 0.658297993,
                   2022L, 0.622366488
                   )

nonres_perc <- tibble::tribble(
                 ~Year,      ~Value,
                 2002L, 0.654337132,
                 2004L, 0.667833839,
                 2006L, 0.671943519,
                 2008L, 0.658385997,
                 2010L,  0.64121002,
                 2012L, 0.636141124,
                 2014L, 0.654083384,
                 2016L, 0.644435705,
                 2018L, 0.634773558,
                 2020L, 0.618951207,
                 2022L, 0.626289435
                 )





