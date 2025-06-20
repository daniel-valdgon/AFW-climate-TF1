*---------------------------------------------------------------------------------------------------
*	Title: Harmonize geocode with regional admin variables form household surveys
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: June 1, 2025
*---------------------------------------------------------------------------------------------------

/*
Summary:
	This do-file takes data from an Excel file called "$data_hhss\HarmoRegions.xlsx" and clean it so that we can more easily match regions in the climate data (regcode and Region A) with those in the household survey data (Region B). Once cleaned (using lower cases only, substracting numbers, hyphens, spaces and other symbols) and matched, the result is exported to the Excel file "$data_hhss\Harmonization_geocode-admin3.xlsx", where the rest of the area matching work is performed manually.
*/


foreach cty in $countries{ 

	display in red "`cty'" 
	import excel using "$data_hhss\HarmoRegions.xlsx", sheet("`cty'") firstrow clear


	// Generating a regional variable in lower cases, without accents, numbers, hyphens and spaces	
	gen RegA = ustrlower( ustrregexra( ustrnormalize( RegionA, "nfd" ) , "\p{Mark}", "" )  )
	replace RegA = ustrregexra(RegA, "[0-9/.,\u00A0 '\-’]", "")
	
	preserve
		keep RegionB
		
		// Generating a regional variable in lower cases, without accents, numbers, hyphens and spaces	
		gen RegB = ustrlower( ustrregexra( ustrnormalize( RegionB, "nfd" ) , "\p{Mark}", "" )  )
		replace RegB = ustrregexra(RegB, "[0-9/.,\u00A0 '\-’]", "")

		gen RegA = RegB
		drop if RegA == ""
		tempfile B
		save `B', replace
	restore

	keep regcode RegionA RegA

	merge m:m RegA using `B'

	export excel using "$data_hhss\Harmonization_geocode-admin3.xlsx", sheet("`cty'", modify) firstrow(var) cell(O1)
}

* Note: After obtaining the file "$data_hhss\Harmonization_geocode-admin3.xlsx", the rest of the area matching work is performed manually.

