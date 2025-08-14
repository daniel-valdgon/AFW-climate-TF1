*--------------------------------------------------------------------
*	Title: Editing exposure data at the h3_6 level 
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: July 25, 2025
*--------------------------------------------------------------------

/*
Note: We use the following hazards and thresholds, based on what was done for the vision indicators and the paper Hill et al (2025):

- Agricultural drought: frequency: AEP2.5 (1-in-40 year event); and Intensity: More than 30% of land affected (Second option: More than 50% of land affected).

- Flood - any (90m): frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 50cm inundation depth (Second and third options: More than 15cm and more than 100cm inundation depth).

- Heat - 5-day mean maximum daily ESI: frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 33°C (Second option: More than 32°C).

- Air pollution - annual median PM2.5 (2018-2022): frequency: P50(2018-2022); and Intensity: More than 25 µg/m3 (classified as unhealthy or worse by WHO Air Quality Guidelines, 2021) (Second option: More than 35 µg/m3)

- Sea level rise - change in coastal flood depth (90m): frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 0 cm.

*/



*************************************************************************************
**# Collapsing and editing exposure data at the h3_6 level for posterior mergings #**
*************************************************************************************

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
label var dr_f2p5_i30_sh_h3 "Share of pop exposed to drought AEP2.5 and >30% land affected at h3_6 (vision indicator)"
egen dr_f2p5_i30_pop_h3 = total(exp_pop), by(h3_6)
label var dr_f2p5_i30_pop_h3 "Population exposed to drought AEP2.5 and >30% land affected at h3_6 (vision indicator)"

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
label var h3_6 "H3 index (hexagonal cells) at resolution 6 (merges with hhss h3 data)"

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
label var fl_f100_i50_sh_h3 "Share of pop exposed to flood RP100 and >50cm inundation depth at h3_6 (vision indicator)"
egen fl_f100_i50_pop_h3 = total(exp_pop), by(h3_6)
label var fl_f100_i50_pop_h3 "Population exposed to flood RP100 and >50cm inundation depth at h3_6 (vision indicator)"
	
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
label var h3_6 "H3 index (hexagonal cells) at resolution 6 (merges with hhss h3 data)"

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
label var he_f100_i33_sh_h3 "Share of pop exposed to heat RP100 and >33°C at h3_6 (vision indicator)"
egen he_f100_i33_pop_h3 = total(exp_pop), by(h3_6)
label var he_f100_i33_pop_h3 "Population exposed to heat RP100 and >33°C at h3_6 (vision indicator)"

// Keep one observation per h3_6
bysort h3_6: keep if _n==1

// Edit dababase and label variables
drop exp_cat exp_sh exp_pop
rename pop pop_h3
label var pop_h3 "Population at the h3 level"
rename pop_year pop_year_h3
label var pop_year_h3 "Year of the population at the h3 level"
label var h3_6 "H3 index (hexagonal cells) at resolution 6 (merges with hhss h3 data)"

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
label var h3_6 "H3 index (hexagonal cells) at resolution 6 (merges with hhss h3 data)"

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
label var se_f100_i0_sh_h3 "Share of pop exposed to sea level rise RP100 and >0cm at h3_6"
egen se_f100_i0_pop_h3 = total(exp_pop), by(h3_6)
label var se_f100_i0_pop_h3 "Population exposed to sea level rise RP100 and >0cm at h3_6"
	
// Keep one observation per h3_6
bysort h3_6: keep if _n==1

// Edit dababase and label variables
drop exp_cat exp_sh exp_pop
rename pop pop_h3
label var pop_h3 "Population at the h3 level"
rename pop_year pop_year_h3
label var pop_year_h3 "Year of the population at the h3 level"
label var h3_6 "H3 index (hexagonal cells) at resolution 6 (merges with hhss h3 data)"

save "$projectpath\3_results\exposure\Sea level rise - change in coastal flood depth (90m)_h3_c.dta", replace

	
