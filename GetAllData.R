
library(httr)
library(jsonlite)
library(tidycensus)
library(tidyverse)
library(tigris)
library(sf)
library(readr)

######## ev registrations

or_electric_vehicles = read.csv("or_ev_registrations_public.csv")[ ,
    c(3, 4, 6, 8, 9, 10) ] 

########## charging station data

url_stub = "https://developer.nrel.gov/api/alt-fuel-stations/v1.json?"
api_key = read_file("nrel_api_key")

my_query = list(
  api_key = api_key,
  fuel_type = 'ELEC',
  state='OR'
)

response =  GET(url = url_stub, query = my_query)

text_response = content(response,'text')
charging_station_df = fromJSON(text_response, flatten=TRUE ) %>% data.frame()
charging_station_df = select(charging_station_df, 
  fuel_stations.city, 
  fuel_stations.state, 
  fuel_stations.zip,
  fuel_stations.plus4,
  fuel_stations.status_code,
  fuel_stations.access_code
  )

write.csv(charging_station_df, file='OregonChargingStations.csv', row.names=F)

########### census data

api_key = str_trim(read_file("census_api_key"))
census_api_key(api_key)

or_income = get_acs(geography = "zcta", 
                    variables = c(medincome = "B19013_001"), 
                    state = "OR", 
                    year = 2019)

write.csv(or_income, file='OregonCensusIncome.csv', row.names=F)

########## joins

income_merge_charging_stations = full_join(
  or_income, charging_station_df,
  by = c("GEOID" = "fuel_stations.zip")
)

or_electric_vehicles$ZIP.Code = as.character(or_electric_vehicles$ZIP.Code)

income_merge_cs_merge_evs = full_join(
  income_merge_charging_stations, or_electric_vehicles,
  by = c("GEOID" = "ZIP.Code")
)
