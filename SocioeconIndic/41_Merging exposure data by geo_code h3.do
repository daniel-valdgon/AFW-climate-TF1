*----------------------------------------------------------------------------------------
*	Title: Merge exposure data to harmonized household survey files by geo_code and h3 
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: June 23, 2025
*----------------------------------------------------------------------------------------

/*
Note: We use the following hazards and thresholds, based on what was done for the vision indicators and the paper Hill et al (2025):

- Agricultural drought: frequency: AEP2.5 (1-in-40 year event); and Intensity: More than 30% of land affected (Second option: More than 50% of land affected).

- Flood - any (90m): frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 50cm inundation depth (Second and third options: More than 15cm and more than 100cm inundation depth).

- Heat - 5-day mean maximum daily ESI: frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 33°C (Second option: More than 32°C).

- Air pollution - annual median PM2.5 (2018-2022): frequency: P50(2018-2022); and Intensity: More than 25 µg/m3 (classified as unhealthy or worse by WHO Air Quality Guidelines, 2021) (Second option: More than 35 µg/m3)

- Sea level rise - change in coastal flood depth (90m): frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 0 cm.


*/


***********************************************************************************
**# Import exposure data at the lowest available level in the household surveys #**
***********************************************************************************

/* This is the lowest available level in the household surveys per country:
	Admin1: CPV	
	Admin2: BEN CAF CIV GAB GHA GIN GMB GNB LBR MRT NER NGA SEN SLE TCD TGO	
	Admin3: BFA CMR MLI 
*/


*********************************************************************************************************
**# Merging harmonized household survey data with exposure data by geo_code (lowest region available) #**
*********************************************************************************************************

// Open loop for countries
foreach cty in $countries{

	display in red "`cty'"
	
	// Open household survey data with harmonized socioeconomic variables
	use "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode_h3.dta", clear

	display in red "Drought"
	
	// Merge the drought exposure data
	merge m:1 geo_code using "$projectpath\3_results\exposure\Agricultural drought - AEP2p5.dta", keep(match master)

		// Generate a variable to identify observations without a matching geo_code and without exposure data at the geo_code level
		gen _m_dr_gcobs=1 if _merge==3
		replace _m_dr_gcobs=2 if _merge==1
		label var _m_dr_gcobs "Obs matched and unmatched without location or geo_code exposure data - Drought"
		drop _merge
		
	display in red "Flood"
	
	// Merge the flood exposure data
	merge m:1 geo_code using "$projectpath\3_results\exposure\Flood - any (90m) - RP100.dta", keep(match master)

		// Generate a variable to identify observations without a matching geo_code and without exposure data at the geo_code level
		gen _m_fl_gcobs=1 if _merge==3
		replace _m_fl_gcobs=2 if _merge==1
		label var _m_fl_gcobs "Obs matched and unmatched without location or geo_code exposure data - Flood"
		drop _merge
		
	display in red "Heat"
	
	// Merge the heat exposure data
	merge m:1 geo_code using "$projectpath\3_results\exposure\Heat - 5-day mean maximum daily ESI - RP100.dta", keep(match master)

		// Generate a variable to identify observations without a matching geo_code and without exposure data at the geo_code level
		gen _m_he_gcobs=1 if _merge==3
		replace _m_he_gcobs=2 if _merge==1
		label var _m_he_gcobs "Obs matched and unmatched without location or geo_code exposure data - Heat"
		drop _merge
		
	display in red "Air pollution"

	// Merge the air pollution exposure data
	merge m:1 geo_code using "$projectpath\3_results\exposure\Air pollution - annual median PM2.5 (2018-2022).dta", keep(match master)

		// Generate a variable to identify observations without a matching geo_code and without exposure data at the geo_code level
		gen _m_po_gcobs=1 if _merge==3
		replace _m_po_gcobs=2 if _merge==1
		label var _m_po_gcobs "Obs matched and unmatched without location or geo_code exposure data - Air pollution"
		drop _merge
		
	display in red "Sea level rise"

	// Merge the sea level rise exposure data
	merge m:1 geo_code using "$projectpath\3_results\exposure\Sea level rise - change in coastal flood depth (90m) - RP100.dta", keep(match master)
		// Note: Some regions or countries do not have sea level rise data because they are landlocked or there is no sea level rise information available (for example, BFA, CMR, MRT, NGA, TCD).  		

		// Generate a variable to identify observations without a matching geo_code and without exposure data at the geo_code level
		gen _m_se_gcobs=1 if _merge==3
		replace _m_se_gcobs=2 if _merge==1
		label var _m_se_gcobs "Obs matched and unmatched without location or geo_code exposure data - Sea level rise"
		drop _merge
		
	// Label the categories of all _m variables	
	label def _m_gcobs 1 "Matched geo_code" 2 "Unmatched no loc or geo_code exposure data", replace
	label val _m_*_gcobs _m_gcobs

	// Editing and ordering variables
	order adm0_pcode adm0_name adm1_pcode adm1_name adm2_pcode adm2_name adm3_pcode adm3_name adm4_pcode adm4_name, after(region0)

	rename (pop pop_year) (pop_geo_code pop_year_geo_code)
	label var pop_geo_code "Population at the geo_code level"
	label var pop_year_geo_code "Year of the population at the geo_code level"
	
	gen sep14 = "sep14"
	label var sep14 "******* Section 14: Hazard exposure variables at geo_code level *******"
	order sep14 pop_geo_code pop_year_geo_code, after(freq)

	// Drop unnecessary variables
	drop code-freq	
	
	// Save household survey data with harmonized socioeconomic and exposure variables
	save "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode_h3_exp.dta", replace

}




***********************************************************************************
**# Merging harmonized household survey data with exposure data at the h3 level #**
***********************************************************************************

// Open loop for countries
foreach cty in $countries{

	display in red "`cty'"

	use "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode_h3_exp.dta", clear

	// Merge the drought exposure data at h3 level
	merge m:1 h3_6 using "$projectpath\3_results\exposure\Agricultural drought - AEP2p5_h3_c.dta", keep(master match) 

		// Generate a variable to identify observations without GPS data and without drought exposure data at the h3 level
		gen _m_dr_h3obs=1 if _merge==3
		replace _m_dr_h3obs=2 if _merge==1 & h3_6==""
		replace _m_dr_h3obs=3 if _merge==1 & h3_6!=""
		label var _m_dr_h3obs "Obs matched and unmatched with a without h3 data - Drought"
		drop _merge

	// Merge the flood exposure data at h3 level
	merge m:1 h3_6 using "$projectpath\3_results\exposure\Flood - any (90m) - RP100_h3_c.dta", keep(master match) 

		// Generate a variable to identify observations without GPS data and without flood exposure data at the h3 level
		gen _m_fl_h3obs=1 if _merge==3
		replace _m_fl_h3obs=2 if _merge==1 & h3_6==""
		replace _m_fl_h3obs=3 if _merge==1 & h3_6!=""
		label var _m_fl_h3obs "Obs matched and unmatched with a without h3 data - Flood"
		drop _merge

	// Merge the heat exposure data at h3 level
	merge m:1 h3_6 using "$projectpath\3_results\exposure\Heat - 5-day mean maximum daily ESI - RP100_h3_c.dta", keep(master match) 

		// Generate a variable to identify observations without GPS data and without heat exposure data at the h3 level
		gen _m_he_h3obs=1 if _merge==3
		replace _m_he_h3obs=2 if _merge==1 & h3_6==""
		replace _m_he_h3obs=3 if _merge==1 & h3_6!=""
		label var _m_he_h3obs "Obs matched and unmatched with a without h3 data - Heat"
		drop _merge
		
	// Merge the air pollution exposure data at h3 level
	merge m:1 h3_6 using "$projectpath\3_results\exposure\Air pollution - annual median PM2.5 (2018-2022)_h3_c.dta", keep(master match) 

		// Generate a variable to identify observations without GPS data and without air pollution exposure data at the h3 level
		gen _m_po_h3obs=1 if _merge==3
		replace _m_po_h3obs=2 if _merge==1 & h3_6==""
		replace _m_po_h3obs=3 if _merge==1 & h3_6!=""
		label var _m_po_h3obs "Obs matched and unmatched with a without h3 data - Air Pollution"
		drop _merge

	// Merge the sea level rise exposure data at h3 level
	merge m:1 h3_6 using "$projectpath\3_results\exposure\Sea level rise - change in coastal flood depth (90m)_h3_c.dta", keep(master match) 
		// Note: Some regions or countries do not have sea level rise data because they are landlocked or there is no sea level rise information available (for example, BFA, CMR, MRT, NGA, TCD).
		
		// Generate a variable to identify observations without GPS data and without sea level rise exposure data at the h3 level
		gen _m_se_h3obs=1 if _merge==3
		replace _m_se_h3obs=2 if _merge==1 & h3_6==""
		replace _m_se_h3obs=3 if _merge==1 & h3_6!=""
		label var _m_se_h3obs "Obs matched and unmatched with a without h3 data - Sea level rise"
		drop _merge
		
	// Label the categories of all _m variables	
	label def _m_h3obs 1 "Matched h3" 2 "Unmatched no GPS or h3 data" 3 "Unmatched no h3 exposure data", replace
	label val _m_*_h3obs _m_h3obs

	
	gen sep15 = "sep15"
	label var sep15 "******* Section 15: Hazard exposure variables at h3 level *******"
	order sep15, before(pop_h3)

	gen sep16 = "sep16"
	label var sep16 "******* Section 16: Hazard exposure variables at h3 or lowest available level *******"
	
	// Generate the exposure variable with h3 values (when available) and with the lowest regional level available (otherwise)
	foreach ha in dr fl he po se{
		foreach var of varlist `ha'_*_sh `ha'_*_pop{
			gen `var'_l = `var'_h3
			replace `var'_l = `var' if _m_`ha'_h3obs!=1
			local lbl: variable label `var'
			label var `var'_l "`lbl' at h3 or lowest level"
		}		
	}

	
	// Save household survey data with harmonized socioeconomic and exposure variables at h3 level or lowest available
	save "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode_h3_exp.dta", replace	
	
}
	

**********************************************************************************************************************
**# Table with matching observations between household survey data and exposure data at the geo_code and h3 levels #**
**********************************************************************************************************************

// Open loop for countries
foreach cty in $countries{

	use "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode_h3_exp.dta", clear

	count // Count total observations per country and save in a local
	local t = r(N)
		
	foreach h in dr fl he po se{

		// Count matched and unmatched observations with geo_code exposure data and save in locals
		count if _m_`h'_gcobs==1 
		local m = r(N)
		count if _m_`h'_gcobs==2
		local u = r(N)

		// Save hazard results in a matrix
		mat A = [`m', (`m'*100/`t') \ `u', (`u'*100/`t')]

		// Compile results for all hazards
		mat GC_`cty' = [nullmat(GC_`cty') , A]

		 // Count matched and unmatched observations with h3 exposure data and save in locals
		count if _m_`h'_h3obs==1
		local m = r(N)
		count if _m_`h'_h3obs==2
		local u1 = r(N)
		count if _m_`h'_h3obs==3
		local u2 = r(N)

		// Save hazard results in a matrix
		mat B = [`m', (`m'*100/`t') \ `u1', (`u1'*100/`t') \ `u2', (`u2'*100/`t')]

		// Compile results for all hazards
		mat H3_`cty' = [nullmat(H3_`cty') , B]
	}
	
	// Compile results for all countries for geo_code and h3 results
	mat GC =  [nullmat(GC) \ GC_`cty']
	mat H3 =  [nullmat(H3) \ H3_`cty'] 	
	
}

// Export matching obs with geo_code to Excel
putexcel set "$projectpath\3_results\hhss-exposure\\Matched obs hhss vs exposure geo_code and h3.xlsx", sheet(geo_code) modify
putexcel C4 = matrix(GC), nformat(number_d2)

// Export matching obs with h3 to Excel
putexcel set "$projectpath\3_results\hhss-exposure\\Matched obs hhss vs exposure geo_code and h3.xlsx", sheet(h3) modify
putexcel C4 = matrix(H3), nformat(number_d2)




