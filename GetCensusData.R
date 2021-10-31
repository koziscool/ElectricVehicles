
library(tidycensus)
library(tidyverse)
library(tigris)
library(sf)

api_key = str_trim(read_file("census_api_key"))
census_api_key(api_key)

or_income = get_acs(geography = "zcta", 
              variables = c(medincome = "B19013_001"), 
              state = "OR", 
              year = 2019)

write.csv(or_income, file='OregonCensusIncome.csv', row.names=F)

