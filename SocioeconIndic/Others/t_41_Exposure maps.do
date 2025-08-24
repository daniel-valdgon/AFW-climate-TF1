




use "$projectpath\3_results\exposure\Agricultural drought - AEP2p5.dta", clear

// Merge the AFW_adminHS with map coordinates (this file was created in the Poverty maps do-file)
merge 1:1 geo_code using "$projectpath\1_data\Maps\boundaries\AFW_adminHS.dta", nogen keep(match using)

// Generate a categorical variable for drought
gen dr_f2p5_i30_sh_cat = .
replace dr_f2p5_i30_sh_cat = 1 if missing(dr_f2p5_i30_sh)
replace dr_f2p5_i30_sh_cat = 2 if dr_f2p5_i30_sh < 0.5 & dr_f2p5_i30_sh!=. 
replace dr_f2p5_i30_sh_cat = 3 if dr_f2p5_i30_sh >= 0.5 & dr_f2p5_i30_sh < 0.75
replace dr_f2p5_i30_sh_cat = 4 if dr_f2p5_i30_sh >= 0.75 & dr_f2p5_i30_sh < 0.95
replace dr_f2p5_i30_sh_cat = 5 if dr_f2p5_i30_sh >= 0.95 & dr_f2p5_i30_sh!=. 

label def dr_f2p5_i30_sh_cat 1 "No Data" 2 "< 50%" 3 "50 - 75%" 4 "75 - 95%" 5 "> 95%", replace
label val dr_f2p5_i30_sh_cat dr_f2p5_i30_sh_cat


// Sort the ID variable per region to use the spmap command
sort _ID


/*
** Define color palette
These RGB values correspond to:
No Data		Light Gray		RGB(211, 211, 211)
< 50%		Darker Green	RGB(0, 128, 0)
50 - 75%	Light Green		RGB(144, 238, 144)
75 - 95%	Light Blue		RGB(100, 149, 237)
> 95%		Very Dark Blue	RGB(0, 0, 139)
*/

// Draw the drought map
spmap dr_f2p5_i30_sh_cat using "$projectpath\1_data\Maps\boundaries\AFW_adminHS_shp.dta", id(_ID) ///
	fcolor("211 211 211" "0 128 0" "144 238 144" "100 149 237" "0 0 139") ///
	clmethod(unique) legend(size(small)) ///
	title("Share of population exposed to drought AEP2.5 and >30% land affected", size(medsmall))

// Save graph	
graph save "$projectpath\3_results\exposure\Figures\AFW_map_dr_f2p5_i30_sh_cat_lav.gph", replace	


** El mapa de abajo lo habia construido antes y es posible que me sirva. En este caso se inicia en el archivo de encuestas de hogares, pero me parece que no es necesario.


***********************************************
**# Generating maps for exposure indicators #**
***********************************************


** Merge regional data with socioecon indicator with exposure data for mapping

// Opend data with socioeconomic variables
use "$data_hhss\\RS_All_se_adminX.dta", clear

// Merge the drought exposure data (OJO!! this is the lowest regional level available and for maps we need to use the lowest regional level statistically significant ... but the code should be similar)
merge 1:1 geo_code using "$projectpath\3_results\exposure\Agricultural drought - AEP2p5.dta"
	// Note: Admin regions only in the master file are regions without drought exposure data (only one, in NGA: NG009005 - Bakassi)
	// Note: There are 967 regions in the exposure file and not in the household survey. I do not drop them here because they provide information for the maps.
rename _merge _m1

// Merge the AFW_adminHS with map coordinates 
merge 1:1 geo_code using "$projectpath\1_data\Maps\boundaries\AFW_adminHS.dta"
assert _merge==3 | _merge==2  // We allow for regions not in the household survey but with map coordinates
drop _merge

// Generate a categorical variable for drought
gen dr_f2p5_i30_sh_cat = .
replace dr_f2p5_i30_sh_cat = 1 if missing(dr_f2p5_i30_sh)
replace dr_f2p5_i30_sh_cat = 2 if dr_f2p5_i30_sh < 0.5 & dr_f2p5_i30_sh!=. 
replace dr_f2p5_i30_sh_cat = 3 if dr_f2p5_i30_sh >= 0.5 & dr_f2p5_i30_sh < 0.75
replace dr_f2p5_i30_sh_cat = 4 if dr_f2p5_i30_sh >= 0.75 & dr_f2p5_i30_sh < 0.95
replace dr_f2p5_i30_sh_cat = 5 if dr_f2p5_i30_sh >= 0.95 & dr_f2p5_i30_sh!=. 

label def dr_f2p5_i30_sh_cat 1 "No Data" 2 "< 50%" 3 "50 - 75%" 4 "75 - 95%" 5 "> 95%", replace
label val dr_f2p5_i30_sh_cat dr_f2p5_i30_sh_cat


// Sort the ID variable per region to use the spmap command
sort _ID


/*
** Define color palette
These RGB values correspond to:
No Data		Light Gray		RGB(211, 211, 211)
< 50%		Darker Green	RGB(0, 128, 0)
50 - 75%	Light Green		RGB(144, 238, 144)
75 - 95%	Light Blue		RGB(100, 149, 237)
> 95%		Very Dark Blue	RGB(0, 0, 139)
*/

// Draw the drought map
spmap dr_f2p5_i30_sh_cat using "$projectpath\1_data\Maps\boundaries\AFW_adminHS_shp.dta", id(_ID) ///
	fcolor("211 211 211" "0 128 0" "144 238 144" "100 149 237" "0 0 139") ///
	clmethod(unique) legend(size(small)) ///
	title("Share of pop exposed to drought AEP2.5 and >30% land affected", size(medsmall))
	
	
	
	