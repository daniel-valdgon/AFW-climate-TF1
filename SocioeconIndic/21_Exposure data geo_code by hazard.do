*------------------------------------------------------------------------------------
*	Title: Generate exposure data at the lowest regional level available (geo_code) 
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: June 23, 2025
*------------------------------------------------------------------------------------

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


****************************	
**# Agricultural drought #**
****************************
** Note: Frequency: AEP2.5 (1-in-40 year event); and Intensity: More than 30% of land affected (Second option: More than 50% of land affected).

foreach ad in admin1 admin2 adminX{

	// Import 
	import excel using "$projectpath\3_results\exposure\Agricultural drought.xlsx", sheet("AFW_`ad'") firstrow clear

	// Keep countries with admin`l' as the lowest available level in the household surveys
    if "`ad'"=="admin1" {
        keep if inlist(code, "CPV")
		local l = 1
    }
    else if "`ad'"=="admin2" {
        drop if inlist(code, "CPV", "BFA", "CMR", "MLI")
		local l = 2
    }
    else if "`ad'"=="adminX" {
        keep if inlist(code, "BFA", "CMR", "MLI")
		local l = 3
    }

	// Generate geographic code
	cap gen geo_code = adm`l'_pcod

	// Generate two drought variables frequency AEP2.5 and intensity thresholds >30% and >50%
	keep if freq == "AEP2.5" 	// Keep the threshold of frequency we need
	// Avoid considering observations for <30% land affected 	
	replace exp_sh = 0 if exp_cat==0 
	replace exp_pop = 0 if exp_cat==0	
	// Generate share and population exposed for AEP2.5 and >30%
	egen dr_f2p5_i30_sh = total(exp_sh), by(geo_code)		
	label var dr_f2p5_i30_sh "Share of pop exposed to drought AEP2.5 and >30% land affected (vision indicator)"
	egen dr_f2p5_i30_pop = total(exp_pop), by(geo_code)
	label var dr_f2p5_i30_pop "Population exposed to drought AEP2.5 and >30% land affected (vision indicator)"
	
	// Avoid considering observations for <50% land affected 		
	replace exp_sh = 0 if exp_cat==1  
	replace exp_pop = 0 if exp_cat==1  
	// Generate share and population exposed for AEP2.5 and >50%
	egen dr_f2p5_i50_sh = total(exp_sh), by(geo_code)
	label var dr_f2p5_i50_sh "Share of pop exposed to drought AEP2.5 and >50% land affected"	
	egen dr_f2p5_i50_pop = total(exp_pop), by(geo_code)
	label var dr_f2p5_i50_pop "Population exposed to drought AEP2.5 and >50% land affected"	
	
	// Keep one observation per geo_code
	bysort geo_code: keep if _n==1
	
	tempfile ag`l'
	save `ag`l'', replace
}

// Append all file 
use `ag3', clear
append using `ag2'
append using `ag1'

// Drop the variables we don't need anymore
drop exp_cat exp_lab exp_sh exp_pop

// Label variables without label
label var geo_code "Lowest regional level available hhss (merges with hhss geo_code data)"	
label var pop "Population"
label var pop_year "Population year"
label var freq "Hazard frequency"

// Save file
save "$projectpath\3_results\exposure\Agricultural drought - AEP2p5.dta", replace


*************************	
**# Flood - any (90m) #**
*************************
	** Note: Flood - any (90m): Frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 50cm inundation depth (Second and third options: More than 15cm and more than 100cm inundation depth). 

foreach ad in admin1 admin2 adminX{

	// Import 
	import excel using "$projectpath\3_results\exposure\Flood - any (90m).xlsx", sheet("AFW_`ad'") firstrow clear

	// Keep countries with admin`l' as the lowest available level in the household surveys
    if "`ad'"=="admin1" {
        keep if inlist(code, "CPV")
		local l = 1
    }
    else if "`ad'"=="admin2" {
        drop if inlist(code, "CPV", "BFA", "CMR", "MLI")
		local l = 2
    }
    else if "`ad'"=="adminX" {
        keep if inlist(code, "BFA", "CMR", "MLI")
		local l = 3
    }

	// Generate geographic code
	cap gen geo_code = adm`l'_pcode

	// Generate two flood variables frequency RP100 and intensity thresholds >50cm and >100cm
	keep if freq == "RP100" 	// Keep the threshold of frequency we need
	
	// Avoid considering observations for <15cm inundation depth 	
	replace exp_sh = 0 if inlist(exp_cat, 0,1) 
	replace exp_pop = 0 if inlist(exp_cat, 0,1)	
	// Generate share and population exposed for RP100 and >15cm
	egen fl_f100_i15_sh = total(exp_sh), by(geo_code)		
	label var fl_f100_i15_sh "Share of pop exposed to flood RP100 and >15cm inundation depth"
	egen fl_f100_i15_pop = total(exp_pop), by(geo_code)
	label var fl_f100_i15_pop "Population exposed to flood RP100 and >15cm inundation depth"	
		
	// Avoid considering observations for <50cm inundation depth 	
	replace exp_sh = 0 if exp_cat == 2 
	replace exp_pop = 0 if exp_cat == 2	
	// Generate share and population exposed for RP100 and >50cm
	egen fl_f100_i50_sh = total(exp_sh), by(geo_code)		
	label var fl_f100_i50_sh "Share of pop exposed to flood RP100 and >50cm inundation depth (vision indicator)"
	egen fl_f100_i50_pop = total(exp_pop), by(geo_code)
	label var fl_f100_i50_pop "Population exposed to flood RP100 and >50cm inundation depth (vision indicator)"
	
	// Avoid considering observations for <100cm inundation depth	
	replace exp_sh = 0 if exp_cat==3  
	replace exp_pop = 0 if exp_cat==3  
	// Generate share and population exposed for RP100 and >100cm
	egen fl_f100_i100_sh = total(exp_sh), by(geo_code)		
	label var fl_f100_i100_sh "Share of pop exposed to flood RP100 and >100cm inundation depth"
	egen fl_f100_i100_pop = total(exp_pop), by(geo_code)
	label var fl_f100_i100_pop "Population exposed to flood RP100 and >100cm inundation depth"
	
	// Keep one observation per geo_code
	bysort geo_code: keep if _n==1
	
	tempfile ag`l'
	save `ag`l'', replace
}

// Append all file 
use `ag3', clear
append using `ag2'
append using `ag1'

// Drop the variables we don't need anymore
drop exp_cat exp_lab exp_sh exp_pop

// Label variables without label
label var geo_code "Lowest regional level available hhss (merges with hhss geo_code data)"	
label var pop "Population"
label var pop_year "Population year"
label var freq "Hazard frequency"

// Save file
save "$projectpath\3_results\exposure\Flood - any (90m) - RP100.dta", replace


*******************************************	
**# Heat - 5-day mean maximum daily ESI #**
*******************************************
	** Note: Heat - 5-day mean maximum daily ESI: frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 33°C (Second option: More than 32°C). 

foreach ad in admin1 admin2 adminX{

	// Import 
	import excel using "$projectpath\3_results\exposure\Heat - 5-day mean maximum daily ESI.xlsx", sheet("AFW_`ad'") firstrow clear

	// Keep countries with admin`l' as the lowest available level in the household surveys
    if "`ad'"=="admin1" {
        keep if inlist(code, "CPV")
		local l = 1
    }
    else if "`ad'"=="admin2" {
        drop if inlist(code, "CPV", "BFA", "CMR", "MLI")
		local l = 2
    }
    else if "`ad'"=="adminX" {
        keep if inlist(code, "BFA", "CMR", "MLI")
		local l = 3
    }

	// Generate geographic code
	cap gen geo_code = adm`l'_pcode

	// Generate two flood variables frequency RP100 and intensity thresholds >50cm and >100cm
	keep if freq == "RP100" 	// Keep the threshold of frequency we need

	// Avoid considering observations for <32°C 	
	replace exp_sh = 0 if inlist(exp_cat, 0,1,2) 
	replace exp_pop = 0 if inlist(exp_cat, 0,1,2)	
	// Generate share and population exposed for RP100 and >32°C
	egen he_f100_i32_sh = total(exp_sh), by(geo_code)		
	label var he_f100_i32_sh "Share of pop exposed to heat RP100 and >32°C"
	egen he_f100_i32_pop = total(exp_pop), by(geo_code)
	label var he_f100_i32_pop "Population exposed to heat RP100 and >32°C"
	
	// Avoid considering observations for <33°C 	
	replace exp_sh = 0 if exp_cat == 3 
	replace exp_pop = 0 if exp_cat == 3	
	// Generate share and population exposed for RP100 and >33°C
	egen he_f100_i33_sh = total(exp_sh), by(geo_code)		
	label var he_f100_i33_sh "Share of pop exposed to heat RP100 and >33°C (vision indicator)"
	egen he_f100_i33_pop = total(exp_pop), by(geo_code)
	label var he_f100_i33_pop "Population exposed to heat RP100 and >33°C (vision indicator)"
	

	// Keep one observation per geo_code
	bysort geo_code: keep if _n==1
	
	tempfile ag`l'
	save `ag`l'', replace
}

// Append all file 
use `ag3', clear
append using `ag2'
append using `ag1'

// Drop the variables we don't need anymore
drop exp_cat exp_lab exp_sh exp_pop

// Label variables without label
label var geo_code "Lowest regional level available hhss (merges with hhss geo_code data)"	
label var pop "Population"
label var pop_year "Population year"
label var freq "Hazard frequency"

// Save file
save "$projectpath\3_results\exposure\Heat - 5-day mean maximum daily ESI - RP100.dta", replace


*******************************************************	
**# Air pollution - annual median PM2.5 (2018-2022) #**
*******************************************************
	** Note: Air pollution - annual median PM2.5 (2018-2022): frequency: P50(2018-2022); and Intensity: More than 25 µg/m3 (classified as unhealthy or worse by WHO Air Quality Guidelines, 2021) (Second option: More than 35 µg/m3) 

foreach ad in admin1 admin2 adminX{

	// Import 
	import excel using "$projectpath\3_results\exposure\Air pollution - annual median PM2.5 (2018-2022).xlsx", sheet("AFW_`ad'") firstrow clear

	// Keep countries with admin`l' as the lowest available level in the household surveys
    if "`ad'"=="admin1" {
        keep if inlist(code, "CPV")
		local l = 1
    }
    else if "`ad'"=="admin2" {
        drop if inlist(code, "CPV", "BFA", "CMR", "MLI")
		local l = 2
    }
    else if "`ad'"=="adminX" {
        keep if inlist(code, "BFA", "CMR", "MLI")
		local l = 3
    }

	// Generate geographic code
	cap gen geo_code = adm`l'_pcode

	// No need to keep a level of frequency because we have only one: P50 (2018-2022)
	
	// Avoid considering observations for <25 µg/m3 	
	replace exp_sh = 0 if inlist(exp_cat, 1,2,3) 
	replace exp_pop = 0 if inlist(exp_cat, 1,2,3)	
	// Generate share and population exposed for P50 and >25 µg/m3
	egen po_f50_i25_sh = total(exp_sh), by(geo_code)		
	label var po_f50_i25_sh "Share of pop exposed to air pollution P50 and 25 µg/m3"
	egen po_f50_i25_pop = total(exp_pop), by(geo_code)
	label var po_f50_i25_pop "Population exposed to air pollution P50 and 25 µg/m3"
	
	// Avoid considering observations for <35 µg/m3 	
	replace exp_sh = 0 if exp_cat == 4 
	replace exp_pop = 0 if exp_cat == 4	
	// Generate share and population exposed for P50 and >35 µg/m3
	egen po_f50_i35_sh = total(exp_sh), by(geo_code)		
	label var po_f50_i35_sh "Share of pop exposed to air pollution P50 and 35 µg/m3"
	egen po_f50_i35_pop = total(exp_pop), by(geo_code)
	label var po_f50_i35_pop "Population exposed to air pollution P50 and 35 µg/m3"
	

	// Keep one observation per geo_code
	bysort geo_code: keep if _n==1
	
	tempfile ag`l'
	save `ag`l'', replace
}

// Append all file 
use `ag3', clear
append using `ag2'
append using `ag1'

// Drop the variables we don't need anymore
drop exp_cat exp_lab exp_sh exp_pop

// Label variables without label
label var geo_code "Lowest regional level available hhss (merges with hhss geo_code data)"	
label var pop "Population"
label var pop_year "Population year"
label var freq "Hazard frequency"

// Save file
save "$projectpath\3_results\exposure\Air pollution - annual median PM2.5 (2018-2022).dta", replace


************************************************************	
**# Sea level rise - change in coastal flood depth (90m) #**
************************************************************
	** Note: Sea level rise - change in coastal flood depth (90m): frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 0 cm. 

foreach ad in admin1 admin2 adminX{

	// Import 
	import excel using "$projectpath\3_results\exposure\Sea level rise - change in coastal flood depth (90m).xlsx", sheet("AFW_`ad'") firstrow clear

	// Keep countries with admin`l' as the lowest available level in the household surveys
    if "`ad'"=="admin1" {
        keep if inlist(code, "CPV")
		local l = 1
    }
    else if "`ad'"=="admin2" {
        drop if inlist(code, "CPV", "BFA", "CMR", "MLI")
		local l = 2
    }
    else if "`ad'"=="adminX" {
        keep if inlist(code, "BFA", "CMR", "MLI")
		local l = 3
    }

	// Generate geographic code
	cap gen geo_code = adm`l'_pcode

	// Generate one sea level rise variable frequency RP100 and intensity threshold >0cm
	keep if freq == "RP100" 	// Keep the threshold of frequency we need

	// Avoid considering observations for <0cm 	
	replace exp_sh = 0 if exp_cat == 0 
	replace exp_pop = 0 if exp_cat == 0	
	// Generate share and population exposed for RP100 and >0cm
	egen se_f100_i0_sh = total(exp_sh), by(geo_code)		
	label var se_f100_i0_sh "Share of pop exposed to sea level rise RP100 and >0cm"
	egen se_f100_i0_pop = total(exp_pop), by(geo_code)
	label var se_f100_i0_pop "Population exposed to sea level rise RP100 and >0cm"
	
	// Keep one observation per geo_code
	bysort geo_code: keep if _n==1
	
	tempfile ag`l'
	save `ag`l'', replace
}

// Append all file 
use `ag3', clear
append using `ag2'
append using `ag1'

// Drop the variables we don't need anymore
drop exp_cat exp_lab exp_sh exp_pop

// Label variables without label
label var geo_code "Lowest regional level available hhss (merges with hhss geo_code data)"	
label var pop "Population"
label var pop_year "Population year"
label var freq "Hazard frequency"

// Save file
save "$projectpath\3_results\exposure\Sea level rise - change in coastal flood depth (90m) - RP100.dta", replace


