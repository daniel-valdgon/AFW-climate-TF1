#------------------------------------------------------------------------
#	Title: Hazards exposure maps at the h3 level
# Project: Regional study on exposure to shocks in SSA countries 
#	Author: Bernardo Atuesta
# First written: Aug 13, 2025
#------------------------------------------------------------------------

# Install required packages
#install.packages("leaflet")
install.packages("h3")

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
library(h3)


setwd("C:/Users/wb384997/OneDrive - WBG/Documents/Climate Change/Regional study on Exposure to shocks/Shared folders/West_Africa_Exposure/3_results/exposure")

###############
### Drought ###
###############

# Load the dataset
drought <- read_dta("Agricultural drought - AEP2p5_h3_c.dta")

# Convert H3 to polygons
drought_sf <- drought %>%
  mutate(geometry = cell_to_polygon(h3_6)) %>%
  st_as_sf() # Convert to sf object


# Generate map
ggplot(drought_sf) +
  geom_sf(aes(fill = dr_f2p5_i30_sh_h3), color = NA) +
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


# Generate map
ggplot(flood_sf) +
  geom_sf(aes(fill = fl_f100_i50_sh_h3), color = NA) +
  scale_fill_viridis_c(option = "cividis", na.value = "grey90") +
  labs(
    fill = "Share of pop exposed (%)",
    title = "Flood Exposure (RP100, >50cm inundation depth)",
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


# Generate map
ggplot(heat_sf) +
  geom_sf(aes(fill = he_f100_i33_sh_h3), color = NA) +
  scale_fill_viridis_c(option = "inferno", na.value = "grey90") +
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


# Generate map
ggplot(airpollution_sf) +
  geom_sf(aes(fill = po_f50_i35_sh_h3), color = NA) +
  scale_fill_viridis_c(option = "magma", na.value = "grey90") +
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


# Generate map
ggplot(sea_sf) +
  geom_sf(aes(fill = se_f100_i0_sh_h3), color = NA) +
  scale_fill_viridis_c(option = "mako", na.value = "grey90") +
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

