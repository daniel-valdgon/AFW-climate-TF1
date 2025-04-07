rm(list = ls()) # clear workspace
gc() # free-up unused memory

library(terra)

setwd("~/Library/CloudStorage/OneDrive-WBG/West_Africa_Exposure")
# setwd("C:/Users/wb587256/OneDrive - WBG/West_Africa_Exposure")

#------------------------------------------------------------------------------#
# AFW population
#------------------------------------------------------------------------------#

pop <- rast("1_data/Population/GHS-POP_2025_3arcsec.tif")

#------------------------------------------------------------------------------#
# Drought - Classify and resample to population grid
#------------------------------------------------------------------------------#

# drought ASI historical already categorical (% land affected)
for (t in c("cropland", "grassland", "any")){

  haz <- rast(paste0("1_data/Climate/Drought/asi_",t,"_1km.tif"))
  
  haz <- classify(haz, cbind(NA, 0)) # NA -> 0
  
  haz <- resample(haz,pop,method="near",threads=T) # resample
  
  writeRaster(haz,paste0("1_data/Climate/Drought/asi_",t,"_cat_res3arcsec.tif"),
              datatype = "INT1U", overwrite = TRUE,
              gdal = c("COMPRESS=ZSTD", "PREDICTOR=2"))
}

# drought VPD (number of days above threshold)
breaks <- c(0, 10, 20, 50, 100, 200, 300, Inf)  # days above threshold

for (c in c("observations","2030_SSP245","2030_SSP585",
            "2050_SSP245","2050_SSP585")){
  
  for (i in c("cnt_VPDgt2kPa","cnt_VPDgt3kPa")){
  
    haz <- rast(paste0("1_data/Climate/Drought/vpd_",c,"_",i,"_3arcmin.tif"))
    
    haz <- classify(haz,breaks,include.lowest=TRUE) |> # classify using breaks
      classify(cbind(NA, 0)) # NA -> 0
    
    haz <- resample(haz,pop,method="near",threads=T) # resample
    
    writeRaster(haz,paste0("1_data/Climate/Drought/vpd_",c,"_",i,
                           "_cat_res3arcsec.tif"),
                datatype = "INT1U", overwrite = TRUE,
                gdal = c("COMPRESS=ZSTD", "PREDICTOR=2"))
  }
}

#------------------------------------------------------------------------------#
# Heat - Classify and resample to population grid
#------------------------------------------------------------------------------#

# heatwave CCKP ESI (5-day max daily °C)
breaks <- c(-Inf,28,30,32,33,34,35,Inf)
haz <- rast("1_data/Climate/Heat/ESI_5daymax_15arcmin.tif")

haz <- classify(haz,breaks,include.lowest=TRUE) |> # classify using breaks
  classify(cbind(NA, 0)) # NA -> 0

haz <- resample(haz,pop,method="near",threads=T) # resample

writeRaster(haz,"1_data/Climate/Heat/ESI_5daymax_cat_res3arcsec.tif",
            datatype = "INT1U", overwrite = TRUE,
            gdal = c("COMPRESS=ZSTD", "PREDICTOR=2"))  

# extreme heat (number of days above threshold)
breaks <- c(0, 10, 20, 50, 100, 200, 300, Inf) # days above threshold

temp <- c("Tmax","wbgtmax")

extreme <- data.frame(temp = c("Tmax","Tmax",
                               "wbgtmax","wbgtmax"),
                      name = c("/Daily_Tmax_","/Daily_Tmax_",
                               "/Daily_WBGT_","/Daily_WBGT_"),
                      indicator = c("cnt_Tmaxgt30C","cnt_Tmaxgt40p6C",
                                    "cnt_WBGTgt28C","cnt_WBGTgt30C"))

climate <- c("observations",
             "2030_SSP245",
             "2030_SSP585",
             "2050_SSP245",
             "2050_SSP585")

for (t in temp){
  
  name <- extreme[extreme$temp==t,"name"][1]
  
  for (i in extreme[extreme$temp==t,"indicator"]){
    
    for (c in climate){
      
      haz <- rast(paste0("1_data/Climate/Heat/",t,"_",c,"_",i,"_3arcmin.tif"))
      
      haz <- classify(haz,breaks,include.lowest=TRUE) |> # classify using breaks
        classify(cbind(NA, 0)) # NA -> 0
      
      haz <- resample(haz,pop,method="near",threads=T) # resample
      
      writeRaster(haz,paste0("1_data/Climate/Heat/",t,"_",c,"_",i,
                             "_cat_res3arcsec.tif"),
                  datatype = "INT1U", overwrite = TRUE,
                  gdal = c("COMPRESS=ZSTD", "PREDICTOR=2"))
    }
  }
}

#------------------------------------------------------------------------------#
# Flood - Classify and resample to population grid
#------------------------------------------------------------------------------#

breaks <- c(0,0,15,50,100,150,Inf) # max inundation depth (cm)

type <- c("pluvial-defended")
# c("coastal-undefended","fluvial-undefended","pluvial-defended")
climate <- c("2020")

for (t in type){
  for (c in climate){
  
    flist <- gtools::mixedsort(
      list.files("1_data/Climate/Flood/", 
                 paste0(t,"_",c,".+1arcsec"), 
                 full.names = TRUE))
    
    haz <- rast(flist)
    
    haz <- classify(haz,breaks,include.lowest=TRUE) |> # classify using breaks
      classify(cbind(NA, 0)) # NA -> 0
    
    # 90m buffer to flooding
    haz_90 <- focal(haz, 3, "max", na.rm=TRUE) # window size 3 = 3*~30 = ~90m
    haz_90 <- resample(haz_90,pop,method="mode", threads=TRUE)
    
    writeRaster(haz_90,paste0("1_data/Climate/Flood/",t,"_",c,"_",
                             "90m_cat_res3arcsec.tif"),
                datatype = "INT1U", overwrite = TRUE,
                gdal = c("COMPRESS=ZSTD", "PREDICTOR=2"))
    
    # larger buffer to flooding
    for (w in c(5, 11)){ # window size 5=5*~90 = ~450m, 11=11*~90 = ~990m
      b <- w*90
      haz_b <- focal(haz_90, w, "max", na.rm=TRUE)
    
      writeRaster(haz_b,paste0("1_data/Climate/Flood/",t,"_",c,"_",b,
                               "m_cat_res3arcsec.tif"),
                  datatype = "INT1U", overwrite = TRUE,
                  gdal = c("COMPRESS=ZSTD", "PREDICTOR=2"))
    }
    rm(haz_b)
    tmpFiles(orphan=TRUE, remove=TRUE)
  }
}

# any flood 
for (c in climate){
  for (b in c(90, 450, 990)){ # 90m, 450m, 990m
    
    flist <- list.files("1_data/Climate/Flood",
                        paste0(".+defended.+",c,"_",b,"m_cat_res3arcsec"), 
                        full.names = TRUE)

    haz <- max(rast(flist[1]), rast(flist[2]), rast(flist[3]), na.rm=TRUE)

    writeRaster(haz,paste0("1_data/Climate/Flood/any_",c,"_",b,
                           "m_cat_res3arcsec.tif"),
                datatype = "INT1U", overwrite = TRUE,
                gdal = c("COMPRESS=ZSTD", "PREDICTOR=2"))
  }
}

#------------------------------------------------------------------------------#
# Sea level rise - Classify and resample to population grid
#------------------------------------------------------------------------------#

breaks <- c(-Inf,0,15,50,100,150,Inf) # max change in inundation depth (cm)

climate <- c("2050-SSP5_8.5","2080-SSP5_8.5")

for (c in climate){
  
  flist <- gtools::mixedsort(
    list.files("1_data/Climate/Flood/", 
               paste0("sea-level-rise_",c,".+1arcsec"), 
               full.names = TRUE))
  
  haz <- rast(flist)
  
  haz <- classify(haz,breaks,include.lowest=TRUE) |> # classify using breaks
    classify(cbind(NA, 0)) # NA -> 0
  
  # 90m buffer to flooding
  haz_90 <- focal(haz, 3, "max", na.rm=TRUE) # window size 3 = 3*~30 = ~90m
  haz_90 <- resample(haz_90,pop,method="mode", threads=TRUE)
  
  writeRaster(haz_90,paste0("1_data/Climate/Flood/sea-level-rise_",c,"_",
                            "90m_cat_res3arcsec.tif"),
              datatype = "INT1U", overwrite = TRUE,
              gdal = c("COMPRESS=ZSTD", "PREDICTOR=2"))
  
  # larger buffer to flooding
  for (w in c(5, 11)){ # window size 5=5*~90 = ~450m, 11=11*~90 = ~990m
    b <- w*90
    haz_b <- focal(haz_90, w, "max", na.rm=TRUE)
    
    writeRaster(haz_b,paste0("1_data/Climate/Flood/sea-level-rise_",c,"_",b,
                             "m_cat_res3arcsec.tif"),
                datatype = "INT1U", overwrite = TRUE,
                gdal = c("COMPRESS=ZSTD", "PREDICTOR=2"))
  }
  rm(haz_b)
  tmpFiles(orphan=TRUE, remove=TRUE)
}

#------------------------------------------------------------------------------#
# Air pollution - Classify and resample to population grid
#------------------------------------------------------------------------------#

breaks <- c(0,5,10,15,25,35,50,Inf) # Annual PM2.5 (µg/m3)

haz <- rast("1_data/Climate/Air pollution/pm2-5_P50_36arcsec.tif")
  
haz <- classify(haz,breaks,include.lowest=TRUE) |> # classify using breaks
  classify(cbind(NA, 0)) # NA -> 0

haz <- resample(haz,pop,method="near",threads=T) # resample

writeRaster(haz,"1_data/Climate/Air pollution/pm2-5_P50_cat_res3arcsec.tif",
            datatype = "INT1U", overwrite = TRUE,
            gdal = c("COMPRESS=ZSTD", "PREDICTOR=2"))

#------------------------------------------------------------------------------#
# Conflict - Classify and resample to population grid
#------------------------------------------------------------------------------#

