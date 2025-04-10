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


summary_data <- tibble::tribble(
  ~Category,                                       ~Industry,                      ~`Key Metric`, ~Year,  ~Region, ~Value,                           ~Unit,
  "Environmental",                                   "Agriculture",                       "Energy Use", 2020L,   "B.C.",   1143,       "gigajoules per employee",
  "Environmental",                                   "Agriculture",                       "Energy Use", 2019L,   "B.C.",   1293,       "gigajoules per employee",
  "Environmental",                                   "Agriculture",                       "Energy Use", 2018L,   "B.C.",   1379,       "gigajoules per employee",
  "Environmental",                                   "Agriculture",                       "Energy Use", 2017L,   "B.C.",   1266,       "gigajoules per employee",
  "Environmental",                                  "Construction",                       "Energy Use", 2021L,   "B.C.",     52,       "gigajoules per employee",
  "Environmental",                                  "Construction",                       "Energy Use", 2020L,   "B.C.",     46,       "gigajoules per employee",
  "Environmental",                                  "Construction",                       "Energy Use", 2019L,   "B.C.",     53,       "gigajoules per employee",
  "Environmental",                                  "Construction",                       "Energy Use", 2018L,   "B.C.",     54,       "gigajoules per employee",
  "Environmental",                                  "Construction",                       "Energy Use", 2017L,   "B.C.",     50,       "gigajoules per employee",
  "Environmental",                                      "Forestry",                       "Energy Use", 2021L,   "B.C.",    418,       "gigajoules per employee",
  "Environmental",                                      "Forestry",                       "Energy Use", 2020L,   "B.C.",    464,       "gigajoules per employee",
  "Environmental",                                      "Forestry",                       "Energy Use", 2019L,   "B.C.",    531,       "gigajoules per employee",
  "Environmental",                                      "Forestry",                       "Energy Use", 2018L,   "B.C.",    640,       "gigajoules per employee",
  "Environmental",                                      "Forestry",                       "Energy Use", 2017L,   "B.C.",    514,       "gigajoules per employee",
  "Environmental",                                 "Manufacturing",                       "Energy Use", 2021L, "Canada",   1210,       "gigajoules per employee",
  "Environmental",                                 "Manufacturing",                       "Energy Use", 2020L, "Canada",   1205,       "gigajoules per employee",
  "Environmental",                                 "Manufacturing",                       "Energy Use", 2019L, "Canada",   1243,       "gigajoules per employee",
  "Environmental",                                 "Manufacturing",                       "Energy Use", 2018L, "Canada",   1222,       "gigajoules per employee",
  "Environmental",                                 "Manufacturing",                       "Energy Use", 2017L, "Canada",   1212,       "gigajoules per employee",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                       "Energy Use", 2021L,   "B.C.",   2674,       "gigajoules per employee",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                       "Energy Use", 2020L,   "B.C.",   3443,       "gigajoules per employee",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                       "Energy Use", 2019L,   "B.C.",   2978,       "gigajoules per employee",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                       "Energy Use", 2018L,   "B.C.",   2910,       "gigajoules per employee",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                       "Energy Use", 2017L,   "B.C.",   2403,       "gigajoules per employee",
  "Environmental",                                   "Agriculture",                    "GHG Emissions", 2020L,   "B.C.",   1.81,             "mtCO<sub>2</sub>e",
  "Environmental",                                   "Agriculture",                    "GHG Emissions", 2019L,   "B.C.",   1.77,             "mtCO<sub>2</sub>e",
  "Environmental",                                   "Agriculture",                    "GHG Emissions", 2018L,   "B.C.",   1.86,             "mtCO<sub>2</sub>e",
  "Environmental",                                   "Agriculture",                    "GHG Emissions", 2017L,   "B.C.",   1.68,             "mtCO<sub>2</sub>e",
  "Environmental",                                  "Construction",                    "GHG Emissions", 2021L,   "B.C.",    0.8,             "mtCO<sub>2</sub>e",
  "Environmental",                                  "Construction",                    "GHG Emissions", 2020L,   "B.C.",    0.7,             "mtCO<sub>2</sub>e",
  "Environmental",                                  "Construction",                    "GHG Emissions", 2019L,   "B.C.",    0.9,             "mtCO<sub>2</sub>e",
  "Environmental",                                  "Construction",                    "GHG Emissions", 2018L,   "B.C.",    0.9,             "mtCO<sub>2</sub>e",
  "Environmental",                                  "Construction",                    "GHG Emissions", 2017L,   "B.C.",    0.8,             "mtCO<sub>2</sub>e",
  "Environmental",                                      "Forestry",                    "GHG Emissions", 2021L,   "B.C.",    0.5,             "mtCO<sub>2</sub>e",
  "Environmental",                                      "Forestry",                    "GHG Emissions", 2020L,   "B.C.",    0.4,             "mtCO<sub>2</sub>e",
  "Environmental",                                      "Forestry",                    "GHG Emissions", 2019L,   "B.C.",    0.5,             "mtCO<sub>2</sub>e",
  "Environmental",                                      "Forestry",                    "GHG Emissions", 2018L,   "B.C.",    0.7,             "mtCO<sub>2</sub>e",
  "Environmental",                                      "Forestry",                    "GHG Emissions", 2017L,   "B.C.",    0.6,             "mtCO<sub>2</sub>e",
  "Environmental",                                 "Manufacturing",                    "GHG Emissions", 2022L,   "B.C.",   16.3,             "mtCO<sub>2</sub>e",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                    "GHG Emissions", 2021L,   "B.C.",    4.3,             "mtCO<sub>2</sub>e",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                    "GHG Emissions", 2020L,   "B.C.",    4.6,             "mtCO<sub>2</sub>e",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                    "GHG Emissions", 2019L,   "B.C.",    4.7,             "mtCO<sub>2</sub>e",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                    "GHG Emissions", 2018L,   "B.C.",    4.7,             "mtCO<sub>2</sub>e",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                    "GHG Emissions", 2017L,   "B.C.",    4.2,             "mtCO<sub>2</sub>e",
  "Environmental",                                   "Agriculture",                    "GHG Intensity", 2020L,   "B.C.",     64, "tCO<sub>2</sub>e per employee",
  "Environmental",                                   "Agriculture",                    "GHG Intensity", 2019L,   "B.C.",     72, "tCO<sub>2</sub>e per employee",
  "Environmental",                                   "Agriculture",                    "GHG Intensity", 2018L,   "B.C.",     78, "tCO<sub>2</sub>e per employee",
  "Environmental",                                   "Agriculture",                    "GHG Intensity", 2017L,   "B.C.",     70, "tCO<sub>2</sub>e per employee",
  "Environmental",                                  "Construction",                    "GHG Intensity", 2021L,   "B.C.",      4, "tCO<sub>2</sub>e per employee",
  "Environmental",                                  "Construction",                    "GHG Intensity", 2020L,   "B.C.",      3, "tCO<sub>2</sub>e per employee",
  "Environmental",                                  "Construction",                    "GHG Intensity", 2019L,   "B.C.",      4, "tCO<sub>2</sub>e per employee",
  "Environmental",                                  "Construction",                    "GHG Intensity", 2018L,   "B.C.",      4, "tCO<sub>2</sub>e per employee",
  "Environmental",                                  "Construction",                    "GHG Intensity", 2017L,   "B.C.",      3, "tCO<sub>2</sub>e per employee",
  "Environmental",                                      "Forestry",                    "GHG Intensity", 2021L,   "B.C.",     30, "tCO<sub>2</sub>e per employee",
  "Environmental",                                      "Forestry",                    "GHG Intensity", 2020L,   "B.C.",     29, "tCO<sub>2</sub>e per employee",
  "Environmental",                                      "Forestry",                    "GHG Intensity", 2019L,   "B.C.",     34, "tCO<sub>2</sub>e per employee",
  "Environmental",                                      "Forestry",                    "GHG Intensity", 2018L,   "B.C.",     45, "tCO<sub>2</sub>e per employee",
  "Environmental",                                      "Forestry",                    "GHG Intensity", 2017L,   "B.C.",     34, "tCO<sub>2</sub>e per employee",
  "Environmental",                                 "Manufacturing",                    "GHG Intensity", 2022L,   "B.C.",     88, "tCO<sub>2</sub>e per employee",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                    "GHG Intensity", 2021L,   "B.C.",    156, "tCO<sub>2</sub>e per employee",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                    "GHG Intensity", 2020L,   "B.C.",    202, "tCO<sub>2</sub>e per employee",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                    "GHG Intensity", 2019L,   "B.C.",    175, "tCO<sub>2</sub>e per employee",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                    "GHG Intensity", 2018L,   "B.C.",    169, "tCO<sub>2</sub>e per employee",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction",                    "GHG Intensity", 2017L,   "B.C.",    139, "tCO<sub>2</sub>e per employee",
  "Environmental",                                  "Construction", "Portion of Total B.C. Energy Use", 2021L,   "B.C.",    3.2,                             "%",
  "Environmental",                                  "Construction", "Portion of Total B.C. Energy Use", 2020L,   "B.C.",    2.9,                             "%",
  "Environmental",                                  "Construction", "Portion of Total B.C. Energy Use", 2019L,   "B.C.",    3.2,                             "%",
  "Environmental",                                  "Construction", "Portion of Total B.C. Energy Use", 2018L,   "B.C.",    3.2,                             "%",
  "Environmental",                                  "Construction", "Portion of Total B.C. Energy Use", 2017L,   "B.C.",    2.9,                             "%",
  "Environmental",                                      "Forestry", "Portion of Total B.C. Energy Use", 2021L,   "B.C.",    1.9,                             "%",
  "Environmental",                                      "Forestry", "Portion of Total B.C. Energy Use", 2020L,   "B.C.",    1.8,                             "%",
  "Environmental",                                      "Forestry", "Portion of Total B.C. Energy Use", 2019L,   "B.C.",    1.9,                             "%",
  "Environmental",                                      "Forestry", "Portion of Total B.C. Energy Use", 2018L,   "B.C.",    2.5,                             "%",
  "Environmental",                                      "Forestry", "Portion of Total B.C. Energy Use", 2017L,   "B.C.",    2.2,                             "%",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction", "Portion of Total B.C. Energy Use", 2021L,   "B.C.",     20,                             "%",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction", "Portion of Total B.C. Energy Use", 2020L,   "B.C.",   21.7,                             "%",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction", "Portion of Total B.C. Energy Use", 2019L,   "B.C.",   19.7,                             "%",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction", "Portion of Total B.C. Energy Use", 2018L,   "B.C.",   19.4,                             "%",
  "Environmental", "Mining, Quarrying, and Oil and Gas Extraction", "Portion of Total B.C. Energy Use", 2017L,   "B.C.",   17.6,                             "%",
  "Environmental",                                 "Manufacturing",                "Water Consumption", 2021L,   "B.C.",   2128,     "cubic liters per employee",
  "Environmental",                                 "Manufacturing",                "Water Consumption", 2020L,   "B.C.",   2228,     "cubic liters/per employee",
  "Environmental",                                 "Manufacturing",                "Water Consumption", 2017L,   "B.C.",   2125,     "cubic liters/per employee",
  "Environmental",                                 "Manufacturing",                "Water Consumption", 2015L,   "B.C.",   2088,     "cubic liters/per employee",
  "Environmental",                                 "Manufacturing",                "Water Consumption", 2013L,   "B.C.",   2104,     "cubic liters/per employee"
)

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





