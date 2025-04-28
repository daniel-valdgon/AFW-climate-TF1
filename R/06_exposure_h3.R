rm(list = ls()) # empty workspace
gc() # free-up unused memory

# load packages
library(sf)
library(terra)
library(exactextractr)
library(data.table)
library(dplyr)
library(h3o)

# setwd("~/Library/CloudStorage/OneDrive-WBG/West_Africa_Exposure")
setwd("C:/Users/wb587256/OneDrive - WBG/West_Africa_Exposure")

#------------------------------------------------------------------------------#
# h3 resolution 6 cells
#------------------------------------------------------------------------------#

pop <- rast("1_data/Population/GHS-POP_2025_3arcsec.tif")

admin0 <- st_read("1_data/Maps/boundaries/AFW_admin0.gpkg") 

for (c in admin0$code){
  
    aoi <- filter(admin0, code==c)
    aoi_h3 <- sfc_to_cells(aoi$geom, 6, containment = "covers") |>
      h3o::flatten_h3()
    
    h3 <- data.frame(code = c, 
                     h3_6 = as.character(aoi_h3),
                     pop = exact_extract(pop, st_as_sfc(aoi_h3), "sum"),
                     pop_year = 2025)
    
    if(!exists("h3_afw")){h3_afw <- h3
    } else{h3_afw <- rbind(h3_afw,h3)}
}

write.csv(h3_afw, "1_data/Maps/boundaries/AFW_h3_6.csv",row.names = FALSE)

totalpop <- filter(h3_afw, pop!=0)
write.csv(totalpop,"1_data/Population/ghs-pop_2025_h3_6.csv",row.names = FALSE)

setDT(totalpop, key = c("code", "h3_6"))

rm(admin0, aoi, aoi_h3, h3, h3_afw)
#------------------------------------------------------------------------------#
# degree of urbanisation
#------------------------------------------------------------------------------#

dou <- rast("1_data/Population/GHS-SMOD2_2025_res3arcsec.tif")

#------------------------------------------------------------------------------#
# hazard maps
#------------------------------------------------------------------------------#

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
#------------------------------------------------------------------------------#
# set-up
#------------------------------------------------------------------------------#

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

sources <- as.list(c(
  rep("FAO",3), rep("CHC-CMIP6",2),rep("Fathom 3.0",15), "CCKP-ERA5",
  rep("CHC-CMIP6",4), "ACAG V6.GL.02.02"))

hazards <- list(
  "Agricultural drought - cropland", "Agricultural drought - grassland",
  "Agricultural drought", "Drought - days VPD > 2kPa", 
  "Drought - days VPD > 3kPa",
  "Flood - any (90m)", "Flood - coastal undefended (90m)", 
  "Flood - fluvial undefended (90m)", "Flood - pluvial defended (90m)",
  "Flood - any (450m)", "Flood - coastal undefended (450m)", 
  "Flood - fluvial undefended (450m)", "Flood - pluvial defended (450m)",
  "Flood - any (990m)", "Flood - coastal undefended (990m)", 
  "Flood - fluvial undefended (990m)", "Flood - pluvial defended (990m)",
  "Sea level rise - change in coastal flood depth (90m)",
  "Sea level rise - change in coastal flood depth (450m)",
  "Sea level rise - change in coastal flood depth (990m)",
  "Heat - 5-day mean maximum daily ESI",
  "Heat - days WBGTmax > 28C", "Heat - days WBGTmax > 30C",
  "Heat - days Tmax > 30C", "Heat - days Tmax > 40.6C",
  "Air pollution - annual median PM2.5 (2018-2022)")

climates <- as.list(c(
  rep("Historical (1984-2023)",3), rep("Historical (1983-2016)",2), 
  rep("Present (2010-2030)",12), rep("2080 SSP5 8.5",3),
  "Present (1950-2022)", rep("Historical (1983-2016)",4),
  "Historical (2018-2022)"))

# exposure categories
drought_cat <- c("<30% land affected","30-50% land affected",">50% land affected")
days_cat <- c("0-10 days","10-20 days","20-50 days","50-100 days",
              "100-200 days","200-300 days",">300 days")
flood_cat <- c("No flood","0-15 cm","15-50 cm","50-100 cm",
               "100-150 cm",">150 cm")
slr_cat <- c("No increase","0-15 cm","15-50 cm","50-100 cm",
             "100-150 cm",">150 cm")
esi_cat <- c("<28ºC","28-30ºC","30-32ºC","32-33ºC", "33-34ºC", "34-35ºC", 
             ">35ºC")
air_cat <- c("0-5 µg/m3","5-10 µg/m3", "10-15 µg/m3", "15-25 µg/m3",
             "25-35 µg/m3","35-50 µg/m3", ">50  µg/m3")

cat_labs <- list(
  drought_cat, drought_cat, drought_cat, days_cat, days_cat,
  flood_cat, flood_cat, flood_cat, flood_cat, 
  flood_cat, flood_cat, flood_cat, flood_cat, 
  flood_cat, flood_cat, flood_cat, flood_cat, 
  slr_cat, slr_cat, slr_cat, 
  esi_cat, days_cat, days_cat, days_cat, days_cat, 
  air_cat)

#------------------------------------------------------------------------------#
# extract exposed population by degree of urbanization
#------------------------------------------------------------------------------#

for (n in 1:length(haz_list)){
  
  haz <- haz_list[[n]]
  source <- sources[n]
  hazard <- hazards[n]
  climate <- climates[n]
  print(paste0(source, ", ", hazard, ", ", climate))
  
  # combine dou and hazard exposure categories
  freq <- names(haz)
  for (l in 1:nlyr(haz)){
    dlh <- concats(dou, as.factor(haz[[l]]))
    cats <- cbind(names(haz[[l]]),as.data.frame(levels(dlh))) |>
      rename(freq = 1, value = 2, label = 3) |>
      mutate(label = gsub("^(.)", "\\U\\1", label, perl = TRUE),
             dou = gsub("\\_.*", "", label),
             exp_cat = as.numeric(gsub(".*_", "", label))) |>
      left_join(data.frame(exp_cat = seq(cat_labs[[n]])-1,
                           exp_lab = cat_labs[[n]]))
    if (exists("exp_cats")){exp_cats <- rbind(exp_cats,cats)}
    else{exp_cats <- cats}
    if (exists("dou_haz")){dou_haz <- c(dou_haz,dlh)}
    else{dou_haz <- dlh}
  }
  names(dou_haz) <- freq
  
  # boundaries
  bounds <- read.csv("1_data/Population/ghs-pop_2025_h3_6.csv") |>
    mutate(geom = st_as_sfc(h3_from_strings(h3_6))) |> 
    st_as_sf()
  
  # extract population exposed
  exp_haz <- exact_extract(dou_haz, bounds, 
                           fun = "weighted_frac", 
                           weights = pop, 
                           append_cols = c("code", "h3_6"), 
                           stack_apply = TRUE)
  
  # reshape
  if (nlyr(dou_haz)==1){
    colnames(exp_haz)[3:ncol(exp_haz)] <- paste0(colnames(exp_haz)[3:ncol(exp_haz)],".",names(dou_haz))
  }
  exp_haz <- melt(setDT(exp_haz),
                  value.name = "exp_sh",
                  measure.vars = measure(
                    value = as.integer, freq = as.character,
                    pattern = "weighted_frac_(.[0-9]*).(.*)"
                  )
  )
  
  # add categories and labels
  exp_haz <- exp_haz[as.data.table(exp_cats), on = c("freq","value")][
    exp_sh>0,.(code, h3_6, hazard, source, climate, freq, 
               dou, exp_cat, exp_lab, exp_sh)]
  
  # bind results for each hazard
  if (exists("exp_all")){exp_all <- rbind(exp_all,exp_haz)}
  else {exp_all <- exp_haz}
  
  rm(haz, dlh, dou_haz, exp_cats, cats)
  gc()
}

setDT(exp_all, key = c("code, h3_6"))
exp <- exp_all[totalpop][
  pop>0,.(code, h3_6, pop, pop_year, hazard, source, climate, freq, 
          dou, exp_cat, exp_lab, exp_sh, exp_pop = pop*exp_sh)
]

# save raw estimates
saveRDS(exp, "3_results/exposure/exp_all_h3.rds")

# FIX AGRICULTURAL DROUGHT LABELS - also in 05_exposure.R
# SAVE AS PARQUET