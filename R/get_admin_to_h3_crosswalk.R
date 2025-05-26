rm(list = ls())  # clear workspace
gc() # free-up unused memory

library(sf)
library(dplyr)
library(h3o)
library(haven)
library(data.table)

setwd("~/Library/CloudStorage/OneDrive-WBG/West_Africa_Exposure")
# setwd("C:/Users/wb587256/OneDrive - WBG/West_Africa_Exposure")

#------------------------------------------------------------------------------#
# AFW boundaries
#------------------------------------------------------------------------------#

# admin boundaries (lowest level available)
afw_adminX <- st_read("1_data/Maps/boundaries/AFW_adminX.gpkg")
h3_res <- 6L

# cover polygons with H3 resolution 6 hexagons
afw_em_h3 <- afw_adminX |>
  mutate(h3 = sfc_to_cells(geom, h3_res, containment = "covers")) |>
  st_drop_geometry() |>
  select(geo_code:adm4_name, h3) |>
  as.data.table()

# unlist h3 addresses
h3 <- afw_em_h3[, list(h3 = unlist(as.character(h3[[1]]))),
                by = list(geo_code, code, adm0_pcode, adm0_name,
                          adm1_pcode, adm1_name, adm2_pcode, adm2_name,
                          adm3_pcode, adm3_name, adm4_pcode, adm4_name)
]

write_dta(select(h3, geo_code, h3), "1_data/Maps/boundaries/AFW_admin_to_h3_6.dta")
write.csv(select(h3, geo_code, h3), "1_data/Maps/boundaries/AFW_admin_to_h3_6.csv")
