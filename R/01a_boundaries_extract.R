rm() # clear workspace
gc() # free-up unused memory

library(httr)
library(sf)
library(arcpullr)
library(dplyr)

setwd("~/Library/CloudStorage/OneDrive-WBG/West_Africa_Exposure")
# setwd("C:/Users/wb587256/OneDrive - WBG/West_Africa_Exposure")

#------------------------------------------------------------------------------#
# Get boundaries from UN Common Operational Datasets (ArcGIS REST API)
#------------------------------------------------------------------------------#

# Current Version: 10.91
server <- "https://codgis.itos.uga.edu/arcgis/rest/services/"

# List of 22 AFW countries
code_list <- c(
  "BEN", "BFA", "CAF", "CIV", "CMR", "COG", "CPV", "GAB", "GHA",
  "GIN", "GMB", "GNB", "GNQ", "LBR", "MLI", "MRT", "NER",
  "NGA", "SEN", "SLE", "TCD", "TGO"
)

# loop over countries and pull boundary files from UN COD API
for (code in code_list) {
  url <- paste0(server, "COD_External/", code, "_pcode/FeatureServer")

  # find the smallest admin layer
  response <- content(GET(url), "text")

  # alternative url
  if (response == "") {
    url <- paste0(server, "COD_NO_GEOM_CHECK/", code, "_pcode/FeatureServer")
    response <- content(GET(url), "text")
  }

  for (n in 1:5) {
    if (grepl(paste0("Admin", n), response)) {
      layer <- n
      if(code=="CAF"){layer <- 3}
      if(code=="NGA"){layer <- 2}
    }
  }
  # get the smallest admin layer
  url <- paste0(url, "/", layer)
  bounds <- get_spatial_layer(url)

  # save as geopackage for each country
  st_write(bounds,
    paste0("1_data/Maps/boundaries/", code, "_admin", layer, ".gpkg"),
    append = FALSE
  )
}

# fix GAB boundary file - create standard named variables

gab <- st_read("1_data/Maps/boundaries/GAB_admin2.gpkg") |>
  mutate(ADM0_PCODE = "GA",
         ADM0_FR = CNTRY_NAME,
         ADM1_PCODE = HRparent,
         ADM1_FR = ADM1_NAME,
         ADM2_PCODE = HRpcode,
         ADM2_FR = ADM2_NAME)

st_write(gab,"1_data/Maps/boundaries/GAB_admin2.gpkg", append = FALSE)