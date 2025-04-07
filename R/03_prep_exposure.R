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
# AFW population
#------------------------------------------------------------------------------#

# POPULATION - GHSL - 2020 - 3arcsec - WGS84 (GHS-POP-R2023A)

pop <- rast("../Hazard Exposure/inputs/population/GHS_POP_E2025_GLOBE_R2023A_4326_3ss_V1_0.tif") |>
  crop(afw)

writeRaster(pop, "1_data/Population/GHS-POP_2025_3arcsec.tif")

#------------------------------------------------------------------------------#
# AFW degree of urbanisation
#------------------------------------------------------------------------------#

# DEGREE OF URBANISATION - GHSL - 1km - World Mollweide (GHS-SMOD-R2023A)

smod<-rast("../Hazard Exposure/inputs/degurban/GHS_SMOD_E2025_GLOBE_R2023A_54009_1000_V2_0.tif") |>
  crop(project(afw,'ESRI:54009'))

crs(smod) <- 'ESRI:54009' # Mollweide coordinate system (54009), 1000m grid

# degurban classification
levels(smod) <- data.frame(id=c(10,11,12,13,21,22,23,30),
                           urb=c("water",
                                 "very low density rural",
                                 "low density rural", 
                                 "rural cluster",
                                 "suburban or peri-urban",
                                 "semi-dense urban cluster",
                                 "dense urban cluster", 
                                 "urban centre"))

writeRaster(smod, "1_data/Population/GHS-SMOD_2025_1km.tif",
            datatype = "INT1U", overwrite = TRUE)

# project and resample to population grid
smod_prj <- project(smod, crs(pop))
smod_res <- resample(smod_prj, pop, method='near', threads=TRUE)
writeRaster(smod_res, "1_data/Population/GHS-SMOD_2025_res3arcsec.tif", 
            datatype = "INT1U", overwrite = TRUE)

# reclassify SMOD water cells with population to non-water

  # average population per dou category
  pop_1km <- rast("../Hazard exposure/inputs/population/GHS_POP_E2025_GLOBE_R2023A_54009_1000_V1_0.tif") |>
    crop(project(afw,'ESRI:54009'))
  
  # use modal class within 5km 
  smod_waterna <- sum(as.numeric(smod),10,NA)
  smod_rcl <- focal(smod_waterna,5,"modal",na.rm=TRUE, 
                    na.policy = "only") 
  
  # otherwise use median population to classify
  med_pop <- zonal(pop_1km, smod, fun = "median", na.rm=TRUE)
  pop_smod_m <- c(0,med_pop[3,2],11,
                  med_pop[3,2],med_pop[4,2], 12,
                med_pop[4,2],med_pop[6,2], 21, # skil rural cluster
                med_pop[6,2],med_pop[7,2], 22,
                med_pop[7,2],med_pop[8,2], 23,
                med_pop[8,2],Inf, 30)
  rclmat <- matrix(pop_smod_m, ncol=3, byrow=TRUE)
  smod_med_pop <- classify(pop_1km, rclmat, include.lowest=TRUE)
  smod_rcl <- ifel(is.na(smod_rcl), smod_med_pop, smod_rcl)
  
  smod_rcl_res <- resample(smod_rcl, smod_res, method='near', threads=TRUE)
  smod_res2 <- ifel(smod_res==10 & pop>0, smod_rcl_res, smod_res) 
  levels(smod_res2) <- levels(smod_res)
  
  writeRaster(smod_res2, "1_data/Population/GHS-SMOD2_2025_res3arcsec.tif", 
              datatype = "INT1U", overwrite = TRUE)
  
  plot(smod_res2)
  