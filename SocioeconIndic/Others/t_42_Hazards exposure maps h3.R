#------------------------------------------------------------------------
#	Title: Hazards exposure maps at the h3 level
# Project: Regional study on exposure to shocks in SSA countries 
#	Author: Bernardo Atuesta
# First written: Aug 13, 2025
#------------------------------------------------------------------------

# Install required packages
#install.packages("leaflet")
#install.packages("h3")

# Load required libraries
library(haven)
library(tidyverse)
library(leaflet)
library(sf)
library(haven)
library(h3jsr)
library(readr)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
#library(h3)

# install.packages("rnaturalearth")       # if needed
# install.packages("rnaturalearthdata")   # if needed
library(rnaturalearth)


setwd("C:/Users/wb384997/OneDrive - WBG/Documents/Climate Change/Regional study on Exposure to shocks/Shared folders/West_Africa_Exposure/3_results/exposure")


# Get country polygons from Natural Earth (medium resolution)
africa <- rnaturalearth::ne_countries(scale = "medium", continent = "Africa", returnclass = "sf") %>%
  st_make_valid()

# West Africa (AFW-style list)
afw_iso3 <- c("BEN","BFA","CIV","CPV","GMB","GHA","GIN","GNB",
              "LBR","MLI","MRT","NER","NGA","SEN","SLE","TGO", 
              "TCD","CMR","CAF","COG","GNQ","GAB")


###############
### Drought ###
###############

# Load the dataset
drought <- read_dta("Agricultural drought - AEP2p5_h3_c.dta")

# Convert H3 to polygons
drought_sf <- drought %>%
  mutate(geometry = cell_to_polygon(h3_6)) %>%
  st_as_sf() # Convert to sf object

sel_countries <- africa %>%
  filter(iso_a3 %in% c(afw_iso3)) %>%
  st_transform(st_crs(drought_sf))   # match CRS


# Clip H3 cells to the selected countries area
# Using a union speeds up spatial filtering
region_union <- st_union(sel_countries)
drought_sel  <- st_filter(drought_sf, region_union)

# Compute bounding box for a tight map extent
bb <- st_bbox(sel_countries)

# --- Map ---
ggplot() +
  geom_sf(data = drought_sel, aes(fill = dr_f2p5_i30_sh_h3), color = NA) +
  # Thicker country borders in black
  geom_sf(data = sel_countries, fill = NA, color = "black", linewidth = 0.7) +
  scale_fill_viridis_c(option = "plasma", na.value = "grey90") +
  labs(
    fill = "Share of pop exposed (%)",
    title = "Agricultural Drought Exposure (AEP2.5, >30% Land Affected)",
    subtitle = "H3 Resolution 6 - AFW Countries"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    axis.text = element_blank(),       # Remove axis numbers
    axis.ticks = element_blank(),      # Remove axis ticks
    axis.title = element_blank(),      # Remove axis titles
    panel.grid = element_blank(),      # Remove grid lines
    legend.position = "bottom",        # Place legend below map
    legend.direction = "horizontal",   # Horizontal legend
    legend.box.margin = margin(t = -10) # Slightly pull legend closer to map
  ) 


# Save as PNG
ggsave("./Figures/Drought_map_h3.png", width = 8, height = 6, dpi = 300)



#############
### Flood ###
#############

# Load the dataset
flood <- read_dta("Flood - any (90m) - RP100_h3_c.dta")

# Convert H3 to polygons
flood_sf <- flood %>%
  mutate(geometry = cell_to_polygon(h3_6)) %>%
  st_as_sf() # Convert to sf object


sel_countries <- africa %>%
  filter(iso_a3 %in% c(afw_iso3)) %>%
  st_transform(st_crs(flood_sf))   # match CRS


# Clip H3 cells to the selected countries area
# Using a union speeds up spatial filtering
region_union <- st_union(sel_countries)
flood_sel  <- st_filter(flood_sf, region_union)

# Compute bounding box for a tight map extent
bb <- st_bbox(sel_countries)

# Generate map
ggplot() +
  geom_sf(data = flood_sel, aes(fill = fl_f100_i50_sh_h3), color = NA) +
  # Thicker country borders in black
  geom_sf(data = sel_countries, fill = NA, color = "black", linewidth = 0.7) +
  scale_fill_distiller(
    palette = "Purples",         # Use palette from ColorBrewer
    direction = 1,            # Keep the light-to-dark direction
    na.value = "grey90"       # Color for NA values
  ) +
  labs(
    fill = "Share of pop exposed (%)",
    title = "Flood Exposure (RP100, >50cm inundation depth)",
    subtitle = "H3 Resolution 6 - AFW Countries"
  ) +
  theme_minimal(base_size = 10) +  
  theme(
    axis.text = element_blank(),       
    axis.ticks = element_blank(),      
    axis.title = element_blank(),      
    panel.grid = element_blank(),      
    legend.position = "bottom",        
    legend.direction = "horizontal",   
    legend.box.margin = margin(t = -10)
  )


# Save as PNG
ggsave("./Figures/Flood_map_h3.png", width = 8, height = 6, dpi = 300)


############
### Heat ###
############

# Load the dataset
heat <- read_dta("Heat - 5-day mean maximum daily ESI - RP100_h3_c.dta")

# Convert H3 to polygons
heat_sf <- heat %>%
  mutate(geometry = cell_to_polygon(h3_6)) %>%
  st_as_sf() # Convert to sf object

sel_countries <- africa %>%
  filter(iso_a3 %in% c(afw_iso3)) %>%
  st_transform(st_crs(heat_sf))   # match CRS


# Clip H3 cells to the selected countries area
# Using a union speeds up spatial filtering
region_union <- st_union(sel_countries)
heat_sel  <- st_filter(heat_sf, region_union)

# Compute bounding box for a tight map extent
bb <- st_bbox(sel_countries)

# Generate map
ggplot() +
  geom_sf(data = heat_sel, aes(fill = he_f100_i33_sh_h3), color = NA) +
  # Thicker country borders in black
  geom_sf(data = sel_countries, fill = NA, color = "black", linewidth = 0.7) +
  scale_fill_distiller(
    palette = "Reds",         # Use palette from ColorBrewer
    direction = 1,            # Keep the light-to-dark direction
    na.value = "grey90"       # Color for NA values
  ) +
  labs(
    fill = "Share of pop exposed (%)",
    title = "Heat Exposure (RP100, >33°C)",
    subtitle = "H3 Resolution 6 - AFW Countries"
  ) +
  theme_minimal(base_size = 10) +  
  theme(
    axis.text = element_blank(),       # Remove axis numbers
    axis.ticks = element_blank(),      # Remove axis ticks
    axis.title = element_blank(),      # Remove axis titles
    panel.grid = element_blank(),      # Remove grid lines
    legend.position = "bottom",        # Place legend below map
    legend.direction = "horizontal",   # Horizontal legend
    legend.box.margin = margin(t = -10) # Slightly pull legend closer to map
  )


# Save as PNG
ggsave("./Figures/Heat_map_h3.png", width = 8, height = 6, dpi = 300)

#####################
### Air Pollution ###
#####################

# Load the dataset
airpollution <- read_dta("Air pollution - annual median PM2.5 (2018-2022)_h3_c.dta")

# Convert H3 to polygons
airpollution_sf <- airpollution %>%
  mutate(geometry = cell_to_polygon(h3_6)) %>%
  st_as_sf() # Convert to sf object

sel_countries <- africa %>%
  filter(iso_a3 %in% c(afw_iso3)) %>%
  st_transform(st_crs(airpollution_sf))   # match CRS


# Clip H3 cells to the selected countries area
# Using a union speeds up spatial filtering
region_union <- st_union(sel_countries)
airpollution_sel  <- st_filter(airpollution_sf, region_union)

# Compute bounding box for a tight map extent
bb <- st_bbox(sel_countries)

# Generate map
ggplot() +
  geom_sf(data = airpollution_sel, aes(fill = po_f50_i35_sh_h3), color = NA) +
  # Thicker country borders in black
  geom_sf(data = sel_countries, fill = NA, color = "black", linewidth = 0.7) +
  scale_fill_distiller(
    palette = "YlOrBr",         # Use palette from ColorBrewer
    direction = 1,            # Keep the light-to-dark direction
    na.value = "grey90"       # Color for NA values
  ) +
  labs(
    fill = "Share of pop exposed (%)",
    title = "Air Pollution Exposure (P50, 35 µg/m3)",
    subtitle = "H3 Resolution 6 - AFW Countries"
  ) +
  theme_minimal(base_size = 10) +  
  theme(
    axis.text = element_blank(),       # Remove axis numbers
    axis.ticks = element_blank(),      # Remove axis ticks
    axis.title = element_blank(),      # Remove axis titles
    panel.grid = element_blank(),      # Remove grid lines
    legend.position = "bottom",        # Place legend below map
    legend.direction = "horizontal",   # Horizontal legend
    legend.box.margin = margin(t = -10) # Slightly pull legend closer to map
  )


# Save as PNG
ggsave("./Figures/AirPollution_map_h3.png", width = 8, height = 6, dpi = 300)


######################
### Sea Level Rise ###
######################

# Load the dataset
sea <- read_dta("Sea level rise - change in coastal flood depth (90m)_h3_c.dta")

# Convert H3 to polygons
sea_sf <- sea %>%
  mutate(geometry = cell_to_polygon(h3_6)) %>%
  st_as_sf() # Convert to sf object

sel_countries <- africa %>%
  filter(iso_a3 %in% c(afw_iso3)) %>%
  st_transform(st_crs(sea_sf))   # match CRS


# Clip H3 cells to the selected countries area
# Using a union speeds up spatial filtering
region_union <- st_union(sel_countries)
sea_sel  <- st_filter(sea_sf, region_union)

# Compute bounding box for a tight map extent
bb <- st_bbox(sel_countries)

# Generate map
ggplot() +
  geom_sf(data = sea_sel, aes(fill = se_f100_i0_sh_h3), color = NA) +
  # Thicker country borders in black
  geom_sf(data = sel_countries, fill = NA, color = "black", linewidth = 0.7) +
  scale_fill_distiller(
    palette = "Blues",         # Use palette from ColorBrewer
    direction = 1,            # Keep the light-to-dark direction
    na.value = "grey90"       # Color for NA values
  ) +
  labs(
    fill = "Share of pop exposed (%)",
    title = "Sea Level Rise (RP100, >0cm)",
    subtitle = "H3 Resolution 6 - AFW Countries"
  ) +
  theme_minimal(base_size = 10) +  
  theme(
    axis.text = element_blank(),       # Remove axis numbers
    axis.ticks = element_blank(),      # Remove axis ticks
    axis.title = element_blank(),      # Remove axis titles
    panel.grid = element_blank(),      # Remove grid lines
    legend.position = "bottom",        # Place legend below map
    legend.direction = "horizontal",   # Horizontal legend
    legend.box.margin = margin(t = -10) # Slightly pull legend closer to map
  )


# Save as PNG
ggsave("./Figures/SeaLevelRise_map_h3.png", width = 8, height = 6, dpi = 300)

