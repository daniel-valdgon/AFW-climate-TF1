*----------------------------------------------------------------------------------------
*	Title: Merge BEN's Flood - any (450m) RP20 at the geo_code level to BEN's dataset 
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: Oct 11, 2025
*----------------------------------------------------------------------------------------

/*
* The R-script "$dofiles//51_Example_Extract BEN_Flood - any (450m) - RP20.R" extracts "BEN_Flood - any (450m) - RP20" data from the file "Flood - any (450m)". This is a different way to obtain the same file:

// Import hazard Excel file at the geo_code level 
import excel using "$projectpath\3_results\exposure\Flood - any (450m).xlsx", sheet("AFW_adminX") firstrow clear

// Keep BEN and frequency RP20 observations
keep if code == "BEN"
keep if freq == "RP20"

// Keep the variables we need
keep geo_code exp_cat exp_lab exp_sh exp_pop pop pop_year

// Save file
save "$projectpath\3_results\exposure\BEN_Flood - any (450m) - RP20.dta", replace
*/



** Open BEN's Flood - any (450m) - RP20 data, edit to obtain the >50cm threshold and save
use "$projectpath\3_results\exposure\BEN_Flood - any (450m) - RP20.dta", clear

	// Avoid considering observations for <50cm inundation depth 	
	replace exp_sh = 0 if inlist(exp_cat, 0,1,2) 
	replace exp_pop = 0 if inlist(exp_cat, 0,1,2)	
	
	// Generate share and population exposed for RP20 and >50cm
	egen fl_f20_i50_sh = total(exp_sh), by(geo_code)		
	label var fl_f20_i50_sh "Share of pop exposed to flood RP20 and >50cm inundation depth"
	egen fl_f20_i50_pop = total(exp_pop), by(geo_code)
	label var fl_f20_i50_pop "Population exposed to flood RP20 and >50cm inundation depth"	

	// Keep one observation per geo_code
	bysort geo_code: keep if _n==1

	// Keep the variables we need
	keep geo_code fl_f20_i50_sh fl_f20_i50_pop
	
// Save file
save "$projectpath\3_results\exposure\BEN_Flood - any (450m) - RP20 - p50cm.dta", replace


** Merge BEN's dataset with the just created "BEN_Flood - any (450m) - RP20 - p50cm" file

// Open household survey data with harmonized socioeconomic variables
use "$projectpath\3_results\hhss-exposure\\BEN\\RS_BEN_se_geocode_h3.dta", clear
	
// Merge the flood exposure data
merge m:1 geo_code using "$projectpath\3_results\exposure\BEN_Flood - any (450m) - RP20 - p50cm.dta", nogen keep(match master)	
	

	