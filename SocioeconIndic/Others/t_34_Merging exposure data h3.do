*---------------------------------------------------------------------------------------------------
*	Title: Merge exposure data to harmonized household survey files at the h3 level when available 
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: July 25, 2025
*---------------------------------------------------------------------------------------------------

/*
Note: We use the following hazards and thresholds, based on what was done for the vision indicators and the paper Hill et al (2025):

- Agricultural drought: frequency: AEP2.5 (1-in-40 year event); and Intensity: More than 30% of land affected (Second option: More than 50% of land affected).

- Flood - any (90m): frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 50cm inundation depth (Second and third options: More than 15cm and more than 100cm inundation depth).

- Heat - 5-day mean maximum daily ESI: frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 33°C (Second option: More than 32°C).

- Air pollution - annual median PM2.5 (2018-2022): frequency: P50(2018-2022); and Intensity: More than 25 µg/m3 (classified as unhealthy or worse by WHO Air Quality Guidelines, 2021) (Second option: More than 35 µg/m3)

- Sea level rise - change in coastal flood depth (90m): frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 0 cm.

*/



************************************************************************************
**# Collapsing and editing harzard data at the h3_6 level for posterior mergings #**
************************************************************************************

****************************	
**# Agricultural drought #**
****************************
** Note: Frequency: AEP2.5 (1-in-40 year event); and Intensity: More than 30% of land affected (Second option: More than 50% of land affected).

use "$projectpath\3_results\exposure\Agricultural drought - AEP2p5_h3.dta", clear

collapse (sum) exp_sh exp_pop (first) pop pop_year, by(h3_6 exp_cat)

// Avoid considering observations for <30% land affected 	
replace exp_sh = 0 if exp_cat==0 
replace exp_pop = 0 if exp_cat==0	
// Generate share and population exposed for AEP2.5 and >30% at the h3_6 level
egen dr_f2p5_i30_sh_h3 = total(exp_sh), by(h3_6)		
label var dr_f2p5_i30_sh_h3 "Share of pop exposed to drought AEP2.5 and >30% land affected at h3_6"
egen dr_f2p5_i30_pop_h3 = total(exp_pop), by(h3_6)
label var dr_f2p5_i30_pop_h3 "Population exposed to drought AEP2.5 and >30% land affected at h3_6"

// Avoid considering observations for <50% land affected 		
replace exp_sh = 0 if exp_cat==1  
replace exp_pop = 0 if exp_cat==1  
// Generate share and population exposed for AEP2.5 and >50% at the h3_6 level
egen dr_f2p5_i50_sh_h3 = total(exp_sh), by(h3_6)
label var dr_f2p5_i50_sh_h3 "Share of pop exposed to drought AEP2.5 and >50% land affected at h3_6"	
egen dr_f2p5_i50_pop_h3 = total(exp_pop), by(h3_6)
label var dr_f2p5_i50_pop_h3 "Population exposed to drought AEP2.5 and >50% land affected at h3_6"	

// Keep one observation per h3_6
bysort h3_6: keep if _n==1

// Edit dababase and label variables
drop exp_cat exp_sh exp_pop
rename pop pop_h3
label var pop_h3 "Population at the h3 level"
rename pop_year pop_year_h3
label var pop_year_h3 "Year of the population at the h3 level"
label var h3_6 "H3 index (hexagonal cells) at resolution 6"

save "$projectpath\3_results\exposure\Agricultural drought - AEP2p5_h3_c.dta", replace


*************************	
**# Flood - any (90m) #**
*************************
	** Note: Flood - any (90m): Frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 50cm inundation depth (Second and third options: More than 15cm and more than 100cm inundation depth). 
	
use "$projectpath\3_results\exposure\Flood - any (90m) - RP100_h3.dta", clear

collapse (sum) exp_sh exp_pop (first) pop pop_year, by(h3_6 exp_cat)

// Avoid considering observations for <15cm inundation depth at the h3_6 level 	
replace exp_sh = 0 if inlist(exp_cat, 0,1) 
replace exp_pop = 0 if inlist(exp_cat, 0,1)	
// Generate share and population exposed for RP100 and >15cm at the h3_6 level
egen fl_f100_i15_sh_h3 = total(exp_sh), by(h3_6)		
label var fl_f100_i15_sh_h3 "Share of pop exposed to flood RP100 and >15cm inundation depth at h3_6"
egen fl_f100_i15_pop_h3 = total(exp_pop), by(h3_6)
label var fl_f100_i15_pop_h3 "Population exposed to flood RP100 and >15cm inundation depth at h3_6"	
	
// Avoid considering observations for <50cm inundation depth at the h3_6 level 	
replace exp_sh = 0 if exp_cat == 2 
replace exp_pop = 0 if exp_cat == 2	
// Generate share and population exposed for RP100 and >50cm at the h3_6 level
egen fl_f100_i50_sh_h3 = total(exp_sh), by(h3_6)		
label var fl_f100_i50_sh_h3 "Share of pop exposed to flood RP100 and >50cm inundation depth at h3_6"
egen fl_f100_i50_pop_h3 = total(exp_pop), by(h3_6)
label var fl_f100_i50_pop_h3 "Population exposed to flood RP100 and >50cm inundation depth at h3_6"
	
// Avoid considering observations for <100cm inundation depth at the h3_6 level
replace exp_sh = 0 if exp_cat==3  
replace exp_pop = 0 if exp_cat==3  
// Generate share and population exposed for RP100 and >100cm at the h3_6 level
egen fl_f100_i100_sh_h3 = total(exp_sh), by(h3_6)		
label var fl_f100_i100_sh_h3 "Share of pop exposed to flood RP100 and >100cm inundation depth at h3_6"
egen fl_f100_i100_pop_h3 = total(exp_pop), by(h3_6)
label var fl_f100_i100_pop_h3 "Population exposed to flood RP100 and >100cm inundation depth at h3_6"

// Keep one observation per h3_6
bysort h3_6: keep if _n==1

// Edit dababase and label variables
drop exp_cat exp_sh exp_pop
rename pop pop_h3
label var pop_h3 "Population at the h3 level"
rename pop_year pop_year_h3
label var pop_year_h3 "Year of the population at the h3 level"
label var h3_6 "H3 index (hexagonal cells) at resolution 6"

save "$projectpath\3_results\exposure\Flood - any (90m) - RP100_h3_c.dta", replace


*******************************************	
**# Heat - 5-day mean maximum daily ESI #**
*******************************************
	** Note: Heat - 5-day mean maximum daily ESI: frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 33°C (Second option: More than 32°C). 

use "$projectpath\3_results\exposure\Heat - 5-day mean maximum daily ESI - RP100_h3.dta", clear

collapse (sum) exp_sh exp_pop (first) pop pop_year, by(h3_6 exp_cat)

// Avoid considering observations for <32°C at the h3_6 level 	
replace exp_sh = 0 if inlist(exp_cat, 0,1,2) 
replace exp_pop = 0 if inlist(exp_cat, 0,1,2)	
// Generate share and population exposed for RP100 and >32°C at the h3_6 level
egen he_f100_i32_sh_h3 = total(exp_sh), by(h3_6)		
label var he_f100_i32_sh_h3 "Share of pop exposed to heat RP100 and >32°C at h3_6"
egen he_f100_i32_pop_h3 = total(exp_pop), by(h3_6)
label var he_f100_i32_pop_h3 "Population exposed to heat RP100 and >32°C at h3_6"

// Avoid considering observations for <33°C at the h3_6 level 	
replace exp_sh = 0 if exp_cat == 3 
replace exp_pop = 0 if exp_cat == 3	
// Generate share and population exposed for RP100 and >33°C at the h3_6 level
egen he_f100_i33_sh_h3 = total(exp_sh), by(h3_6)		
label var he_f100_i33_sh_h3 "Share of pop exposed to heat RP100 and >33°C at h3_6"
egen he_f100_i33_pop_h3 = total(exp_pop), by(h3_6)
label var he_f100_i33_pop_h3 "Population exposed to heat RP100 and >33°C at h3_6"

// Keep one observation per h3_6
bysort h3_6: keep if _n==1

// Edit dababase and label variables
drop exp_cat exp_sh exp_pop
rename pop pop_h3
label var pop_h3 "Population at the h3 level"
rename pop_year pop_year_h3
label var pop_year_h3 "Year of the population at the h3 level"
label var h3_6 "H3 index (hexagonal cells) at resolution 6"

save "$projectpath\3_results\exposure\Heat - 5-day mean maximum daily ESI - RP100_h3_c.dta", replace


*******************************************************	
**# Air pollution - annual median PM2.5 (2018-2022) #**
*******************************************************
	** Note: Air pollution - annual median PM2.5 (2018-2022): frequency: P50(2018-2022); and Intensity: More than 25 µg/m3 (classified as unhealthy or worse by WHO Air Quality Guidelines, 2021) (Second option: More than 35 µg/m3) 

use "$projectpath\3_results\exposure\Air pollution - annual median PM2.5 (2018-2022)_h3.dta", clear

collapse (sum) exp_sh exp_pop (first) pop pop_year, by(h3_6 exp_cat)

// Avoid considering observations for <25 µg/m3 at the h3_6 level 	
replace exp_sh = 0 if inlist(exp_cat, 1,2,3) 
replace exp_pop = 0 if inlist(exp_cat, 1,2,3)	
// Generate share and population exposed for P50 and >25 µg/m3 at the h3_6 level
egen po_f50_i25_sh_h3 = total(exp_sh), by(h3_6)		
label var po_f50_i25_sh_h3 "Share of pop exposed to air pollution P50 and 25 µg/m3 at h3_6"
egen po_f50_i25_pop_h3 = total(exp_pop), by(h3_6)
label var po_f50_i25_pop_h3 "Population exposed to air pollution P50 and 25 µg/m3 at h3_6"

// Avoid considering observations for <35 µg/m3 at the h3_6 level 	
replace exp_sh = 0 if exp_cat == 4 
replace exp_pop = 0 if exp_cat == 4	
// Generate share and population exposed for P50 and >35 µg/m3 at the h3_6 level
egen po_f50_i35_sh_h3 = total(exp_sh), by(h3_6)		
label var po_f50_i35_sh_h3 "Share of pop exposed to air pollution P50 and 35 µg/m3 at h3_6"
egen po_f50_i35_pop_h3 = total(exp_pop), by(h3_6)
label var po_f50_i35_pop_h3 "Population exposed to air pollution P50 and 35 µg/m3 at h3_6"

// Keep one observation per h3_6
bysort h3_6: keep if _n==1

// Edit dababase and label variables
drop exp_cat exp_sh exp_pop
rename pop pop_h3
label var pop_h3 "Population at the h3 level"
rename pop_year pop_year_h3
label var pop_year_h3 "Year of the population at the h3 level"
label var h3_6 "H3 index (hexagonal cells) at resolution 6"

save "$projectpath\3_results\exposure\Air pollution - annual median PM2.5 (2018-2022)_h3_c.dta", replace


************************************************************	
**# Sea level rise - change in coastal flood depth (90m) #**
************************************************************
	** Note: Sea level rise - change in coastal flood depth (90m): frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 0 cm. 

use "$projectpath\3_results\exposure\Sea level rise - change in coastal flood depth (90m)_h3.dta", clear

collapse (sum) exp_sh exp_pop (first) pop pop_year, by(h3_6 exp_cat)

// Avoid considering observations for <0cm at the h3_6 level 	
replace exp_sh = 0 if exp_cat == 0 
replace exp_pop = 0 if exp_cat == 0	
// Generate share and population exposed for RP100 and >0cm at the h3_6 level
egen se_f100_i0_sh_h3 = total(exp_sh), by(h3_6)		
label var se_f100_i0_sh_h3 "Share of pop exposed to heat RP100 and >0cm at h3_6"
egen se_f100_i0_pop_h3 = total(exp_pop), by(h3_6)
label var se_f100_i0_pop_h3 "Population exposed to heat RP100 and >0cm at h3_6"
	
// Keep one observation per h3_6
bysort h3_6: keep if _n==1

// Edit dababase and label variables
drop exp_cat exp_sh exp_pop
rename pop pop_h3
label var pop_h3 "Population at the h3 level"
rename pop_year pop_year_h3
label var pop_year_h3 "Year of the population at the h3 level"
label var h3_6 "H3 index (hexagonal cells) at resolution 6"

save "$projectpath\3_results\exposure\Sea level rise - change in coastal flood depth (90m)_h3_c.dta", replace


***********************************************************************************
**# Merging harmonized household survey data with exposure data at the h3 level #**
***********************************************************************************

// Open loop for countries
foreach cty in $countries{
*local cty = "NER"

	display in red "`cty'"

	use "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode_exp_h3.dta", clear

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

		// Generate a variable to identify observations without GPS data and without sea level rise exposure data at the h3 level
		gen _m_se_h3obs=1 if _merge==3
		replace _m_se_h3obs=2 if _merge==1 & h3_6==""
		replace _m_se_h3obs=3 if _merge==1 & h3_6!=""
		label var _m_se_h3obs "Obs matched and unmatched with a without h3 data - Sea level rise"
		drop _merge
		
	// Label the categories of all _m variables	
	label def _m_h3obs 1 "Matched" 2 "Unmatched no GPS data" 3 "Unmatched no exposure data", replace
	label val _m_*_h3obs _m_h3obs
	
	// Generate the exposure variable with h3 values (when available) and with the lowest regional level available (otherwise)
	foreach ha in dr fl he po se{
		foreach var of varlist `ha'_*_sh `ha'_*_pop{
			gen `var'_l = `var'_h3
			replace `var'_l = `var' if _m_`ha'_h3obs!=1
			local lbl: variable label `var'
			label var `var'_l "`lbl' at h3 or lowest level"
		}		
	}

	label var h3_6 "H3 index (hexagonal cells) at resolution 6"
	label var h3_7 "H3 index (hexagonal cells) at resolution 7"
	label var gps_lat "GPS latitude coordinates" 
	label var gps_lon "GPS longitude coordinates"
	label var region0 "Country"
	
	// Save household survey data with harmonized socioeconomic and exposure variables at h3 level or lowest available
	save "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode_exp_h3_l.dta", replace	
	
}
	

	



	
/*	After merging the drought exposure data at the h3_6 level:

* Number of observations without h3_6 values (h3_6=="" due to no gps data):
BEN: 0 (0%)
BFA: 325 (0.69%)
CIV: 6,850 (10.62%)
GMB: 0 (0%)
GNB: 903 (2.18%) without GPS data + 203 (0.48%) without exposure data at h3 level. Total: 1,106 (2.66%)
LBR: 1,106 (2.66%)
MLI: 413 (0.99%) without GPS data + 289 (0.69%) without exposure data at h3 level. Total: 702 (1.68%)
MRT: 1,610 (2.66%) without GPS data + 880(1.45%) without exposure data at h3 level. Total: 2,490 (4.11%)
NER: 6,630 (15.04%) without GPS data + 820(1.86%) without exposure data at h3 level. Total: 7,450 (16.90%)
SEN: 3,238 (4.11%)
TCD: 2,258 (5.01%) without GPS data + 366(0.81%) without exposure data at h3 level. Total: 2,624 (5.82%)
TGO: 269 (0.93%)


* Countries without GPS data at all
CAF: 32,368 (100%)
CMR: 49,244 (100%)
CPV: 24,395 (100%)
GHA: 59,864 (100%)
GIN: 41,434 (100%)
LBR: 36,303 (100%)
NGA: 112,564 (100%)
SLE: 40,462 (100%)	
*/


** ME FALTA VER BIEN EL CASO DE MLI Y LAS REGIONES QUE NO TENIAN DATOS, A VER SI COINCIDEN CON LAS QUE TAMPOCO TIENEN GPS Y/O H3.
		* Vi el caso de MLI y es algo que tengo que corregir porque si tienen datos de GPS y de h3, pero no tengo esas observaciones en la base que estoy usando, entonces tengo que revisar lo que hice antes para que esas observaciones queden en la base.
** TAMBIEN TENGO QUE REVISAR SI EFECTIVAMENTE ALGUNAS OBSERVACIONES NO ESTAN EN LOS DATOS DE EXPOSURE H3 O SI ES QUE YO ESTOY HACIENDO ALGO QUE LAS BORRE SIN DARME CUENTA.
		* Revisé y efectivamente hay algunos valores de h3_6 que si están en la encuesta de hogares y no en los archivos de exposure al nivel h3.

* ME FALTA hacer los labels de las variables de exposure (HECHO!) y hacer el cuadro de las variables que hacen merged y las que no (con y sin GPS data) (Eso si está PENDING)

sort hid pid
br hid hhsize pid region1 region2 region3 geo_code code-adm4_name pop-dr_f2p5_i50_pop h3_6-dr_f2p5_i50_pop_h3
br hid hhsize pid geo_code pop-dr_f2p5_i50_pop h3_6-dr_f2p5_i50_pop_h3



	
