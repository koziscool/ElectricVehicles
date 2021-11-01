
library(tidyverse)
library(zipcodeR)
library(ggplot2)
library(dplyr)

zip_distance("08731", "08901")
zip_distance("97006", "97007")

zips = read.csv('OregonZipCodes.csv')
zipOnly = zips$zip
zipOnly
zip_test = zipOnly[1:10]

zip_test

#b = as.character(rep(zip_test, times=10))
b
#a = as.character(rep(zip_test, each=10))
a

a = zipOnly[1:10]
b = zipOnly[1:10]

for (i  in a)
{
  for (j  in b)
  {
    d = zip_distance(i,j)
    d
  }
}


d = zip_distance(a,b)
d

