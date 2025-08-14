
** Test: Trying to create h3 variables in the survey dataset using BEN as an example

use "$data_hhss\\BEN\\BEN_2021_EHCVM_V01_M_V01_A_GMD_LOC.dta", clear

python:
import pandas as pd
import h3
import sfi

# Get data from Stata
gps_lat = sfi.Data.get(var='gps_lat')
gps_lon = sfi.Data.get(var='gps_lon')

# Generate h3 codes
h3_6 = [h3.geo_to_h3(lat, lon, 6) for lat, lon in zip(gps_lat, gps_lon)]
h3_7 = [h3.geo_to_h3(lat, lon, 7) for lat, lon in zip(gps_lat, gps_lon)]

# Return to Stata
sfi.Data.addVarStr('h3_6', 15)
sfi.Data.addVarStr('h3_7', 15)
for i in range(len(h3_6)):
    sfi.Data.store(i, 'h3_6', h3_6[i])
    sfi.Data.store(i, 'h3_7', h3_7[i])
end


* This did not work, but I found the way to do it properly in R (see R-script "32_Adding h3 variables.R").


