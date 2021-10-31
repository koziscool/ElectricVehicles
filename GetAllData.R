
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
df = fromJSON(text_response, flatten=TRUE ) %>% data.frame()
df = select(df, 
  fuel_stations.city, 
  fuel_stations.state, 
  fuel_stations.zip,
  fuel_stations.plus4,
  fuel_stations.status_code,
  fuel_stations.access_code
  )

write.csv(df, file='OregonChargingStations.csv', row.names=F)

########### census data

api_key = str_trim(read_file("census_api_key"))
census_api_key(api_key)

or_income = get_acs(geography = "zcta", 
                    variables = c(medincome = "B19013_001"), 
                    state = "OR", 
                    year = 2019)

write.csv(or_income, file='OregonCensusIncome.csv', row.names=F)

##########