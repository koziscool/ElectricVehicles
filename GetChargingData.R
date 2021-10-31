
library(httr)
library(jsonlite)
library(tidyverse)
library(readr)

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



df

