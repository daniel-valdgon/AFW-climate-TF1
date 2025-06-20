#---------------------------------------------------------------------------------------------------
#	Title: Merging socioeconomic indicators by geocode with climate exposure data
# Project: Regional study on exposure to shocks in SSA countries 
#	Author: Bernardo Atuesta
# First written: June 7, 2025
#---------------------------------------------------------------------------------------------------

# Load required libraries
library(dplyr)
library(haven)  # For Stata import 
library(readr)  # For general data handling
library(sf)

# Set working directory path: CHANGE DEPENDING ON THE USER
setwd("C:/Users/wb384997/OneDrive - WBG/Documents/Climate Change/Regional study on Exposure to shocks/Shared folders/West_Africa_Exposure")

# Load data with socioeconomic indicators at the adminX level
seind <- read_dta("./1_data/Household_survey/RS_All_se_adminX.dta")

# Load data with exposure indicators at the adminX level
exp_all <- readRDS("./3_results/exposure/exp_all.rds")

# Merge (many-to-one) with the seind object
seind_exp_all <- exp_all %>%
  left_join(seind, by = "geo_code")    
  # There are several observations that do not merge because they correspond to geo_codes not present in the household survey

saveRDS(seind_exp_all, file = "./3_results/SocioeconIndic/seind_exp_all.rds")


## instructions on how to use R to create a Stata file for each country and merge it at the country level (example for BFA):

# Load data with socioeconomic indicators at the adminX level
# Example to do it at the country level for BFA:
  #bfa_seind <- read_dta("./1_data/Household_survey/BFA/RS_BFA_se_adminX.dta")

# Load data with exposure indicators at the adminX level
  #exp_all <- readRDS("./3_results/exposure/exp_all.rds")

# Filter observations where geo_code starts with "BF" (which correspond to BFA)
  #exp_bf <- exp_all %>%
  #filter(startsWith(geo_code, "BF"))

# Columns of type list are not supported by write_dta, so we need to discover the columns that are lists:
  #which(sapply(exp_bf, is.list))
  
# Drop columns that are lists (columns source and climate)
  #exp_bf_clean <- exp_bf[ , !sapply(exp_bf, is.list)]

# Export data to Stata and follow instructions in dofile "" to merge it with socioeconomic indicators:  
  # write_dta(exp_bf_clean, "./1_data/Household_survey/BFA/exp_BFA.dta")



  