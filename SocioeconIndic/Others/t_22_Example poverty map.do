** Example poverty map

use "$projectpath\3_results\hhss-exposure\\RS_All_se-gc-h3_admin_lsig.dta", clear

// Merge the AFW_adminHS_lsig with map coordinates 
merge 1:1 geo_code using "$projectpath\1_data\Maps\boundaries\AFW_adminHS_lsig.dta"
, nogen keep(match using)
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
