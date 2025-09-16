*-----------------------------------------------------------------------
*	Title: Obtain poverty maps for AFW 
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: June 23, 2025
*-----------------------------------------------------------------------

** OJO!! This do-file is useful for verifying poverty results and for our own exercises, not for the database. Check content and change names after finishing the do-files for the database.

// Change the Stata directory in order to use the spshape2data command
cd "$projectpath\1_data\Maps\boundaries"

** Use the shape file AFW_adminX.shp to generage the corresponding file and shape files in Stata format  
	*Note: The file AFW_adminX.shp was generated in an R-script ("$dofiles//t_14_From gpkg to shp files for maps.R") from the file AFW_adminX.gpkg.
spshape2dta AFW_adminX, replace saving(AFW_adminX)
	*Note: The previous command generated the following files in the same folder as AFW_adminX.gpkg: 
		* AFW_adminX.dta, 
		* AFW_adminX_shp.dta, 

** Do the same for AFW_admin2 and AFW_admin1 
spshape2dta AFW_admin2, replace saving(AFW_admin2)
spshape2dta AFW_admin1, replace saving(AFW_admin1)
spshape2dta AFW_admin0, replace saving(AFW_admin0)

***********************************************************************************************************
**# Generate file with admin codes corresponding to the lowest available level in the household surveys #**
***********************************************************************************************************

/*
These are the lowest level of admin regions available per country in the household surveys, which are different to the lowest available in the file "AFW_adminX.dta":
	Admin1: CPV	
	Admin2: CAF CIV GMB NER SEN SLE TGO	

For the rest of the countries, the lowest level of admin regions available in the household surveys match that in the file "AFW_adminX.dta" (admin2 or admin3): 	
	AdminX: BEN BFA CMR GHA GIN GNB LBR MLI MRT NGA TCD
		Admin2: BEN GHA GIN GNB LBR MRT NGA TCD
		Admin3: BFA CMR MLI 
	
	
*/

// Open adminX file
use "$projectpath\1_data\Maps\boundaries\AFW_adminX.dta", clear

// Drop the countries with admin1 or admin2 in household surveys but not in adminX	
drop if inlist(code, "CPV", "CAF", "CIV", "GMB", "NER", "SEN", "SLE", "TGO")

// Save file
save "$projectpath\1_data\Maps\boundaries\AFW_adminHS.dta", replace


// Open adminX_shp file
use "$projectpath\1_data\Maps\boundaries\AFW_adminX_shp.dta", clear

// Merge the AFW_adminX.dta to use the country variable (code)
merge m:1 _ID using "$projectpath\1_data\Maps\boundaries\AFW_adminX.dta", keepusing(code)
assert _merge==3
drop _merge

// Drop the countries with admin1 or admin2 in household surveys but not in adminX	
drop if inlist(code, "CPV", "CAF", "CIV", "GMB", "NER", "SEN", "SLE", "TGO")
drop code

// Save file
save "$projectpath\1_data\Maps\boundaries\AFW_adminHS_shp.dta", replace


// Open admin1 file
use "$projectpath\1_data\Maps\boundaries\AFW_admin1.dta", clear

// Keep observations of the countries we need with admin1 information
keep if inlist(code, "CPV")

// Replace the _ID number to avoid merging errors and save a temporary file
replace _ID = 10000+_ID 
tempfile ad1
save `ad1', replace

// Open admin1_shp file
use "$projectpath\1_data\Maps\boundaries\AFW_admin1_shp.dta", clear

// Merge the AFW_admin1.dta to use the country variable (code)
merge m:1 _ID using "$projectpath\1_data\Maps\boundaries\AFW_admin1.dta", keepusing(code)
assert _merge==3
drop _merge

// Keep observations of the countries we need with admin1 information
keep if inlist(code, "CPV")
drop code

// Replace the _ID number to avoid merging errors and save a temporary file	
replace _ID = 10000+_ID
tempfile ad1shp
save `ad1shp', replace


// Open admin2 file
use "$projectpath\1_data\Maps\boundaries\AFW_admin2.dta", clear

// Keep observations of the countries we need with admin2 information
keep if inlist(code, "CAF", "CIV", "GMB", "NER", "SEN", "SLE", "TGO")

// Replace the _ID number to avoid merging errors and save a temporary file
replace _ID = 20000+_ID 
tempfile ad2
save `ad2', replace


// Open admin2_shp file
use "$projectpath\1_data\Maps\boundaries\AFW_admin2_shp.dta", clear

// Merge the AFW_admin2.dta to use the country variable (code)
merge m:1 _ID using "$projectpath\1_data\Maps\boundaries\AFW_admin2.dta", keepusing(code)
assert _merge==3
drop _merge

// Keep observations of the countries we need with admin2 information
keep if inlist(code, "CAF", "CIV", "GMB", "NER", "SEN", "SLE", "TGO")
drop code
	
// Replace the _ID number to avoid merging errors and save a temporary file
replace _ID = 20000+_ID 
tempfile ad2shp
save `ad2shp', replace

** Open the AFW_adminHS files, append the temporary files just created and save the file
use "$projectpath\1_data\Maps\boundaries\AFW_adminHS.dta", clear
append using `ad1'
append using `ad2'
sort _ID
save "$projectpath\1_data\Maps\boundaries\AFW_adminHS.dta", replace

use "$projectpath\1_data\Maps\boundaries\AFW_adminHS_shp.dta", clear
append using `ad1shp'
append using `ad2shp'
sort _ID shape_order
save "$projectpath\1_data\Maps\boundaries\AFW_adminHS_shp.dta", replace



*****************************************************************************
**# Map poverty rates using the lowest available admin region per country #**
*****************************************************************************

// Opend data with socioeconomic variables
*use "$data_hhss\\RS_All_se_adminX.dta", clear
use "$projectpath\3_results\hhss-exposure\\RS_All_se-gc-h3_adminX.dta", clear

// Merge the AFW_adminHS with map coordinates 
merge 1:1 geo_code using "$projectpath\1_data\Maps\boundaries\AFW_adminHS.dta", nogen keep(match using)
	// Note: There is one observation in the household survey of MLI that is not in the AFW_adminHS data (region3=="11102)"
*assert _merge==3 | _merge==2  // We allow for regions not in the household survey but with map coordinates
*drop if _merge==1 // There is one observation in the household survey of MLI that is not in the AFW_adminHS data (region3=="11102)"
*drop _merge

merge m:1 code using "$projectpath\1_data\Maps\boundaries\AFW_admin0.dta", nogen keep(match using)

// Label the poverty categories and generate a categorical variable for each poverty variable
label def povcat 1 "No Data" 2 "< 5%" 3 "5 - 10%" 4 "10 - 20%" 5 "20 - 30%" 6 "30 - 50%" 7 "> 50%", replace

foreach pov in p_2_15 p_3_65 p_6_85 p_3 p_4_2 p_8_3{
	replace `pov' = 100*`pov' // Report results in percentages
	gen `pov'_cat = .
	replace `pov'_cat = 1 if missing(`pov')
	replace `pov'_cat = 2 if `pov' < 5 & `pov'!=. 
	replace `pov'_cat = 3 if `pov' >= 5 & `pov' < 10
	replace `pov'_cat = 4 if `pov' >= 10 & `pov' < 20
	replace `pov'_cat = 5 if `pov' >= 20 & `pov' < 30
	replace `pov'_cat = 6 if `pov' >= 30 & `pov' < 50
	replace `pov'_cat = 7 if `pov' >= 50 & `pov'!=. 

	label val `pov'_cat povcat
}

// Sort the ID variable per region to use the spmap command
sort _ID


/*
** Define color palette
These RGB values correspond to:
No Data		Light Gray		RGB(211, 211, 211)
< 5%		Darker Green	RGB(0, 128, 0)
5 - 10%		Light Green		RGB(144, 238, 144)
10 - 20%	Light Blue		RGB(173, 216, 230)
20 - 30%	Medium Blue		RGB(100, 149, 237)
30 - 50%	Dark Blue		RGB(65, 105, 225)
> 50%		Very Dark Blue	RGB(0, 0, 139)
*/

// Draw the poverty map
spmap p_2_15_cat using "$projectpath\1_data\Maps\boundaries\AFW_adminHS_shp.dta", id(_ID) ///
	fcolor("211 211 211" "0 128 0" "144 238 144" "173 216 230" "100 149 237" "65 105 225" "0 0 139") ///
	ocolor(gs12 ..) clmethod(unique) legend(size(small)) ///
	title("Poverty rates - AFW ($2.15, 2017 PPP)", size(medsmall))


// Save graph	
graph save "$projectpath\3_results\SocioeconIndic\Figures\AFW_map_pov_2_15_lav.gph", replace	



***********************************************************************************************************************************************
**# Generate file with admin codes corresponding to the lowest regional level of statistical significance per country the household surveys #**
***********************************************************************************************************************************************

/*
	
// These are the groups of countries depending on their lowest regional level of statistical significance
region1 "BEN BFA CAF CIV CMR GIN GNB MLI NER SEN TCD TGO"
region2 "CPV GHA GMB LBR NGA SLE"
region3 "MRT"	

Notes: 
	- admin1 of CPV and NGA corresponds to region2 in household surveys, which is the lowest representative level.
	- The lowest admin level available for mapping in MRT is admin2, although region3 is the lowest representative level in the household survey.
*/


// Open admin2 file
use "$projectpath\1_data\Maps\boundaries\AFW_admin2.dta", clear

// Keep the countries with admin2 as the lowest level of significance in household surveys	
keep if inlist(code, "GHA","GMB","LBR","MRT","SLE")

// Save file
save "$projectpath\1_data\Maps\boundaries\AFW_adminHS_lsig.dta", replace


// Open admin2_shp file
use "$projectpath\1_data\Maps\boundaries\AFW_admin2_shp.dta", clear

// Merge the AFW_admin2.dta to use the country variable (code)
merge m:1 _ID using "$projectpath\1_data\Maps\boundaries\AFW_admin2.dta", keepusing(code)
assert _merge==3
drop _merge

// Keep the countries with admin2 as the lowest level of significance in household surveys	
keep if inlist(code, "GHA","GMB","LBR","MRT","SLE")
drop code

// Save file
save "$projectpath\1_data\Maps\boundaries\AFW_adminHS_lsig_shp.dta", replace


// Open admin1 file
use "$projectpath\1_data\Maps\boundaries\AFW_admin1.dta", clear

// Drop the countries with admin2 as the lowest level of significance in household surveys	
drop if inlist(code, "GHA","GMB","LBR","MRT","SLE")

// Replace the _ID number to avoid merging errors and save a temporary file
replace _ID = 10000+_ID 
tempfile ad1
save `ad1', replace

// Open admin1_shp file
use "$projectpath\1_data\Maps\boundaries\AFW_admin1_shp.dta", clear

// Merge the AFW_admin1.dta to use the country variable (code)
merge m:1 _ID using "$projectpath\1_data\Maps\boundaries\AFW_admin1.dta", keepusing(code)
assert _merge==3
drop _merge

// Drop the countries with admin2 as the lowest level of significance in household surveys	
drop if inlist(code, "GHA","GMB","LBR","MRT","SLE")
drop code

// Replace the _ID number to avoid merging errors and save a temporary file	
replace _ID = 10000+_ID
tempfile ad1shp
save `ad1shp', replace


** Open the AFW_adminHS_lsig files, append the temporary files just created and save the file
use "$projectpath\1_data\Maps\boundaries\AFW_adminHS_lsig.dta", clear
append using `ad1'
sort _ID
save "$projectpath\1_data\Maps\boundaries\AFW_adminHS_lsig.dta", replace

use "$projectpath\1_data\Maps\boundaries\AFW_adminHS_lsig_shp.dta", clear
append using `ad1shp'
sort _ID shape_order
save "$projectpath\1_data\Maps\boundaries\AFW_adminHS_lsig_shp.dta", replace



*************************************************************************************
**# Map poverty rates using the lowest regional level of significance per country #**
*************************************************************************************

// Opend data with socioeconomic variables
*use "$data_hhss\\RS_All_se_adminX.dta", clear
use "$projectpath\3_results\hhss-exposure\\RS_All_se-gc-h3_adminX.dta", clear


// Rename geo_code and replace it by the corresponding lowest regional level of significance
gen geo_code_orig = geo_code

replace geo_code = adm1_pcode
*replace geo_code = adm2_pcode if inlist(code, "GHA","GMB","LBR","MRT","SLE")
replace geo_code = adm2_pcode if inlist(country, "GHA","GMB","LBR","MRT","SLE")

// Collapse file to the lowest regional level of significance

local varsc "dpcexp_pov_2017 dpcexp_pov_2021 pcfoodexp educyrs pcremit"
*local varsp "p_2_15 p_3_65 p_6_85 p_3 p_4_2 p_8_3 educat5_* ageg_* male female disability lstatus_* indcat4_* loweduc yrsschol_hh scholatt water8_* noimpwater nobaswater noelec lowq_mat scookfl notimprsanit cellphone car fridge noassets accinter hh_remit bankacc mobbankacc nosoctrss"
local varsp "p_2_15 p_3_65 p_6_85 p_3 p_4_2 p_8_3 educat5_* ageg_* female disability lstatus_* indcat4_* loweduc yrsschol_hh scholatt water8_* noimpwater nobaswater noelec lowq_mat scookfl notimprsanit cellphone car fridge noassets accinter hh_remit bankacc mobbankacc nosoctrss"
	
collapse (mean) `varsc' `varsp' (rawsum) wta_hh (first) region* subnatidsurvey adm* [pw= wta_hh], by(country year geo_code)

*save "$data_hhss\\RS_All_se_admin_lsig.dta", replace
save "$projectpath\3_results\hhss-exposure\\RS_All_se-gc-h3_admin_lsig.dta", replace

use "$projectpath\3_results\hhss-exposure\\RS_All_se-gc-h3_admin_lsig.dta", clear

// Merge the AFW_adminHS_lsig with map coordinates 
merge 1:1 geo_code using "$projectpath\1_data\Maps\boundaries\AFW_adminHS_lsig.dta", nogen keep(match using)
	// Note: There is one observation in the household survey of MLI that is not in the AFW_adminHS data (region3=="11102)"
*assert _merge==3 | _merge==2  // We allow for regions not in the household survey but with map coordinates
*drop _merge

// Label the poverty categories and generate a categorical variable for each poverty variable
label def povcat 1 "No Data" 2 "< 5%" 3 "5 - 10%" 4 "10 - 20%" 5 "20 - 30%" 6 "30 - 50%" 7 "> 50%", replace

foreach pov in p_2_15 p_3_65 p_6_85 p_3 p_4_2 p_8_3{
	replace `pov' = 100*`pov' // Express results in percentages
	gen `pov'_cat = .
	replace `pov'_cat = 1 if missing(`pov')
	replace `pov'_cat = 2 if `pov' < 5 & `pov'!=. 
	replace `pov'_cat = 3 if `pov' >= 5 & `pov' < 10
	replace `pov'_cat = 4 if `pov' >= 10 & `pov' < 20
	replace `pov'_cat = 5 if `pov' >= 20 & `pov' < 30
	replace `pov'_cat = 6 if `pov' >= 30 & `pov' < 50
	replace `pov'_cat = 7 if `pov' >= 50 & `pov'!=. 

	label val `pov'_cat povcat
}

// Sort the ID variable per region to use the spmap command
sort _ID


/*
** Define color palette
These RGB values correspond to:
No Data		Light Gray		RGB(211, 211, 211)
< 5%		Darker Green	RGB(0, 128, 0)
5 - 10%		Light Green		RGB(144, 238, 144)
10 - 20%	Light Blue		RGB(173, 216, 230)
20 - 30%	Medium Blue		RGB(100, 149, 237)
30 - 50%	Dark Blue		RGB(65, 105, 225)
> 50%		Very Dark Blue	RGB(0, 0, 139)
*/

// Draw the poverty map
spmap p_2_15_cat using "$projectpath\1_data\Maps\boundaries\AFW_adminHS_lsig_shp.dta", id(_ID) ///
	fcolor("211 211 211" "0 128 0" "144 238 144" "173 216 230" "100 149 237" "65 105 225" "0 0 139") ///
	clmethod(unique) legend(size(small)) ///
	title("Poverty rates - AFW ($2.15, 2017 PPP)", size(medsmall))

// Save graph	
graph save "$projectpath\3_results\SocioeconIndic\Figures\AFW_map_pov_2_15_lsig.gph", replace	

foreach pov in 2_15 3_65 6_85 3 4_2 8_3{

	if "`pov'" == "2_15"{
		local title = "$2.15, 2017 PPP"
	}
	else if "`pov'" == "3_65"{
		local title = "$3.65, 2017 PPP"
	}	
	else if "`pov'" == "6_85"{
		local title = "$6.85, 2017 PPP"
	}	
	else if "`pov'" == "3"{
		local title = "$3, 2021 PPP"
	}	
	else if "`pov'" == "4_2"{
		local title = "$4.2, 2021 PPP"
	}	
	else if "`pov'" == "8_3"{
		local title = "$8.3, 2021 PPP"
	}	
	
	// Draw the poverty map
	spmap p_`pov'_cat using "$projectpath\1_data\Maps\boundaries\AFW_adminHS_lsig_shp.dta", id(_ID) ///
		fcolor("211 211 211" "0 128 0" "144 238 144" "173 216 230" "100 149 237" "65 105 225" "0 0 139") ///
		clmethod(unique) legend(size(small)) ///
		title("Poverty rates - AFW (`title')", size(medsmall))

	// Save graph	
	graph save "$projectpath\3_results\SocioeconIndic\Figures\AFW_map_pov_`pov'_lsig.gph", replace	

}
