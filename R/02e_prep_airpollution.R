rm() # clear workspace
gc() # free-up unused memory

library(terra)

# setwd("~/Library/CloudStorage/OneDrive-WBG/West_Africa_Exposure")
setwd("C:/Users/wb587256/OneDrive - WBG/West_Africa_Exposure")

#------------------------------------------------------------------------------#
# AFW boundaries
#------------------------------------------------------------------------------#

afw <- vect("1_data/Maps/boundaries/AFW_admin0.gpkg")
plot(afw)

#------------------------------------------------------------------------------#
# WUStL ACAG - Satellite-derived PM2.5 - V6.GL.02.02  (1998-2022)
#------------------------------------------------------------------------------#

# most recent 5 years of PM2.5 data
flist <- list.files("../Hazard Exposure/inputs/air_pollution/wustl_pm2.5", 
                    full.names = TRUE)

pm25 <- rast(flist) |>
  crop(afw)

pm25_clean <- median(pm25, na.rm=TRUE)
names(pm25_clean) <- "P50(2018-2022)"
plot(pm25_clean)

writeRaster(pm25_clean, "1_data/Climate/Air pollution/pm2-5_P50_36arcsec.tif", 
            datatype = "FLT4S",overwrite = TRUE)
