rm(list = ls()) # empty workspace
gc() # free-up unused memory

# load packages
library(sf)
library(terra)
library(exactextractr)
library(data.table)
library(dplyr)

setwd("~/Library/CloudStorage/OneDrive-WBG/West_Africa_Exposure")
# setwd("C:/Users/wb587256/OneDrive - WBG/West_Africa_Exposure")

#------------------------------------------------------------------------------#
# boundaries
#------------------------------------------------------------------------------#

afw <- st_read("1_data/Maps/boundaries/AFW_admin0.gpkg") |>
  st_make_valid() |> 
  st_union() |> 
  st_as_sf()

plot(afw)
### LOOP OVER COUNTRIES??

#------------------------------------------------------------------------------#
# population data to grid
#------------------------------------------------------------------------------#

pop <- rast("1_data/Population/GHS-POP_2025_3arcsec.tif")
dou <- rast("1_data/Population/GHS-SMOD2_2025_res3arcsec.tif")

raster <- crop(c(pop,dou), afw, mask = TRUE)
names(raster) <- c("pop_2025","dou_2025")

grid <- as.data.frame(raster, xy=TRUE)

#------------------------------------------------------------------------------#
# hazard data to grid
#------------------------------------------------------------------------------#

# hazard maps
drought_any <- rast("1_data/Climate/Drought/asi_any_cat_res3arcsec.tif")
drought_cropland <- rast("1_data/Climate/Drought/asi_cropland_cat_res3arcsec.tif")
drought_grassland <- rast("1_data/Climate/Drought/asi_grassland_cat_res3arcsec.tif")

dry_days_VPDgt2kPa <- rast("1_data/Climate/Drought/vpd_observations_cnt_VPDgt2kPa_cat_res3arcsec.tif")
dry_days_VPDgt3kPa <- rast("1_data/Climate/Drought/vpd_observations_cnt_VPDgt3kPa_cat_res3arcsec.tif")

flood_any <- rast("1_data/Climate/Flood/any_2020_90m_cat_res3arcsec.tif")
flood_coastal <- rast("1_data/Climate/Flood/coastal-undefended_2020_90m_cat_res3arcsec.tif") 
flood_fluvial <- rast("1_data/Climate/Flood/fluvial-undefended_2020_90m_cat_res3arcsec.tif") 
flood_pluvial <- rast("1_data/Climate/Flood/pluvial-defended_2020_90m_cat_res3arcsec.tif")

flood_any_450m <- rast("1_data/Climate/Flood/any_2020_450m_cat_res3arcsec.tif")
flood_coastal_450m <- rast("1_data/Climate/Flood/coastal-undefended_2020_450m_cat_res3arcsec.tif") 
flood_fluvial_450m <- rast("1_data/Climate/Flood/fluvial-undefended_2020_450m_cat_res3arcsec.tif") 
flood_pluvial_450m <- rast("1_data/Climate/Flood/pluvial-defended_2020_450m_cat_res3arcsec.tif")

flood_any_990m <- rast("1_data/Climate/Flood/any_2020_990m_cat_res3arcsec.tif")
flood_coastal_990m <- rast("1_data/Climate/Flood/coastal-undefended_2020_990m_cat_res3arcsec.tif") 
flood_fluvial_990m <- rast("1_data/Climate/Flood/fluvial-undefended_2020_990m_cat_res3arcsec.tif") 
flood_pluvial_990m <- rast("1_data/Climate/Flood/pluvial-defended_2020_990m_cat_res3arcsec.tif")

sea_level_rise_2080_ssp585 <- rast("1_data/Climate/Flood/sea-level-rise_2050-SSP5_8.5_90m_cat_res3arcsec.tif")
sea_level_rise_2080_ssp585_450m <- rast("1_data/Climate/Flood/sea-level-rise_2050-SSP5_8.5_450m_cat_res3arcsec.tif")
sea_level_rise_2080_ssp585_990m <- rast("1_data/Climate/Flood/sea-level-rise_2050-SSP5_8.5_990m_cat_res3arcsec.tif")

heat_ESI5daymax <- rast("1_data/Climate/Heat/ESI_5daymax_cat_res3arcsec.tif")

heat_days_WBGTgt28C <- rast("1_data/Climate/Heat/wbgtmax_observations_cnt_WBGTgt28C_cat_res3arcsec.tif")
heat_days_WBGTgt30C <- rast("1_data/Climate/Heat/wbgtmax_observations_cnt_WBGTgt30C_cat_res3arcsec.tif")

heat_days_Tgt30C <- rast("1_data/Climate/Heat/Tmax_observations_cnt_Tmaxgt30C_cat_res3arcsec.tif")
heat_days_Tgt40p6C <- rast("1_data/Climate/Heat/Tmax_observations_cnt_Tmaxgt40p6C_cat_res3arcsec.tif")

air_pollution <-  rast("1_data/Climate/Air pollution/pm2-5_P50_cat_res3arcsec.tif")

# setup
haz_list <- list(
  drought_any, drought_cropland, drought_grassland,
  dry_days_VPDgt2kPa, dry_days_VPDgt3kPa, 
  flood_any, flood_coastal, flood_fluvial, flood_pluvial, 
  flood_any_450m, flood_coastal_450m, flood_fluvial_450m, flood_pluvial_450m, 
  flood_any_990m, flood_coastal_990m, flood_fluvial_990m, flood_pluvial_990m, 
  sea_level_rise_2080_ssp585, sea_level_rise_2080_ssp585_450m, 
  sea_level_rise_2080_ssp585_990m, 
  heat_ESI5daymax,
  heat_days_WBGTgt28C, heat_days_WBGTgt30C,
  heat_days_Tgt30C,heat_days_Tgt40p6C,
  air_pollution)


#------------------------------------------------------------------------------#
# gridded data
#------------------------------------------------------------------------------#

raster <- crop(pop, bounds, mask = TRUE)
names(raster) <- ""

grid <- as.data.frame(raster, xy=TRUE)

