#------------------------------------------------------------------------
#	Title: Adding h3 variables (where available) to harmonized survey data
# Project: Regional study on exposure to shocks in SSA countries 
#	Author: Bernardo Atuesta
# First written: July 12, 2025
#------------------------------------------------------------------------

#Install required packages (if not already installed):
#install.packages("h3jsr") # Only once

# Load required libraries
library(sf)
library(haven)

library(h3jsr)
library(readr)
library(dplyr)

setwd("C:/Users/wb384997/OneDrive - WBG/Documents/Climate Change/Regional study on Exposure to shocks/Shared folders/West_Africa_Exposure")

# Countries with GPS data: BEN BFA CIV GMB GNB MLI MRT NER SEN TCD TGO
# Countries without GPS data: CAF CMR CPV GHA GIN LBR NGA SLE

# List of country codes
countries <- c("BEN", "BFA", "CIV", "GHA", "GMB", "GNB", "MLI", "MRT", "NER", "SEN", "TCD", "TGO", "CAF", "CMR", "CPV", "GIN", "LBR", "NGA", "SLE")

for (ctry in countries) {
  message("Processing: ", ctry)
  
  # Construct file paths
  input_path <- paste0("./3_results/hhss-exposure/", ctry, "/RS_", ctry, "_se_geocode.dta")
  output_path <- paste0("./3_results/hhss-exposure/", ctry, "/RS_", ctry, "_se_geocode_h3.dta")
  
  # Load dataset
  survey <- read_dta(input_path)
  
  survey <- survey %>%
    mutate(
      # To avoid errors for missings, replace missing gps values with placeholders (a point not in West Africa and easy to identify -  the north pole)
      gps_lon = if_else(is.na(gps_lon), 179, gps_lon),
      gps_lat = if_else(is.na(gps_lat), 89, gps_lat),
      
      # Compute h3_6 and h3_7 points using gps values and the h3jsr library, assuming EPSG:4326
      h3_6 = point_to_cell(data.frame(lng = gps_lon, lat = gps_lat), res = 6),
      h3_7 = point_to_cell(data.frame(lng = gps_lon, lat = gps_lat), res = 7),
      
      # Restore missing values where placeholders were used 
      h3_6 = if_else((gps_lon == 179 | gps_lat == 89), NA_character_, h3_6),
      h3_7 = if_else((gps_lon == 179 | gps_lat == 89), NA_character_, h3_7),        
      gps_lon = if_else(gps_lon == 179, NA_real_, gps_lon),
      gps_lat = if_else(gps_lat == 89, NA_real_, gps_lat)  
    )
    
  # Save updated dataset
  write_dta(survey, output_path)
}


