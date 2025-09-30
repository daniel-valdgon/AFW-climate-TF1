*--------------------------------------------------------------------
*	Title: Adding geo_code to the harmonized dataset
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: June 16, 2025
*--------------------------------------------------------------------


// Open loop for countries
foreach cty in $countries{

	// Open initial data with main harmonized variables
	use "$data_hhss\\`cty'\\RS_`cty'_se.dta", clear

	// Generate a variable for National statistics
	gen region0 = "0 - `cty'"

	** Countries with information up to admin2: BEN CIV CPV GAB GHA GMB GNB LBR NER NGA SLE TGO
	** Countries with information up to admin3: BFA CAF CMR GIN MLI MRT SEN TCD
	// Not al countries have non-missing region3, so this identifies the ones that do and considers it for the next loop
	tab region3
	local r3=r(r)

	if `r3' == 0 | "`cty'" == "GAB" | "`cty'" == "GIN" | "`cty'" == "MRT" | "`cty'" == "SEN" | "`cty'" == "TCD"{
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
	merge m:1 region`ur' using ``cty'_geo_reg`ur'', nogen keep(master match)

	*Note: in MLI, there are 1,710 obs (3.93%) that correspond to region3 values that do not have a matching geo_code in exposure data, but they do have a matching h3 code, so we keep them.
		
	cap drop *_prev // Drop regional variable we do not need

	label var geo_code "Lowest regional level available hhss (merges with hazard data)"

	save "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode.dta", replace
}

