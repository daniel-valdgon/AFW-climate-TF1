rm(list = ls()) # empty workspace
gc() # free-up unused memory

# load packages
library(sf)
library(terra)
library(exactextractr)
library(data.table)
library(dplyr)

# setwd("~/Library/CloudStorage/OneDrive-WBG/West_Africa_Exposure")
setwd("C:/Users/wb587256/OneDrive - WBG/West_Africa_Exposure")

#------------------------------------------------------------------------------#
# boundaries
#------------------------------------------------------------------------------#

bounds <- st_read("1_data/Maps/boundaries/AFW_adminX.gpkg")

#------------------------------------------------------------------------------#
# population
#------------------------------------------------------------------------------#

pop <- rast("1_data/Population/GHS-POP_2025_3arcsec.tif")

totalpop <- exact_extract(pop, bounds, fun = "sum",
                          append_cols = c("geo_code")) |>
  rename(pop = sum) |> mutate(pop_year = 2025)

write.csv(totalpop,"1_data/Population/ghs-pop_2025_admin2.csv",row.names = FALSE)

setDT(totalpop, key = "geo_code")

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
  bounds <- st_read("1_data/Maps/boundaries/AFW_adminX.gpkg")
  
  # extract population exposed
  exp_haz <- exact_extract(dou_haz, bounds, 
                           fun = "weighted_frac", 
                           weights = pop, 
                           append_cols = c("geo_code"), 
                           stack_apply = TRUE)
  
  # reshape
  if (nlyr(dou_haz)==1){
    colnames(exp_haz)[2:ncol(exp_haz)] <- paste0(colnames(exp_haz)[2:ncol(exp_haz)],".",names(dou_haz))
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
    exp_sh>0,.(geo_code, hazard, source, climate, freq, 
               dou, exp_cat, exp_lab, exp_sh)]
  
  # bind results for each hazard
  if (exists("exp_all")){exp_all <- rbind(exp_all,exp_haz)}
  else {exp_all <- exp_haz}
  
  rm(haz, dlh, dou_haz, exp_cats, cats)
  gc()
}

setDT(exp_all, key = c("geo_code"))
exp <- exp_all[totalpop][
  pop>0,.(geo_code, pop, pop_year, hazard, source, climate, freq, 
          dou, exp_cat, exp_lab, exp_sh, exp_pop = pop*exp_sh)
]

# save raw estimates
saveRDS(exp, "3_results/exposure/exp_all.rds")

#------------------------------------------------------------------------------#
# summarise exposed population
#------------------------------------------------------------------------------#
library(openxlsx)

exp <- readRDS("3_results/exposure/exp_all.rds")
bounds <- st_read("1_data/Maps/boundaries/AFW_adminX.gpkg")

for (h in unique(exp$hazard)){

# adminX DOU level
exp_admX_dou <- filter(exp, hazard==h) |>
  left_join(st_drop_geometry(bounds)) |>
  group_by(geo_code, hazard, climate, freq, dou) |>
  mutate(pop = sum(exp_pop),exp_sh = exp_pop/pop) |> ungroup() |>
  select(code:adm4_name, geo_code, dou, pop, pop_year, 
         hazard:freq, exp_cat:exp_pop) |>
  arrange(geo_code, hazard, climate, freq, dou, exp_cat) 

# adminX level
exp_admX <- group_by(exp_admX_dou,pick(code:adm4_name, geo_code, pop_year:exp_lab)) |>
  summarise(across(c(pop,exp_pop), ~sum(.x, na.rm = TRUE))) |>
  group_by(geo_code, hazard, climate, freq) |>
  mutate(pop = sum(exp_pop),exp_sh = exp_pop/pop) |> ungroup() |>
  select(code:adm4_name, geo_code, pop, pop_year, hazard:exp_lab, exp_sh, exp_pop) |>
  arrange(geo_code, hazard, climate, freq, exp_cat) 

# admin2 DOU level
exp_adm2_dou <- group_by(exp_admX_dou,pick(code:adm2_name, dou, pop_year:exp_lab)) |>
  summarise(across(c(pop,exp_pop), ~sum(.x, na.rm = TRUE))) |>
  group_by(adm2_pcode, hazard, climate, freq, dou) |>
  mutate(pop = sum(exp_pop),exp_sh = exp_pop/pop) |> ungroup() |>
  select(code:adm2_name, dou, pop, pop_year, hazard:exp_lab, exp_sh, exp_pop) |>
  arrange(adm2_pcode, hazard, climate, freq, dou, exp_cat) 

# admin2 level
exp_adm2 <- group_by(exp_admX_dou,pick(code:adm2_name, pop_year:exp_lab)) |>
  summarise(across(c(pop,exp_pop), ~sum(.x, na.rm = TRUE))) |>
  group_by(adm2_pcode, hazard, climate, freq) |>
  mutate(pop = sum(exp_pop),exp_sh = exp_pop/pop) |> ungroup() |>
  select(code:adm2_name, pop, pop_year, hazard:exp_lab, exp_sh, exp_pop) |>
  arrange(adm2_pcode, hazard, climate, freq, exp_cat) 

# admin1 dou level
exp_adm1_dou <- group_by(exp_admX_dou,pick(code:adm1_name, dou, pop_year:exp_lab)) |>
  summarise(across(c(pop,exp_pop), ~sum(.x, na.rm = TRUE))) |>
  group_by(adm1_pcode, hazard, climate, freq, dou) |>
  mutate(pop = sum(exp_pop),exp_sh = exp_pop/pop) |> ungroup() |>
  select(code:adm1_name, dou, pop, pop_year, hazard:exp_lab, exp_sh, exp_pop) |>
  arrange(adm1_pcode, hazard, climate, freq, dou, exp_cat) 

# admin1 level
exp_adm1 <- group_by(exp_admX_dou,pick(code:adm1_name, pop_year:exp_lab)) |>
  summarise(across(c(pop,exp_pop), ~sum(.x, na.rm = TRUE))) |>
  group_by(adm1_pcode, hazard, climate, freq) |>
  mutate(pop = sum(exp_pop),exp_sh = exp_pop/pop) |> ungroup() |>
  select(code:adm1_name, pop, pop_year, hazard:exp_lab, exp_sh, exp_pop) |>
  arrange(adm1_pcode, hazard, climate, freq, exp_cat)

# admin0 dou level
exp_adm0_dou <- group_by(exp_admX_dou,pick(code:adm0_name, dou, pop_year:exp_lab)) |>
  summarise(across(c(pop,exp_pop), ~sum(.x, na.rm = TRUE))) |>
  group_by(adm0_pcode, hazard, climate, freq, dou) |>
  mutate(pop = sum(exp_pop),exp_sh = exp_pop/pop) |> ungroup() |>
  select(code:adm0_name, dou, pop, pop_year, hazard:exp_lab, exp_sh, exp_pop) |>
  arrange(adm0_pcode, hazard, climate, freq, dou, exp_cat)

# admin0 level
exp_adm0 <- group_by(exp_admX_dou,pick(code:adm0_name, pop_year:exp_lab)) |>
  summarise(across(c(pop,exp_pop), ~sum(.x, na.rm = TRUE))) |>
  group_by(adm0_pcode, hazard, climate, freq) |>
  mutate(pop = sum(exp_pop),exp_sh = exp_pop/pop) |> ungroup() |>
  select(code:adm0_name, pop, pop_year, hazard:exp_lab, exp_sh, exp_pop) |>
  arrange(adm0_pcode, hazard, climate, freq, exp_cat)

# save to excel
library(openxlsx)
xl_lst <- list(
  "AFW_admin0" = exp_adm0, "AFW_admin0_DoU" = exp_adm0_dou,
  "AFW_admin1" = exp_adm1, "AFW_admin1_DoU" = exp_adm1_dou,
  "AFW_admin2" = exp_adm2, "AFW_admin2_DoU" = exp_adm2_dou,
  "AFW_adminX" = exp_admX, "AFW_adminX_DoU" = exp_admX_dou
)
write.xlsx(xl_lst, paste0("3_results/exposure/",h,".xlsx"))

}