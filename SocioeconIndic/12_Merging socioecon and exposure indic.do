*---------------------------------------------------------------------------------------------------
*	Title: Calculating socioeconomic indicators by geocode and merge with exposure data
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: June 5, 2025
*---------------------------------------------------------------------------------------------------


// Open loop for countries
foreach cty in $countries{

	// Open initial data with main harmonized variables
	use "$data_hhss\\`cty'\\RS_`cty'_se.dta", clear

	// Save lists of variables in two locals (one for continuous variables and one for dummy variables)
	local varsc "dpcexp_pov_2017 dpcexp_pov_2021 pcfoodexp educyrs pcremit"
	local varsp "p_2_15 p_3_65 p_6_85 p_3 p_4_2 p_8_3 educat5_* ageg_* male female disability lstatus_* indcat4_* loweduc yrsschol_hh scholatt water8_* noimpwater nobaswater noelec lowq_mat scookfl notimprsanit cellphone car fridge noassets accinter hh_remit bankacc mobbankacc nosoctrss"

	// Multiply the dummy variables by 100 to obtain results in percentages
	foreach v of varlist `varsp'{
		replace `v' = 100*`v'
	} 

	// Generate a variable for National statistics
	gen region0 = "0 - `cty'"

	** Countries with information up to admin2: BEN CIV CPV GHA GMB GNB LBR NER NGA SLE TGO
	** Countries with information up to admin3: BFA CAF CMR GIN MLI MRT SEN TCD
	// Not al countries have non-missing region3, so this identifies the ones that do and considers it for the next loop
	tab region3
	local r3=r(r)

	if `r3' == 0 | "`cty'" == "GIN" | "`cty'" == "MRT" | "`cty'" == "SEN" | "`cty'" == "TCD"{
		local ur = 2
	}
	else{
		local ur = 3
	}	

	// Preserve data, import harmonized geo_code and household regional variable file and restore data
	preserve

		import excel using "$data_hhss\Harmonization_geocode-admin3.xlsx", sheet("`cty'") firstrow clear
		
		keep geo_code-hs_regcode	// Keep only the variables we need

		rename hs_regcode region`ur' // Rename the household regional variable of the lowest level available
		drop if region`ur'=="" // Drop subregions not in the household survey

		tempfile `cty'_geo_reg`ur'
		save ``cty'_geo_reg`ur'', replace	
				
	restore

	// Merge with harmonized regional temporary file
	merge m:1 region`ur' using ``cty'_geo_reg`ur''

	tab _m
	keep if _m==3	
		// MLI: 1,710 obs (3.93%). These observations correspond to region3 values that do not exist in exposure data.
		
	drop _m

	save "$data_hhss\\`cty'\\RS_`cty'_se_geocode.dta", replace

	collapse (mean) `varsc' `varsp' (rawsum) wta_hh (first) code adm* [pw= wta_hh], by(country year geo_code)

	save "$data_hhss\\`cty'\\RS_`cty'_se_adminX.dta", replace
}


// Create an empty file with an empty variable to be able to append 
clear
gen A=.
// Open loop for countries
foreach cty in $countries{
	append using "$data_hhss\\`cty'\\RS_`cty'_se_adminX.dta"
}
drop A
save "$data_hhss\\RS_All_se_adminX.dta", replace


/*
After this do-file, use the R script "$projectpath\\2_scripts\wb384997\SocioeconIndic\\22_Socioecon and exposure indic by geocode.R" to merge the "$data_hhss\\`cty'\\RS_`cty'_se_adminX.dta" file with climate exposure data, or to check the instructions on how to use R to create a Stata file for each country and merge it at the country level like this (example for BFA):

use "$data_hhss\\BFA\\RS_BFA_se_adminX.dta", clear

merge 1:m geo_code using "$data_hhss\\BFA\\exp_BFA.dta"
	* Note: There are several observations that do not merge because they correspond to geo_codes not present in the household survey

*/

