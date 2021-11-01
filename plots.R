
library(httr)
library(jsonlite)
library(tidycensus)
library(tidyverse)
library(tigris)
library(sf)
library(readr)
library(zipcodeR)

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
                    year = 2019,
                    geometry=TRUE)

write.csv(or_income, file='OregonCensusIncome.csv', row.names=F)

########## joins, group bys and mutates

zip_only = data.frame(or_income$GEOID)
colnames(zip_only) = "ZipCode"

or_electric_vehicles$ZIP.Code = as.character(or_electric_vehicles$ZIP.Code)

charging_station_df = charging_station_df %>% 
    add_count(fuel_stations.zip, name = 'Charging.Stations.By.Zip')

or_cs_summary = distinct(charging_station_df, fuel_stations.zip, .keep_all = TRUE)
or_cs_summary = left_join(zip_only, or_cs_summary, 
                          by = c("ZipCode" = "fuel_stations.zip"))
or_cs_summary$Charging.Stations.By.Zip[is.na(or_cs_summary$Charging.Stations.By.Zip)] = 0
cs_with_map = left_join(or_income, or_cs_summary, 
                         by = c("GEOID" = "ZipCode")) 

or_electric_vehicles = or_electric_vehicles %>% 
  add_count(ZIP.Code, name = 'EVs.By.Zip')
or_ev_summary = distinct(or_electric_vehicles, ZIP.Code, .keep_all = TRUE)
or_ev_summary = left_join(zip_only, or_ev_summary, 
      by = c("ZipCode" = "ZIP.Code"))
or_ev_summary$EVs.By.Zip[is.na(or_ev_summary$EVs.By.Zip)] = 0

evs_with_map = left_join(or_income, or_ev_summary, 
        by = c("GEOID" = "ZipCode")) 

#### mapplots

ggplot(data = cs_with_map, aes(fill=Charging.Stations.By.Zip)) + geom_sf() +
  scale_fill_distiller(
    palette = "YlOrBr",
    direction = -1
  ) + 
  theme_void()

ggplot(data = evs_with_map, aes(fill=EVs.By.Zip)) + geom_sf() +
  scale_fill_distiller(
    palette = "YlOrBr",
    direction = -1
  ) + 
  theme_void()

ggplot(data = or_income, aes(fill=estimate)) + geom_sf() +
  scale_fill_distiller(
    palette = "YlOrBr",
    direction = -1
  ) + 
  theme_void()

######## scatterplots

or_join_cs_ev_summary = inner_join(or_ev_summary, or_cs_summary, 
                        by = "ZipCode")

ggplot(data = or_join_cs_ev_summary, 
       aes(x = EVs.By.Zip, y = Charging.Stations.By.Zip)) +
      geom_point()

cor_ev_cs = cor(or_join_cs_ev_summary$EVs.By.Zip,
                or_join_cs_ev_summary$Charging.Stations.By.Zip)
cor_ev_cs


or_join_income_ev_summary = inner_join(or_income, or_ev_summary, 
                                   by = c("GEOID" = "ZipCode"))

ggplot(data = or_join_income_ev_summary, 
       aes(x = EVs.By.Zip, y = estimate)) +
      geom_point()

cor_ev_income = cor(or_join_income_ev_summary$EVs.By.Zip,
                    or_join_income_ev_summary$estimate,
                    use="complete.obs")
cor_ev_income

