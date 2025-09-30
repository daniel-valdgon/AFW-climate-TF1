

* Code to include the village variable in Gabon's data:



// Open raw data with village and household ID variables
datalibweb, country(GAB) year(2017) type(SSARAW) surveyid(GAB_2017_EGEP_v01_M) filename(MENAGE_REC.dta)

// Save in shared folder
save "$data_hhss\\GAB\\SSARAW_GAB_2017_EGEP_v01_M_MENAGE_REC.dta", replace

// Open Excel file with village codes and names
import excel "$data_hhss\\GAB\\EGEP2017_village_codes.xlsx", firstrow clear

// Edit variables
destring Code, replace
rename (Code VillageName) (village region1)

// Save in a temporary file
tempfile vilcode
save `vilcode', replace	

// Open raw data with village and household ID variables
use "$data_hhss\\GAB\\SSARAW_GAB_2017_EGEP_v01_M_MENAGE_REC.dta", clear

// Merge with village code and names
merge m:1 village using `vilcode', nogen keep(match)

// Generate household ID variable to merge with SSAPOV files
gen hid = grappe_cor*100 + menage_cor
tostring hid, replace

// Edit GPS variables
rename (gps_prefill_latitude gps_prefill_longitude) (gps_lat gps_lon)

// Generate empty GPS variables not available
foreach var in loc_id{
	cap gen `var' = .
}
foreach var in loc_type gps_level	gps_mod gps_priv{
	cap gen `var' = ""
}

// Keep the variables we need
keep hid region1 gps_lat gps_lon loc_id loc_type gps_level gps_mod gps_priv 

// Save file
save "$data_hhss\\GAB\\SSARAW_GAB_2017_EGEP_v01_M_MENAGE_REC_mod.dta", replace



use "$data_hhss\\GAB\\SSAPOV_P_GAB.dta", clear
drop region1
merge 1:1 hid using "$data_hhss\\GAB\\SSARAW_GAB_2017_EGEP_v01_M_MENAGE_REC_mod.dta", nogen keep(master match)

* Aquí pego el archivo de Excel y me aseguro de que todos los hogares tengan una village con código y nombre. Después veo como puedo renombrar o usar esa variable para generar region1

// Save file
save 

// Open the H module of SSAPOV


// Merge the file with region1 and GPS variables

use "$data_hhss\\GAB\\SSARAW_GAB_2017_EGEP_v01_M_MENAGE_REC_mod.dta", clear

* Save

* Después de asegurarme de que esto me queda bien, tengo que ver como lo puedo incorporar a los do-files de la base de datos.
use "$data_hhss\\GAB\\SSAPOV_P_GAB.dta", clear

drop region*
merge 1:1 hid using "$data_hhss\\GAB\\SSARAW_GAB_2017_EGEP_v01_M_MENAGE_REC_mod.dta"

*local cty = "GAB"
*local survey = "EGEP"
*local year = "2017"