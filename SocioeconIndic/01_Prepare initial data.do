*-----------------------------------------------------------------------------
*	Title: Prepare initial data from SSAPOV (datalibweb) and EHCVM data
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: Mar 13, 2025
*-----------------------------------------------------------------------------


*************************************************************
***# Download SSAPOV and EHCVM data to the shared folder #***
*************************************************************
** Latest data accessed and download to shared folder on 8/7/2025

/* Note: This section can be performed just once. All files should be in the shared folder.

// Loop over countries and increase local i 1 by 1 to go over the corresponding year and survey of each country
local i=0
foreach cty in $countries{

	local ++i

	local year : word `i' of $years
	local survey : word `i' of $surveys

	display in red "`cty' - `year' - `survey'"

	***************************
	***# P module - SSAPOV #***

	** Open P module
	dlw, coun(`cty') y(`year') t(SSAPOV) mod(P) sur(`survey')
	
	// Save in shared folder
	save "$data_hhss\\`cty'\\SSAPOV_P_`cty'.dta", replace	

	***************************
	***# H module - SSAPOV #***

	if "`cty'" != "NGA" {
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(H) sur(`survey')
		
		// Save in shared folder
		save "$data_hhss\\`cty'\\SSAPOV_H_`cty'.dta", replace			
	}
	
	***************************
	***# L module - SSAPOV #***

	** Open L module (considering the exceptions: CIV, NGA, TGO)
	if !("`cty'" == "CIV" | "`cty'" == "NGA" | "`cty'" == "TGO"){
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(L) sur(`survey')

		// Save in shared folder
		save "$data_hhss\\`cty'\\SSAPOV_L_`cty'.dta", replace					
	}	

	***************************
	***# I module - SSAPOV #***

	** Open I module (considering the Nigerian - NGA - exception)
	if "`cty'" != "NGA"{
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(I) sur(`survey')

		// Save in shared folder
		save "$data_hhss\\`cty'\\SSAPOV_I_`cty'.dta", replace			
	}

	*****************************
	***# GMD module - SSAPOV #***
	
	if "`cty'" == "CIV" | "`cty'" == "NGA" | "`cty'" == "TGO"{
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(GMD) sur(`survey')
		
		// Save in shared folder
		save "$data_hhss\\`cty'\\SSAPOV_GMD_`cty'.dta", replace	
	}
	
	
	***************************************
	***# Sections 4b, 6 and 15 - EHCVM #***

	** Loop for countries with EHCVM
	if "`survey'" == "EHCVM" & "`cty'" != "CAF"{

		// Consider different path and file name for Chad (TCD) and Guinea (GIN)
		
		***# Section 4b (for contributions to social security)
		if "`cty'" == "TCD"{ 	
			use "$EHCVM2_data\\`cty'\Datain\Menage\Ordinaire\\s04b_me_`cty'_`year'.dta", clear
		}
		else if "`cty'" == "GIN"{ 	
			use "$EHCVM1_data\\`cty'\Datain\\s04_me_`cty'`year'.dta", clear
		}			
		else{
			use "$EHCVM2_data\\`cty'\Datain\Menage\\s04b_me_`cty'`year'.dta", clear
		}

		// Save in shared folder
		save "$data_hhss\\`cty'\\EHCVM_S4b_`cty'.dta", replace	
		
		***# Section 6 (for access to bank account)
		if "`cty'" == "TCD"{
			use "$EHCVM2_data\\`cty'\Datain\Menage\Ordinaire\\s06_me_`cty'_`year'.dta", clear
		}	
		else if "`cty'" == "GIN"{ 	
			use "$EHCVM1_data\\`cty'\Datain\\s06_me_`cty'`year'.dta", clear
		}			
		else{		
			use "$EHCVM2_data\\`cty'\Datain\Menage\\s06_me_`cty'`year'.dta", clear
		}

		// Save in shared folder		
		save "$data_hhss\\`cty'\\EHCVM_S6_`cty'.dta", replace
		
		***# Section 15 (for social transfers)
		if "`cty'" == "TCD"{
			use "$EHCVM2_data\\`cty'\Datain\Menage\Ordinaire\\s15_me_`cty'_`year'.dta", clear
		}	
		else if "`cty'" == "GIN"{ 	
			use "$EHCVM1_data\\`cty'\Datain\\s15_me_`cty'`year'.dta", clear
			drop s15q05
			rename s15q02 s15q05
		}					
		else{
			use "$EHCVM2_data\\`cty'\Datain\Menage\\s15_me_`cty'`year'.dta", clear
		}

		// Save in shared folder
		save "$data_hhss\\`cty'\\EHCVM_S15_`cty'.dta", replace	
		
	}
}	


*******************************************************************************************************
***# Create file with regions and GPS variables from raw data to merge with SSAPOV files for Gabon #***
** Note: This file was created for Gabon because its SSAPOV files were missing regions and GPS variables.	
	
// Open raw data with village and household ID variables
datalibweb, country(GAB) year(2017) type(SSARAW) surveyid(GAB_2017_EGEP_v01_M) filename(MENAGE_REC.dta)

// Save in shared folder
save "$data_hhss\\GAB\\SSARAW_GAB_2017_EGEP_v01_M_MENAGE_REC.dta", replace

// Open Excel file with village codes and names
import excel "$data_hhss\\GAB\\NOMMENCLATURE DES ENTITES ADMINISTRATIVES_2017_BA.xlsx", sheet("CODES_2013") firstrow clear

// Edit variables
*destring Code, replace
rename (PROV_LABEL DEP_LABEL ARR_LABEL PROV_CODE DEP_CODE ARR_CODE) (region1 region2 region3 reg1code reg2code village)

// Save in a temporary file
tempfile vilcode
save `vilcode', replace	

// Open raw data with village and household ID variables
use "$data_hhss\\GAB\\SSARAW_GAB_2017_EGEP_v01_M_MENAGE_REC.dta", clear

// Merge with village code and names
merge m:1 village using `vilcode', nogen keep(match)

// Generate household ID variable to merge with SSAPOV files
gen hid = grappe_cor*100 + menage_cor
tostring hid, replace

// Edit GPS variables
rename (gps_prefill_latitude gps_prefill_longitude) (gps_lat gps_lon)

// Generate empty GPS variables not available
foreach var in loc_id{
	cap gen `var' = .
}
foreach var in loc_type gps_level	gps_mod gps_priv{
	cap gen `var' = ""
}

// Keep the variables we need
keep hid region1 region2 region3 gps_lat gps_lon loc_id loc_type gps_level gps_mod gps_priv 

// Save file
save "$data_hhss\\GAB\\SSARAW_GAB_2017_EGEP_v01_M_MENAGE_REC_mod.dta", replace

*/

***************************************************************************************
***# Prepare initial datasets with harmonized variables from SSAPOV and EHCVM data #***
***************************************************************************************
	
// Loop over countries and increase local i 1 by 1 to go over the corresponding year and survey of each country
local i=0
foreach cty in $countries{

	local ++i

	local year : word `i' of $years
	local survey : word `i' of $surveys

	display in red "`cty' - `year' - `survey'"

	***************************
	***# P module - SSAPOV #***

	** Open P module
	use "$data_hhss\\`cty'\\SSAPOV_P_`cty'.dta", clear

	drop if wta_hh==. // Eliminate observations without weight. Applies to CIV: 728 obs (5.3%), MRT: 3 obs (0.03%). These households are not considered for poverty measurement or any other statistic.
	
	*** Merge with the gps data files (for those available)
		*Countries with GPS data: BEN BFA CIV GMB GNB MLI MRT NER SEN TCD TGO
		*Countries without GPS data: CAF CMR CPV GHA GIN LBR NGA SLE
	
	// Generate household id variable for merging with the GPS files
	if ("`cty'" == "CIV" | "`cty'" == "MLI" | "`cty'" == "NER" | "`cty'" == "SEN"){
		cap gen hhid = hid_orig
	}
	else if ("`cty'" == "GHA"){
		gen hhid = subinstr(hid, "/", "", .)
	}
	else if ("`cty'" == "MRT"){
		cap gen hhid_orig = hid
	}	
	else{
		cap gen hhid = hid
	}
	

	// Merge with the GPS files (for those available)
	if ("`cty'" == "BEN" | "`cty'" == "NER"){
		merge 1:1 hhid using "$data_hhss\\`cty'\\`cty'_2021_EHCVM_V01_M_V01_A_GMD_LOC.dta"
	}
	else if ("`cty'" == "BFA" | "`cty'" == "CIV" | "`cty'" == "GNB" | "`cty'" == "MLI" | "`cty'" == "SEN" | "`cty'" == "TGO"){
		merge 1:1 hhid using "$data_hhss\\`cty'\\`cty'_2021_EHCVM_V01_M_V02_A_GMD_LOC.dta"
	}
	else if ("`cty'" == "GHA"){
		merge 1:1 hhid using "$data_hhss\\`cty'\\`cty'_2016_GLSS-VII_V01_M_V03_A_GMD_LOC.dta"
		destring loc_id, replace
	}
	else if ("`cty'" == "GMB"){
		merge 1:1 hhid using "$data_hhss\\`cty'\\`cty'_2020_IHS_V02_M_V02_A_GMD_LOC.dta"
	}
	else if ("`cty'" == "MRT"){
		merge 1:1 hhid_orig using "$data_hhss\\`cty'\\`cty'_2019_EPCV_V01_M_V01_A_GMD_LOC.dta"
	}
	else if ("`cty'" == "TCD"){
		merge 1:1 hhid using "$data_hhss\\`cty'\\`cty'_2022_EHCVM_V01_M_V01_A_GMD_LOC.dta"
	}
	else if ("`cty'" == "GAB"){
		drop region*
		merge 1:1 hid using "$data_hhss\\`cty'\\SSARAW_GAB_2017_EGEP_v01_M_MENAGE_REC_mod.dta"
	}	
	else{
		gen _merge=.
	}
	
	drop if _m==2 // Eliminate observations only in the LOC file (not in the household survey from SSAPOV). Applies to GMB: 332 obs (2.4%), MRT: 3 obs (0.03%)

	// Generate empty GPS variables for those missing them
	if ("`cty'" == "CAF" | "`cty'" == "CMR" | "`cty'" == "CPV" | "`cty'" == "GIN" | "`cty'" == "LBR" | "`cty'" == "NGA" | "`cty'" == "SLE" | "`cty'" == "GHA"){	// These are the countries without GPS information
		foreach var in loc_id gps_lat gps_lon{
			cap gen `var' = .
		}
		foreach var in loc_type gps_level	gps_mod gps_priv{
			cap gen `var' = ""
		}
	}	

	// Generate variable to identify households considered for poverty measurement
	gen hhpovm = 1
	label var hhpovm "Household consider for poverty measurement = 1"
	
	// Keep only the variables we need and save in temporary file for posterior merges
	keep country year region* subnatidsurvey strata rururb capital cluster hhno hid hid_orig ///
		int_month int_year hhsize ctry_adq wta_hh wta_pop wta_cadq fdtexp nfdtexp hhtexp wel_PPP ///
		icp2017 cpi2017 icp2021 cpi2021 pc_fd pc_hh ///
		loc_id gps_lat gps_lon loc_type gps_level gps_mod gps_priv hhpovm


	label var loc_type  "Location type"
	label var gps_lat   "Latitude (decimal degrees)"
	label var gps_lon   "Longitude (decimal degrees)"
	label var gps_level "Coordinates level"
	label var gps_mod   "Coordinates modified"
	label var gps_priv  "Coordinates privacy"
	
	tempfile `cty'_P
	save ``cty'_P', replace			
	
	***************************
	***# H module - SSAPOV #***

	** Open H module (considering the Nigerian - NGA - exception)
	if "`cty'" == "NGA"{
		// Load GMD file for NGA because there is no H file
		use "$data_hhss\\`cty'\\SSAPOV_GMD_`cty'.dta", clear
		
		// Rename existing variables and generate non-existent variables
		rename (hhid countrycode weight_h tv cooksource) (hid country wta_hh television fuelcook) 

		recode water_source (1=1) (2 3=2) (4 5 6 7=3) (9 10=4) (13=5) (8=6) (11 12=7) (14=8), gen(water8)
		label def water8  1 "1.Piped water -own tap" ///
						2	"2.Public tap or standpipe" ///
						3	"3.Protected well" ///
						4	"4.Unprotected well" ///
						5	"5.Surface water" ///
						6	"6.Rainwater" ///
						7	"7.Tanker-truck/ vendor" ///
						8	"8.Other", replace
		label val water8 water8
		label var water8 "Main source of drinking water (8 categories)"
		
		foreach var in des_mig_1 des_mig_2 des_mig_3 origin_rmt amt_rmt_1 amt_rmt_2 amt_rmt_3 hh_remit{
			gen `var' = .
		}
		
		keep if relationharm == 1 // keep only one observation per household
	}
	else {
		use "$data_hhss\\`cty'\\SSAPOV_H_`cty'.dta", clear
	}

	// Keep only the variables we need and save in temporary file for posterior merges
	keep country hid wta_hh water8 imp_wat_rec w_30 electricity roof wall floor fuelcook ///
		imp_san_rec radio television cellphone fridge computer bcycle mcycle car internet des_mig_*	///
		origin_rmt amt_rmt_1 amt_rmt_2 amt_rmt_3 hh_remit

	// Fixing some observations in GMB with values in hh_remit > 1
	if "`cty'" == "GMB"{
		replace hh_remit = 1 if hh_remit>1 & ((amt_rmt_1>0 & amt_rmt_1!=.) | (amt_rmt_2>0 & amt_rmt_2!=.) | (amt_rmt_3>0 & amt_rmt_3!=.))
		replace hh_remit = 0 if hh_remit>1 & !((amt_rmt_1>0 & amt_rmt_1!=.) | (amt_rmt_2>0 & amt_rmt_2!=.) | (amt_rmt_3>0 & amt_rmt_3!=.))
	}
	
	tempfile `cty'_H
	save ``cty'_H', replace			


	***************************
	***# L module - SSAPOV #***

	** Open L module (considering the exceptions: CIV, NGA, TGO)
	if "`cty'" == "CIV" | "`cty'" == "NGA" | "`cty'" == "TGO"{
		use "$data_hhss\\`cty'\\SSAPOV_GMD_`cty'.dta", clear
		
		rename (countrycode hhid) (country hid) 		
	}
	else {
		use "$data_hhss\\`cty'\\SSAPOV_L_`cty'.dta", clear
	}	

	// Keep only the variables we need and save in temporary file for posterior merges
	keep country hid pid lstatus industrycat4 ocusec contract socialsec

	tempfile `cty'_L
	save ``cty'_L', replace			


	***************************
	***# I module - SSAPOV #***

	** Open I module (considering the Nigerian - NGA - exception)
	if "`cty'" == "NGA"{
		use "$data_hhss\\`cty'\\SSAPOV_GMD_`cty'.dta", clear
		
		rename (hhid countrycode weight_h male age educy school relationharm) (hid country wta_hh sex ageyrs educyrs atschool relathh6)		
	}
	else {
		use "$data_hhss\\`cty'\\SSAPOV_I_`cty'.dta", clear
	}


	// Keep only the variables we need and save in temporary file for posterior merges
	keep country hid wta_hh pid pid_orig sex ageyrs relathh6 educat5 educyrs ///
		atschool eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty

	tempfile `cty'_I
	save ``cty'_I', replace			

	// Merge all files per country and save in temporary file
	use ``cty'_P', clear
	merge 1:1 hid using ``cty'_H', nogen
	merge 1:m hid using ``cty'_L', nogen
	merge 1:1 hid pid using ``cty'_I', nogen 

	// Generate dummy variable to identify individuals considered for poverty measurement
	gen indpovm = (hhpovm==1 & relathh6!=.)
	label var indpovm "Individuals considered for poverty measurement"
	label def indpovm 0 "Not considered for poverty measurement" 1 "Considered for poverty measurement", replace
	label val indpovm indpovm
	
	if "`cty'" == "CPV"{	// There is no information in the relathh6 variable for CPV, but all individuals are considered for poverty measurement. 
		replace indpovm = 1
	}

	tempfile `cty'_pSSAPOV
	save ``cty'_pSSAPOV', replace			
	

	***************************************
	***# Sections 4b, 6 and 15 - EHCVM #***

	** Loop for countries with EHCVM
	if "`survey'" == "EHCVM" & "`cty'" != "CAF"{

		***# Section 4b (for contributions to social security)
		use "$data_hhss\\`cty'\\EHCVM_S4b_`cty'.dta", clear
		
		// Identify household members who contribute to social security
		gen socsec = (s04q38==1) 

		// Collapse file at the household level
		collapse (max) socsec, by(grappe menage)

		// Generate household id variable to merge with SSAPOV file
		if ("`cty'" == "CIV" | "`cty'" == "GIN" | "`cty'" == "NER" | "`cty'" == "SEN" | "`cty'" == "TCD" | "`cty'" == "TGO"){
			gen hid_orig=grappe*100+menage
		}
		else if ("`cty'" == "MLI"){
			gen hid_orig=grappe*1000+menage
		}		
		else if ("`cty'" == "GNB"){
			gen hid=grappe*100+menage
			replace hid=grappe*1000+menage if menage >= 10
		}				
		else{
			gen hid=grappe*1000+menage
		}
		
		// Save in temporary file
		tempfile `cty'_socsec
		save ``cty'_socsec', replace			
		
		
		***# Section 6 (for access to bank account)
		use "$data_hhss\\`cty'\\EHCVM_S6_`cty'.dta", clear
		
		// Identify household members who have access to any bank account and to a mobile bank account
		gen bankacc = (s06q01__1==1 | s06q01__2==1 | s06q01__3==1 | s06q01__4==1 | s06q01__5==1) 
		gen mobbankacc = (s06q01__4==1)

		// Collapse file at the household level
		collapse (max) bankacc mobbankacc, by(grappe menage)

		// Generate household id variable to merge with SSAPOV file
		if ("`cty'" == "CIV" | "`cty'" == "GIN" | "`cty'" == "NER" | "`cty'" == "SEN" | "`cty'" == "TCD" | "`cty'" == "TGO"){
			gen hid_orig=grappe*100+menage
		}
		else if ("`cty'" == "MLI"){
			gen hid_orig=grappe*1000+menage
		}	
		else if ("`cty'" == "GNB"){
			gen hid=grappe*100+menage
			replace hid=grappe*1000+menage if menage >= 10
		}			
		else{
			gen hid=grappe*1000+menage
		}

		// Save in temporary file
		tempfile `cty'_bankacc
		save ``cty'_bankacc', replace			


		***# Section 15 (for social transfers)
		use "$data_hhss\\`cty'\\EHCVM_S15_`cty'.dta", clear
		
		// Identify households that receive social transfers
		gen soctransf = (s15q01==7 & s15q05==1) 

		// Collapse file at the household level
		collapse (max) soctransf, by(grappe menage)

		// Generate household id variable to merge with SSAPOV file
		if ("`cty'" == "CIV" | "`cty'" == "GIN" | "`cty'" == "NER" | "`cty'" == "SEN" | "`cty'" == "TCD" | "`cty'" == "TGO"){
			gen hid_orig=grappe*100+menage
		}
		else if ("`cty'" == "MLI"){
			gen hid_orig=grappe*1000+menage
		}	
		else if ("`cty'" == "GNB"){
			gen hid=grappe*100+menage
			replace hid=grappe*1000+menage if menage >= 10
		}			
		else{
			gen hid=grappe*1000+menage
		}

		// Save in temporary file
		tempfile `cty'_soctransf
		save ``cty'_soctransf', replace	


		***# Open file with SSAPOV variables and merge with additional variables from EHCVM
		if ("`cty'" == "CIV" | "`cty'" == "GIN" | "`cty'" == "MLI" | "`cty'" == "NER" | "`cty'" == "SEN" | "`cty'" == "TCD" | "`cty'" == "TGO"){
			use ``cty'_pSSAPOV', clear
			merge m:1 hid_orig using ``cty'_socsec', nogen 
			merge m:1 hid_orig using ``cty'_bankacc', nogen
			merge m:1 hid_orig using ``cty'_soctransf', nogen
		}
		else{
			use ``cty'_pSSAPOV', clear
			merge m:1 hid using ``cty'_socsec', nogen 
			merge m:1 hid using ``cty'_bankacc', nogen
			merge m:1 hid using ``cty'_soctransf', nogen
		}		

		// Generate variable to identify households in sections 4b, 6 or 15 of the EHCVM survey and not in SSAPOV
		gen onlyehcvm = (indpovm==.)
		label var onlyehcvm "Observations only in EHCVM and not in SSAPOV = 1"

		cap gen survey = "`survey'"
		
		// Save initial data set
		save "$data_hhss\\`cty'\\RS_`cty'.dta", replace
	}
	else {
		// For non-EHCVM countries and CAF, open file with SSAPOV variables and generate additional variables (from EHCVM) with missing, to avoid future conflicts
		use ``cty'_pSSAPOV', clear
		
		gen socsec = . 
		gen bankacc = .
		gen mobbankacc = .	
		gen soctransf = .
		gen onlyehcvm = .
		
		gen survey = "`survey'"
		
		// Save initial data set
		save "$data_hhss\\`cty'\\RS_`cty'.dta", replace
	}

}

**********************************************************************
***# Labeling ID variables that merge with SSAPOV and EHCVM files #***
**********************************************************************

foreach cty in $countries{
	display in red "`cty'" 
	
	use "$data_hhss\\`cty'\\RS_`cty'.dta", clear
	if ("`cty'" == "CIV" | "`cty'" == "GIN" | "`cty'" == "MLI" | "`cty'" == "NER" | "`cty'" == "SEN" | "`cty'" == "TCD" | "`cty'" == "TGO"){
		label var hid_orig "Household identifier (merges with EHCVM)"
		label var hid "Household identifier (merges with SSAPOV)"
		label var pid "Personal identifier (merges with SSAPOV and EHCVM)"		
	}
	else if ("`cty'" == "GNB" | "`cty'" == "BEN" | "`cty'" == "BFA"){
		label var hid "Household identifier (merges with SSAPOV and EHCVM)"
		label var pid "Personal identifier (merges with SSAPOV and EHCVM)"
	}
	else {
		label var hid "Household identifier (merges with SSAPOV)"
		label var pid "Personal identifier (merges with SSAPOV)"
	}

	drop if wta_hh==. // Eliminate observations without weight (not considered for poverty measurement or any other statistic, but present in the SSAPOV modules I or L): GHA(1) GIN(13) GMB(3,991) GNB(14) LBR(5) NER(597)
	
	save "$data_hhss\\`cty'\\RS_`cty'.dta", replace	
}	


