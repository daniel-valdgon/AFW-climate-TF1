#---------------------------------------------------------------------------------------------
#	Title: Generate exposure data files at the h3_6 level to merge with harmonized survey data
# Project: Regional study on exposure to shocks in SSA countries 
#	Author: Bernardo Atuesta
# First written: July 15, 2025
#---------------------------------------------------------------------------------------------


# Load required libraries
library(sf)
library(haven)
library(readr)
library(dplyr)

setwd("C:/Users/wb384997/OneDrive - WBG/Documents/Climate Change/Regional study on Exposure to shocks/Shared folders/West_Africa_Exposure")

# Load data with exposure indicators at the h3 level
exp_all_h3 <- readRDS("./3_results/exposure/exp_all_h3.rds")

head(exp_all_h3)

# Drop columns that are lists (columns source and climate) to be able to save Stata file later
exp_all_h3 <- exp_all_h3[ , !sapply(exp_all_h3, is.list)]

###############
### Drought ###
###############

# Filter exposure data to obtain only drought data
drought <- exp_all_h3 %>%
  filter(
    hazard == "Agricultural drought",
    freq == "AEP2.5"
  )

head(drought)


# Save drought file in Stata
write_dta(drought, "./3_results/exposure/Agricultural drought - AEP2p5_h3.dta")


#############
### Flood ###
#############

# Filter exposure data to obtain only flood data
flood <- exp_all_h3 %>%
  filter(
    hazard == "Flood - any (90m)",
    freq == "RP100"
  )

head(flood)

# Save flood file in Stata
write_dta(flood, "./3_results/exposure/Flood - any (90m) - RP100_h3.dta")


############
### Heat ###
############

# Filter exposure data to obtain only heat data
heat <- exp_all_h3 %>%
  filter(
    hazard == "Heat - 5-day mean maximum daily ESI",
    freq == "RP100"
  )

head(heat)

# Save flood file in Stata
write_dta(heat, "./3_results/exposure/Heat - 5-day mean maximum daily ESI - RP100_h3.dta")


#####################
### Air Pollution ###
#####################

# Filter exposure data to obtain only heat data
air <- exp_all_h3 %>%
  filter(
    hazard == "Air pollution - annual median PM2.5 (2018-2022)",
    # No need to keep a level of frequency because we have only one: P50 (2018-2022)
  )

head(air)

# Save flood file in Stata
write_dta(air, "./3_results/exposure/Air pollution - annual median PM2.5 (2018-2022)_h3.dta")



######################
### Sea Level Rise ###
######################

# Filter exposure data to obtain only heat data
sea <- exp_all_h3 %>%
  filter(
    hazard == "Sea level rise - change in coastal flood depth (90m)",
    freq == "RP100"
  )

head(sea)

# Save flood file in Stata
write_dta(sea, "./3_results/exposure/Sea level rise - change in coastal flood depth (90m)_h3.dta")


