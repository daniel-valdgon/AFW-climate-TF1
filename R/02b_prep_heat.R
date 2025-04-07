rm() # clear workspace
gc() # free-up unused memory

library(terra)
library(gtools)

setwd("~/Library/CloudStorage/OneDrive-WBG/West_Africa_Exposure")
# setwd("C:/Users/wb587256/OneDrive - WBG/West_Africa_Exposure")

#------------------------------------------------------------------------------#
# AFW boundaries
#------------------------------------------------------------------------------#

afw <- vect("1_data/Maps/boundaries/AFW_admin0.gpkg")
plot(afw)

#------------------------------------------------------------------------------#
# CCKP 5-day maximum daily Environmental Stress Index (ESI)
#------------------------------------------------------------------------------#

files <- list.files(
  "../Hazard exposure/inputs/heatwave_ESI/esx5day/medians",".nc$",
  full.names=TRUE) 

heat <- rast(mixedsort(sort(files))) |>
  crop(afw)
names(heat) <- c("RP5","RP10","RP20","RP50","RP100")

heat
plot(heat)

# save return period stack with 5-day max esi
writeRaster(heat, "1_data/Climate/Heat/ESI_5daymax_15arcmin.tif", 
            datatype = "FLT4S", overwrite = TRUE)

#------------------------------------------------------------------------------#
# CHC-CMIP6 Annual number of extreme heat days (T and WBGT)
#------------------------------------------------------------------------------#

# CHC-CMIP6 extreme WBGT server address
chc <- "https://data.chc.ucsb.edu/products/CHC_CMIP6/extremes/"

month <- c(paste0("0",1:9),10:12)
year <- c(1983:2016)

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
      
      hotdays_c <- rast()
      
      for (y in year){
        
        hotdays_y <- rast()
        
        for (m in month){
      
          hot <- rast(paste0(chc,t,"/",c,"/",m,name,y,"_",m,"_",i,".tif")) |>
            crop(afw)
          
          names(hot) <- m
          hotdays_y <- c(hotdays_y, hot)
        }
        hotdays_y <- subst(hotdays_y,-9999,NA) |> app(sum, na.rm = TRUE)
        
        names(hotdays_y) <- y
        hotdays_c <- c(hotdays_c, hotdays_y)
      }
      hotdays_p <- c(quantile(hotdays_c, 0.5, na.rm=FALSE),
                     quantile(hotdays_c, 0.9, na.rm=FALSE),
                     quantile(hotdays_c, 0.95, na.rm=FALSE))
      
      names(hotdays_p) <- c("P50", "P90", "P95")

      writeRaster(hotdays_p,
                  paste0("1_data/Climate/Heat/",t,"_",c,"_",i,"_3arcmin.tif"),
                  datatype = "INT2S", overwrite = TRUE)
      
      rm(hot,hotdays_c,hotdays_y,hotdays_p)
      tmpFiles(current=TRUE, orphan=TRUE, remove=TRUE)
    }
  }
}
