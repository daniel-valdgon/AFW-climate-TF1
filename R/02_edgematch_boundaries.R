rm() # clear workspace
gc() # free-up unused memory

library(sf)
library(dplyr)
library(lwgeom)

setwd("~/Library/CloudStorage/OneDrive-WBG/West_Africa_Exposure")
# setwd("C:/Users/wb587256/OneDrive - WBG/West_Africa_Exposure")

#------------------------------------------------------------------------------#
# WB official Admin-0 boundaries
#------------------------------------------------------------------------------#

# List of 22 AFW countries
code_list <- c(
  "BEN", "BFA", "CAF", "CIV", "CMR", "COG", "CPV", "GAB", "GHA",
  "GIN", "GMB", "GNB", "GNQ", "LBR", "MLI", "MRT", "NER",
  "NGA", "SEN", "SLE", "TCD", "TGO"
)

wb_admin0 <- st_read("1_data/Maps/boundaries/am24_admin0.gpkg")

afw_admin0 <- filter(wb_admin0, code %in% code_list)

st_write(afw_admin0,"1_data/Maps/boundaries/AFW_admin0.gpkg", append = FALSE)

#------------------------------------------------------------------------------#
# Edge match subnational boundaries to admin-0 - Voronoi method
#------------------------------------------------------------------------------#

sf_use_s2(FALSE)
afw_em <- data.frame()

# loop over countries
for (i in code_list){
  
  fname <- list.files("1_data/Maps/boundaries/", i , full.names = TRUE)
  sample <- st_read(fname) |> select(OBJECTID) |> st_make_valid()
  labels <- st_read(fname) |>
    st_drop_geometry() |>
    mutate(code = i) |> 
    select(where(~!all(is.na(.x)))) |>
    select(code, OBJECTID, contains("ADM"))

    # target admin0 polygon
    target <- filter(afw_admin0, code==i) |> select(geom)
    
    # make lines from sample polygons
    samp_union <- st_union(st_make_valid(sample))
    outline <- st_cast(samp_union, "MULTILINESTRING")
    lines <- st_intersection(sample, outline) |> 
      st_collection_extract("LINESTRING") |> 
      st_make_valid()
    
    # make points from lines
    points <- st_segmentize(lines,dfMaxLength = units::set_units(100,m)) %>%
      st_cast("MULTIPOINT") %>% st_cast("POINT") %>% 
      st_transform(3395) %>%
      st_snap_to_grid(units::set_units(10,m)) %>% # snap to 10m grid
      st_transform(4326) %>% 
      distinct()
    
    # make voronoi polygons from points
    voron <- st_collection_extract(st_voronoi(do.call(c,st_geometry(points)))) %>% 
      st_set_crs(st_crs(points))
    
    # combine voronoi and subnat polygons, intersect with admin-0, keep polygons
    em <- mutate(points,geom = voron[unlist(st_intersects(points,voron))]) |>
      st_make_valid() |> group_by(OBJECTID) |> summarize(geom=st_union(geom)) |>
      st_difference(samp_union) |> rbind(sample) |>
      group_by(OBJECTID) |> summarize(geom=st_union(geom)) |>
      st_intersection(target) |> rowwise() |> 
      mutate(geom = st_combine(st_collection_extract(geom, "POLYGON"))) |>
      left_join(labels)
    
    plot(target, main = i)
    plot(em[1], main = i)
    
    # bind
    if (nrow(afw_em)==0){afw_em <- em}
    else{afw_em <- bind_rows(afw_em,em)}
}

#------------------------------------------------------------------------------#
# Clean up
#------------------------------------------------------------------------------#

# check valid
any(!st_is_valid(afw_em)) # All valid if FALSE

# standardize names
afw_em_clean <- afw_em |>
  mutate(adm0_name  = if_else(!is.na(ADM0_EN),ADM0_EN,
                            if_else(!is.na(ADM0_FR),ADM0_FR,
                                    if_else(!is.na(ADM0_PT),ADM0_PT,NA))),
         adm1_name  = if_else(!is.na(ADM1_EN),ADM1_EN,
                            if_else(!is.na(ADM1_FR),ADM1_FR,
                                    if_else(!is.na(ADM1_PT),ADM1_PT,NA))),
         adm2_name  = if_else(!is.na(ADM2_EN),ADM2_EN,
                              if_else(!is.na(ADM2_FR),ADM2_FR,
                                      if_else(!is.na(ADM2_PT),ADM2_PT,NA))),
         adm3_name  = if_else(!is.na(ADM3_EN),ADM3_EN,
                              if_else(!is.na(ADM3_FR),ADM3_FR,NA)),
         adm4_name  = ADM4_EN) |>
  rename(adm0_pcode = ADM0_PCODE,
         adm1_pcode = ADM1_PCODE,
         adm2_pcode = ADM2_PCODE,
         adm3_pcode = ADM3_PCODE,
         adm4_pcode = ADM4_PCODE) |>
  mutate(geo_code = if_else(!is.na(adm4_pcode),adm4_pcode,
                            if_else(!is.na(adm3_pcode),adm3_pcode,
                                    if_else(!is.na(adm2_pcode),adm2_pcode,
                                            NA)))) |>
  select(geo_code, code, adm0_pcode, adm0_name, adm1_pcode, adm1_name,
         adm2_pcode, adm2_name, adm3_pcode, adm3_name, adm4_pcode, adm4_name)
         
st_write(afw_em_clean,"1_data/Maps/boundaries/AFW_adminX.gpkg", append = FALSE)

# ADMIN 2
afw_em_admin2 <- group_by(afw_em_clean, code, adm0_pcode, adm0_name, 
                          adm1_pcode, adm1_name,adm2_pcode, adm2_name) |>
  summarise(geom=st_union(geom)) |>
  mutate(geo_code = adm2_pcode) |>
  select(geo_code, code, adm0_pcode, adm0_name, adm1_pcode, adm1_name,
         adm2_pcode, adm2_name)
  
st_write(afw_em_admin2,"1_data/Maps/boundaries/AFW_admin2.gpkg", append = FALSE)

# ADMIN 1
afw_em_admin1 <- group_by(afw_em_clean, code, adm0_pcode, adm0_name, 
                          adm1_pcode, adm1_name) |>
  summarise(geom=st_union(geom)) |>
  mutate(geo_code = adm1_pcode) |>
  select(geo_code, code, adm0_pcode, adm0_name, adm1_pcode)

st_write(afw_em_admin1,"1_data/Maps/boundaries/AFW_admin1.gpkg", append = FALSE)

# #check coverage
# library(leaflet)
# 
# map <- select(afw_em_clean,code,geo_code)
# 
# leaflet(map) %>%
#   addProviderTiles("CartoDB.Positron") %>%
#   addPolygons(color = "green",
#               popup = paste("Country: ", map$code, "<br>",
#                             "Region: ", map$geo_code, "<br>"))
# 
# length(unique(afw_em_clean$geo_code))
# length(unique(afw_em_clean$code))