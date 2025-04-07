rm() # clear workspace
gc() # free-up unused memory

library(terra)

setwd("~/Library/CloudStorage/OneDrive-WBG/West_Africa_Exposure")
# setwd("C:/Users/wb587256/OneDrive - WBG/West_Africa_Exposure")

#------------------------------------------------------------------------------#
# AFW boundaries
#------------------------------------------------------------------------------#

afw <- vect("1_data/Maps/boundaries/AFW_admin0.gpkg")
plot(afw)

#------------------------------------------------------------------------------#
# ACLED georeferenced data
#------------------------------------------------------------------------------#

library(acledr)


# get UCDP data
getUCDP(db = "gedevents", version = "18.2", location = NULL)

# get ACLED data
getACLED(years = c(2019, 2024), iso = afw$code, event_type = "")

# combine

# select event types

# create raster data with distance to conflict buffers

