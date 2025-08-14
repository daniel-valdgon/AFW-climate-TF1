

// Open exposure data
use "$data_hhss//exp_all.dta", clear

* Encode string variables used in reshape
encode hazard, gen(hazard_id)
encode freq, gen(freq_id)
encode dou, gen(dou_id)
encode exp_lab, gen(exp_lab_id)

* Create a unique stub name for reshaping
gen stub = "h" + string(hazard_id) + "_f" + string(freq_id) + "_d" + string(dou_id) + "_e" + string(exp_lab_id)

keep geo_code pop pop_year exp_sh exp_pop stub
* Reshape to wide format
reshape wide exp_sh exp_pop, i(geo_code) j(stub) string

* Step 4: Drop helper variables if needed
drop hazard_id freq_id dou_id exp_cat_id stub


/*
. tab hazard_id

                              hazard_id |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
1                   Agricultural drought |    146,815        2.68        2.68
2        Agricultural drought - cropland |    143,830        2.62        5.30
3       Agricultural drought - grassland |    143,421        2.62        7.92
4 Air pollution - annual median PM2.5 (20 |     31,733        0.58        8.50
5              Drought - days VPD > 2kPa |     91,076        1.66       10.16
6              Drought - days VPD > 3kPa |     88,268        1.61       11.77
7                     Flood - any (450m) |    505,774        9.23       21.00
8                      Flood - any (90m) |    471,330        8.60       29.60
9                     Flood - any (990m) |    466,286        8.51       38.10
10      Flood - coastal undefended (450m) |    107,754        1.97       40.07
11       Flood - coastal undefended (90m) |    104,197        1.90       41.97
12      Flood - coastal undefended (990m) |    110,328        2.01       43.98
13      Flood - fluvial undefended (450m) |    307,410        5.61       49.59
14       Flood - fluvial undefended (90m) |    282,847        5.16       54.75
15      Flood - fluvial undefended (990m) |    317,464        5.79       60.54
16        Flood - pluvial defended (450m) |    469,389        8.56       69.10
17         Flood - pluvial defended (90m) |    427,342        7.80       76.90
18        Flood - pluvial defended (990m) |    437,316        7.98       84.88
19    Heat - 5-day mean maximum daily ESI |    149,803        2.73       87.61
20                 Heat - days Tmax > 30C |     87,811        1.60       89.21
21               Heat - days Tmax > 40.6C |     86,565        1.58       90.79
22              Heat - days WBGTmax > 28C |     97,796        1.78       92.58
23              Heat - days WBGTmax > 30C |     98,272        1.79       94.37
24  Sea level rise - change in coastal floo |    103,137        1.88       96.25
25  Sea level rise - change in coastal floo |    101,567        1.85       98.10
26  Sea level rise - change in coastal floo |    103,910        1.90      100.00
----------------------------------------+-----------------------------------
                                  Total |  5,481,441      100.00

The unde-fended fluvial flood data is used for the indicator.

I decided to use the following hazards and thresholds, based on what was done for the vision indicators and the paper Hill et al (2025):

- 1 Agricultural drought: frequency: AEP2.5 (1-in-40 year event); and Intensity: More than 30% of land affected (Second option: More than 50% of land affected).

- 8 Flood - any (90m): frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 50cm inundation depth (Second option: More than 100cm inundation depth).

- 19 Heat - 5-day mean maximum daily ESI: frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 33°C (Second option: More than 32°C).

- 4 Air pollution - annual median PM2.5 (2018-2022): frequency: P50(2018-2022); and Intensity: More than 25 µg/m3 (classified as unhealthy or worse by WHO Air Quality Guidelines, 2021) (Second option: More than 25 µg/m3)

- 25 Sea level rise - change in coastal flood depth (90m): frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 50cm inundation depth.


*/



// Open household survey data with geocode variables
use "$data_hhss\\BEN\\RS_BEN_se_geocode.dta", clear

// Import 
import excel using "$projectpath\3_results\exposure\Agricultural drought.xlsx", sheet("AFW_admin2_DoU") firstrow clear

// Keep observations of the country we need
keep if code=="BEN"

// Encode the string variables we need for the reshape





* Encode string variables used in reshape
encode freq, gen(freq_id)
encode dou, gen(dou_id)
encode exp_lab, gen(exp_lab_id)

* Create a unique stub name for reshaping
gen stub = "Agdr" + "_f" + string(freq_id) + "_d" + string(dou_id) + "_e" + string(exp_lab_id)

keep adm2_pcode pop pop_year exp_sh exp_pop stub

* Reshape to wide format
reshape wide pop exp_sh exp_pop, i(adm2_pcode) j(stub) string


*** HASTA AQUI ESTABA PROBANDO COSAS. CREO QUE DEBO DEJAR LO ANTERIOR A ESTE PUNTO EN UN DOFILE DE BORRADOR, Y DE AQUI PARA ABAJO COMO EL DEFINITIVO (con excepcion del comentario en el que defino los thresholds y los hazards que utilizo).


***********************************************************************************
**# Import exposure data at the lowest available level in the household surveys #**
***********************************************************************************

/* This is the lowest available level in the household surveys per country:
	Admin1: CPV	
	Admin2: BEN CAF CIV GHA GIN GMB GNB LBR MRT NER NGA SEN SLE TCD TGO	
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
	label var dr_f2p5_i30_sh "Share of pop exposed to drought AEP2.5 and >30% land affected"
	egen dr_f2p5_i30_pop = total(exp_pop), by(geo_code)
	label var dr_f2p5_i30_pop "Population exposed to drought AEP2.5 and >30% land affected"
	
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
	
	// Collapse to have one observation per geo_code
	*collapse (first) exp_sh exp_pop (first) code adm* pop_year, by(geo_code) 

	tempfile ag`l'
	save `ag`l'', replace
}

// Append all file 
use `ag3', clear
append using `ag2'
append using `ag1'

// Drop the variables we don't need anymore
drop exp_cat exp_lab exp_sh exp_pop


// Save file
save "$projectpath\3_results\exposure\Agricultural drought - AEP2p5.dta", replace


*************************	
**# Flood - any (90m) #**
*************************
	** Note: Flood - any (90m): Frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 50cm inundation depth (Second option: More than 100cm inundation depth). 

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
	
	// Avoid considering observations for <50cm inundation depth 	
	replace exp_sh = 0 if inlist(exp_cat, 0,1) 
	replace exp_pop = 0 if inlist(exp_cat, 0,1)	
	// Generate share and population exposed for RP100 and >50cm
	egen fl_f100_i15_sh = total(exp_sh), by(geo_code)		
	label var fl_f100_i15_sh "Share of pop exposed to flood RP100 and >15cm inundation depth"
	egen fl_f100_i15_pop = total(exp_pop), by(geo_code)
	label var fl_f100_i15_pop "Population exposed to flood RP100 and >15cm inundation depth"	
		
	// Avoid considering observations for <50cm inundation depth 	
	replace exp_sh = 0 if exp_cat == 2 
	replace exp_pop = 0 if exp_cat == 2	
	// Generate share and population exposed for RP100 and >50cm
	egen fl_f100_i50_sh = total(exp_sh), by(geo_code)		
	label var fl_f100_i50_sh "Share of pop exposed to flood RP100 and >50cm inundation depth"
	egen fl_f100_i50_pop = total(exp_pop), by(geo_code)
	label var fl_f100_i50_pop "Population exposed to flood RP100 and >50cm inundation depth"
	
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


// Save file
save "$projectpath\3_results\exposure\Flood - any (90m) - RP100.dta", replace


*******************************************	
**# Heat - 5-day mean maximum daily ESI #**
*******************************************
	** Note: Heat - 5-day mean maximum daily ESI: frequency: RP100 (1 in 100 chance of occurring in any given year); and Intensity: More than 33°C (Second option: More than 35°C). 

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
	label var he_f100_i33_sh "Share of pop exposed to heat RP100 and >33°C"
	egen he_f100_i33_pop = total(exp_pop), by(geo_code)
	label var he_f100_i33_pop "Population exposed to heat RP100 and >33°C"
	

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
	
	// Avoid considering observations for 25 µg/m3 	
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
	label var se_f100_i0_sh "Share of pop exposed to heat RP100 and >0cm"
	egen se_f100_i0_pop = total(exp_pop), by(geo_code)
	label var se_f100_i0_pop "Population exposed to heat RP100 and >0cm"
	
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


// Save file
save "$projectpath\3_results\exposure\Sea level rise - change in coastal flood depth (90m) - RP100.dta", replace



*******************************************************************
**# Merging harmonized household survey data with exposure data #**
*******************************************************************


// Open loop for countries
foreach cty in $countries{

	display in red "`cty'"
	
	// Open household survey data with harmonized socioeconomic variables
	use "$data_hhss\\`cty'\\RS_`cty'_se_geocode.dta", clear

	display in red "Drought"
	
	// Merge the drought exposure data
	merge m:1 geo_code using "$projectpath\3_results\exposure\Agricultural drought - AEP2p5.dta", nogen keep(match master)
		// Note: There is only one region in NGA without drought data (NG009005 - Bakassi): 39 observations

	display in red "Flood"
	
	// Merge the flood exposure data
	merge m:1 geo_code using "$projectpath\3_results\exposure\Flood - any (90m) - RP100.dta", nogen keep(match master)
		// Note: There is only one region in NGA without flood exposure data (NG009005 - Bakassi): 39 observations

	display in red "Heat"
	
	// Merge the heat exposure data
	merge m:1 geo_code using "$projectpath\3_results\exposure\Heat - 5-day mean maximum daily ESI - RP100.dta", nogen keep(match master)
		// Note: There is only one region in NGA without heat exposure data (NG009005 - Bakassi): 39 observations

	display in red "Air pollution"
	
	// Merge the air pollution exposure data
	merge m:1 geo_code using "$projectpath\3_results\exposure\Air pollution - annual median PM2.5 (2018-2022).dta", nogen keep(match master)
		// Note: There is only one region in NGA without air pollution data (NG009005 - Bakassi): 39 observations

	display in red "Sea level rise"
	
	// Merge the sea level rise exposure data
	merge m:1 geo_code using "$projectpath\3_results\exposure\Sea level rise - change in coastal flood depth (90m) - RP100.dta", nogen keep(match master)
		// Note: Some countries do not have sea level rise data (because they are landlocked or there is no sea level rise information for all regions): BFA, CMR, MRT, NGA, TCD.  		

	// Save household survey data with harmonized socioeconomic and exposure variables
	save "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode_exp.dta", replace

}


** AQUI VOY! TENGO QUE LIMPIAR ESTE DOFILE Y DESPUES MIRAR LO DE H3.


***********************
**# Generating maps #**
***********************


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
