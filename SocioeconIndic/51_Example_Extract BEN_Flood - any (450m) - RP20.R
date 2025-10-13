#---------------------------------------------------------------------------------------------
#	Title: Example to extract BEN's flood 450m RP20 data from full exposure data file
# Project: Regional study on exposure to shocks in SSA countries 
#	Author: Bernardo Atuesta
# First written: Oct 11, 2025
#---------------------------------------------------------------------------------------------

# Load required libraries
library(sf)
library(haven)
library(readr)
library(dplyr)

setwd("C:/Users/wb384997/OneDrive - WBG/Documents/Climate Change/Regional study on Exposure to shocks/Shared folders/West_Africa_Exposure")

# Load data with exposure indicators at the h3 level
exp_all <- readRDS("./3_results/exposure/exp_all.rds")


# Drop columns that are lists (columns source and climate) to be able to save Stata file later
exp_all <- exp_all[ , !sapply(exp_all, is.list)]

# Filter exposure data (country, hazard and frequecy)
flood <- exp_all %>%
  filter(
    substr(geo_code, 1, 2)=="BJ", 
    hazard == "Flood - any (450m)", 
    freq == "RP20"  
  )

#head(flood)

# Sum exp_sh and exp_pop of all dou categories by geo_code
c_flood <- flood %>%
  group_by(geo_code, exp_cat, exp_lab) %>%
  summarise(
    exp_sh = sum(exp_sh, na.rm = TRUE),
    exp_pop = sum(exp_pop, na.rm = TRUE),
    pop = first(pop),
    pop_year = first(pop_year),
    .groups = "drop"
  )

#head(c_flood)

# Save flood file in Stata
write_dta(c_flood, "./3_results/exposure/BEN_Flood - any (450m) - RP20.dta")
