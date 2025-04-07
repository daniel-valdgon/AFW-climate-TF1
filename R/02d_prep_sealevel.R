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
afw1 <- vect("1_data/Maps/boundaries/AFW_admin1.gpkg")

#------------------------------------------------------------------------------#
# Exposure to sea level rise and climate change 
#------------------------------------------------------------------------------#

# Maximum inundation due to sea level rise  = 
  # Future coastal flooding - present coastal flooding

#------------------------------------------------------------------------------#
# Get Fathom 3.0 SSP585 2050 and 2080 Coastal Flood Maps - 1 arcsecond
#------------------------------------------------------------------------------#

  #tiles
  tlist <- c()
  for (code in unique(afw1$adm0_pcode)){
    dirname <- list.files("../Fathom 3.0/",paste0(code,"_"))
    flist <- read.csv(paste0("../Fathom 3.0/",dirname,"/",
                             dirname,"_file_list.csv"))
    tiles <- unique(gsub(".*(.{11})$", "\\1", flist$path))
    tlist <- unique(c(tlist, tiles))
  }
  
  # Loop over different flood types, options and RPs
  type <- c("COASTAL-UNDEFENDED")
  # c("COASTAL-UNDEFENDED","FLUVIAL-UNDEFENDED",
  #   "FLUVIAL-DEFENDED","PLUVIAL-DEFENDED")
  
  climate <- c("2050-SSP5_8.5","2080-SSP5_8.5")
  # c("2020", 
  #  "2030-SSP2_4.5", "2030-SSP3_7.0","2030-SSP5_8.5", 
  #  "2050-SSP2_4.5", "2050-SSP3_7.0","2050-SSP5_8.5", 
  #  "2080-SSP2_4.5", "2080-SSP3_7.0","2080-SSP5_8.5")
  
  return <- c(5,10,20,100)
  # c(5,10,20,50,100,200,500,1000)
  
  # download, merge AFW tiles, save
  for (t in type) {
    for (c in climate){
      for (rp in return){
        
        fnames <- paste0("1in",rp,"-",t,"-",c,"_",tlist)
        
        flist <- list.files("../Fathom 3.0/",
                            paste0(fnames,collapse = "|"),
                            full.names = TRUE, recursive = TRUE)
        
        flist <- data.frame(name = flist, 
                            tile = gsub(".*(.{11})$", "\\1", flist))
        
        flist <- flist[!duplicated(flist$tile),]
        
        f <- merge(sprc(flist$name))
        f <- subst(f,-32768,NA) # No data pixels --> NA
        f <- subst(f,-32767,NA) # perm. water bodies --> NA
        names(f) <- paste0("RP",rp)
        
        writeRaster(f, paste0("1_data/Climate/Flood/",tolower(t),"_",c,"_RP",rp,
                              "_1arcsec.tif"),
                    datatype = "INT2S", overwrite = TRUE,
                    gdal = c("COMPRESS=ZSTD", "PREDICTOR=2", "ZSTDLEVEL=1")) 
      }
    }
  }

#------------------------------------------------------------------------------#
# Calculate change in coastal flood inundation = sea level rise
#------------------------------------------------------------------------------#

climate <- c("2050-SSP5_8.5","2080-SSP5_8.5")
return <- c(5,10,20,100)

for (rp in return){
  
  present <- rast(paste0("1_data/Climate/Flood/coastal-undefended_2020_RP",rp,
                  "_1arcsec.tif"))
  
  for (c in climate){
  
  future <- rast(paste0("1_data/Climate/Flood/coastal-undefended_",c,"_RP",rp,
                        "_1arcsec.tif"))
  
  delta <- future - present
  
  writeRaster(delta, paste0("1_data/Climate/Flood/sea-level-rise_",c,"_RP",rp,
                        "_1arcsec.tif"),
              datatype = "INT2S", overwrite = TRUE,
              gdal = c("COMPRESS=ZSTD", "PREDICTOR=2", "ZSTDLEVEL=1")) 
    
  }
}
