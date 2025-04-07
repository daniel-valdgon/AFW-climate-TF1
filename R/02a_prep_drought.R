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
# Agricultural Drought Historical Frequency - FAO ASI (1984-2023)
#------------------------------------------------------------------------------#

# Historic agricultural drought frequency - FAO ASI - 30/50% affected
hdf <- rast(
  list.files("../Hazard exposure/inputs/drought_ASI/historical/1984-2023", 
             ".tif$",full.names=TRUE)) |>
  crop(afw) |>
  subst(251:254,NA)
# flags: 251: incomplete season; 252: no data; 253: no season; 254: no cropland/grassland

# maximum frequency in any season - cropland
hdf_c <- c(max(hdf[[c(1,3)]], na.rm = TRUE),
           max(hdf[[c(2,4)]], na.rm = TRUE))
names(hdf_c) <- c("LA30", "LA50")
plot(hdf_c)

writeRaster(hdf_c, "1_data/Climate/Drought/asi_freq_cropland_1km.tif", 
            datatype = "INT1U",overwrite = TRUE)

# maximum frequency in any season - grassland
hdf_p <- c(max(hdf[[c(5,7)]], na.rm = TRUE),
           max(hdf[[c(6,8)]], na.rm = TRUE))
names(hdf_p) <- c("LA30", "LA50")
plot(hdf_p)

writeRaster(hdf_p, "1_data/Climate/Drought/asi_freq_grassland_1km.tif", 
            datatype = "INT1U",overwrite = TRUE)

# convert to ~ annual exceedance freq
for (aep in c(2.5, 5, 10, 20)){
  hdf_c[[paste0("AEP",aep)]]<- ifel(hdf_c$LA50>=aep, 2,ifel(hdf_c$LA30>=aep,1, 0))
  levels(hdf_c[[paste0("AEP",aep)]]) <- data.frame(value = c(0:2), 
                                                 label = c("≤ 30% land affected",
                                                           "30-50% land affected",
                                                           ">50% land affected"))
  
  hdf_p[[paste0("AEP",aep)]] <- ifel(hdf_p$LA50>=aep, 2,ifel(hdf_p$LA30>=aep,1, 0))
  levels(hdf_p[[paste0("AEP",aep)]]) <- data.frame(value = c(0:2), 
                                                 label = c("≤ 30% land affected",
                                                           "30-50% land affected",
                                                           ">50% land affected"))
}

hdf_c_aep <- subset(hdf_c, 3:6)
writeRaster(hdf_c_aep, "1_data/Climate/Drought/asi_cropland_1km.tif", 
            datatype = "INT1U",overwrite = TRUE)


hdf_p_aep <- subset(hdf_p, 3:6)
writeRaster(hdf_p_aep, "1_data/Climate/Drought/asi_grassland_1km.tif", 
            datatype = "INT1U",overwrite = TRUE)

hdf_any_aep <- c(max(hdf_c_aep[[1]],hdf_p_aep[[1]], na.rm = TRUE),
                 max(hdf_c_aep[[2]],hdf_p_aep[[2]], na.rm = TRUE),
                 max(hdf_c_aep[[3]],hdf_p_aep[[3]], na.rm = TRUE),
                 max(hdf_c_aep[[4]],hdf_p_aep[[4]], na.rm = TRUE))

for (n in 1:nlyr(hdf_any_aep)){
  levels(hdf_any_aep[[n]]) <- data.frame(value = c(0:2), 
                                         label = c("≤ 30% land affected",
                                                   "30-50% land affected",
                                                   ">50% land affected"))
}
names(hdf_any_aep) <- names(hdf_c_aep)


writeRaster(hdf_any_aep, "1_data/Climate/Drought/asi_any_1km.tif", 
            datatype = "INT1U",overwrite = TRUE)

# Source: https://data.apps.fao.org/catalog/iso/f8568e67-46e7-425d-b779-a8504971389b

#------------------------------------------------------------------------------#
# CHC-CMIP6 Annual number of dry days (VPD)
#------------------------------------------------------------------------------#

chc <- "https://data.chc.ucsb.edu/products/CHC_CMIP6/extremes/"

month <- c(paste0("0",1:9),10:12)
year <- c(1983:2016)

drought = c("vpd")

extreme <- data.frame(drought = c("vpd","vpd"),
                      name = c("/Daily_VPD_","/Daily_VPD_"),
                      indicator = c("cnt_VPDgt2kPa","cnt_VPDgt3kPa"))

climate <- c("observations",
             "2030_SSP245",
             "2030_SSP585",
             "2050_SSP245",
             "2050_SSP585")

for (t in drought){
  
  name <- extreme[extreme$drought==t,"name"][1]
  
  for (i in extreme[extreme$drought==t,"indicator"]){
    
    for (c in climate){
      
      drydays_c <- rast()
      
      for (y in year){
        
        drydays_y <- rast()
        
        for (m in month){
          
          dry <- rast(paste0(chc,t,"/",c,"/",m,name,y,"_",m,"_",i,".tif")) |>
            crop(afw)
          
          names(dry) <- m
          drydays_y <- c(drydays_y, dry)
        }
        drydays_y <- subst(drydays_y,-9999,NA) |> app(sum, na.rm = TRUE)
        
        names(drydays_y) <- y
        drydays_c <- c(drydays_c, drydays_y)
      }
      drydays_p <- c(quantile(drydays_c, 0.5, na.rm=FALSE),
                     quantile(drydays_c, 0.9, na.rm=FALSE),
                     quantile(drydays_c, 0.95, na.rm=FALSE))
      
      names(drydays_p) <- c("P50", "P90", "P95")
      
      writeRaster(drydays_p,
                  paste0("1_data/Climate/Drought/",t,"_",c,"_",i,"_3arcmin.tif"),
                  datatype = "INT2S", overwrite = TRUE)
      
      rm(dry,drydays_c,drydays_y,drydays_p)
      tmpFiles(current=TRUE, orphan=TRUE, remove=TRUE)
    }
  }
}
