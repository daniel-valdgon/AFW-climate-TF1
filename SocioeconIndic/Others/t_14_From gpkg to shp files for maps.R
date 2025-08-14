## This script is not used anymore. I keep it in the older versions, just in case.

#---------------------------------------------------------------------------------------------------
#	Title: Reading .gpkg file and exporting .shp shape-files to read in Stata for maps
# Project: Regional study on exposure to shocks in SSA countries 
#	Author: Bernardo Atuesta
# First written: June 23, 2025
#---------------------------------------------------------------------------------------------------

# Install and load necessary R packages
install.packages("sf")       # for reading GPKG and handling spatial data
install.packages("readr")    # for writing CSV files

# Load required libraries
library(sf)
library(readr)
        
# Set working directory path: CHANGE DEPENDING ON THE USER
setwd("C:/Users/wb384997/OneDrive - WBG/Documents/Climate Change/Regional study on Exposure to shocks/Shared folders/West_Africa_Exposure")

# Read the GPKG file
gpkg_data <- st_read("./1_data/Maps/boundaries/AFW_adminX.gpkg")


# Export to SHP (Shapefile)
st_write(gpkg_data, "./1_data/Maps/boundaries/AFW_adminX.shp")
  # Nota: The previous command generated the following files in the same folder as AFW_adminX.gpkg: 
    # AFW_adminX.dbf, 
    # AFW_adminX.prj, 
    # AFW_adminX.shp, 
    # AFW_adminX.shx

# Do the same for the files AFW_admin2 and AFW_admin1
gpkg_data <- st_read("./1_data/Maps/boundaries/AFW_admin2.gpkg")
st_write(gpkg_data, "./1_data/Maps/boundaries/AFW_admin2.shp") 

gpkg_data <- st_read("./1_data/Maps/boundaries/AFW_admin1.gpkg")
st_write(gpkg_data, "./1_data/Maps/boundaries/AFW_admin1.shp") 


## Exploring the am24_admin0.gpkg datafile

# Save am24_admin0.gpkg in an object called am24_admin0.
am24_admin0 <- st_read("./1_data/Maps/boundaries/am24_admin0.gpkg")
# View the first few rows
head(am24_admin0)

# Create a new data frame with only the first 10 rows and 4 columns of am24_admin0
am24_admin0_subset <- am24_admin0[10, 1:4]

# Open it in the Viewer pane
View(am24_admin0_subset)


# View the full content of the first row and the column geom
as.character(am24_admin0[1, "geom"])



