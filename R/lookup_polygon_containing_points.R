rm(list = ls())  # clear workspace
gc() # free-up unused memory

library(sf)
library(haven)

setwd("~/Library/CloudStorage/OneDrive-WBG/West_Africa_Exposure")
# setwd("C:/Users/wb587256/OneDrive - WBG/West_Africa_Exposure")

#------------------------------------------------------------------------------#
# Lookup polygon containing survey coordinates
#------------------------------------------------------------------------------#

# boundaries
afw_adminX <- st_read("1_data/Maps/boundaries/AFW_adminX.gpkg")

#survey data with (anonymized) coordinates
survey <- read_dta("1_data/Household_survey/BEN/BEN_2021_EHCVM_V01_M_V01_A_GMD_LOC.dta")

# convert coordinates to point geometry 
survey_pts <- st_as_sf(survey, coords = c("gps_lon", "gps_lat"), crs = st_crs(4326)) 

# spatial join - lookup admin region containing each point
sf_use_s2(FALSE)
survey_admin <- st_join(survey_pts, afw_adminX[,-2], join = st_within)
  
# save 
write_dta(st_drop_geometry(survey_admin), 
          "1_data/Household_survey/BEN/BEN_2021_EHCVM_admin_lookup.dta")
