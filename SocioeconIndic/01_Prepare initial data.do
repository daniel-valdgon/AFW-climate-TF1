*---------------------------------------------------------------------------------------------------
*	Title: Prepare initial data from SSAPOV (datalibweb), EHCVM and Nigeria's NLSS 2022/23 survey
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: Mar 13, 2025
*---------------------------------------------------------------------------------------------------

 
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

	drop if wta_hh==. // Eliminate observations without weight. Applies to CIV: 728 obs (5.3%), MRT: 3 obs (0.03%).
	
	*** Merge with the gps data files (for those available)
		*Countries with GPS data: BEN BFA CIV GHA GMB GNB MLI MRT NER SEN TCD TGO
		*Countries without GPS data: CAF CMR CPV GIN LBR NGA SLE
	
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
	
	cap drop if _m==2 // Eliminate observations only in the LOC file (not in the household survey from SSAPOV). Applies to GMB: 332 obs (2.4%), MRT: 3 obs (0.03%)

	// Generate empty GPS variables for those missing them
	if ("`cty'" == "GHA"){	// GHA has a particular set of location variables
		foreach var in gps_lat gps_lon{
			gen `var' = .
		}
		foreach var in gps_level	gps_mod gps_priv{
			gen `var' = ""
		}
	}		
	else if ("`cty'" == "CAF" | "`cty'" == "CMR" | "`cty'" == "CPV" | "`cty'" == "GIN" | "`cty'" == "LBR" | "`cty'" == "NGA" | "`cty'" == "SLE" | "`cty'" == "GHA"){	// These are the countries without GPS information
		foreach var in loc_id gps_lat gps_lon adm_year{
			gen `var' = .
		}
		foreach var in loc_type gps_level	gps_mod gps_priv adm_key adm_name adm_src adm_level{
			gen `var' = ""
		}
	}	
	else{	// This applies to countries with GPS information except for GHA
		foreach var in adm_year{
			gen `var' = .
		}
		foreach var in adm_key adm_name adm_src adm_level{
			gen `var' = ""
		}
	}	

	// Keep only the variables we need and save in temporary file for posterior merges
	keep country year region* subnatidsurvey strata rururb capital cluster hhno hid hid_orig ///
		int_month int_year hhsize ctry_adq wta_hh wta_pop wta_cadq fdtexp nfdtexp hhtexp wel_PPP ///
		icp2017 cpi2017 icp2021 cpi2021 pc_fd pc_hh ///
		loc_id gps_lat gps_lon adm_year loc_type gps_level gps_mod gps_priv adm_key adm_name adm_src adm_level


	label var loc_type  "Location type"
	label var gps_lat   "Latitude (decimal degrees)"
	label var gps_lon   "Longitude (decimal degrees)"
	label var gps_level "Coordinates level"
	label var gps_mod   "Coordinates modified"
	label var gps_priv  "Coordinates privacy"
	label var adm_year  "Map year"
	label var adm_key   "Spatial unit ID for shapefile"
	label var adm_name  "Region name"
	label var adm_src   "Map source"
	label var adm_level "Map level"

	
	tempfile `cty'_P
	save ``cty'_P', replace			
	
	***************************
	***# H module - SSAPOV #***

	** Open H module (considering the Nigerian - NGA - exception)
	if "`cty'" == "NGA"{
		// Load GMD file for NGA because there is no H file
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(GMD) verm(02) vera(02) sur(`survey')
		
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
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(H) sur(`survey')
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

	** Open L module (considering the exceptions: NGA, TGO)
	if "`cty'" == "CIV" | "`cty'" == "NGA" | "`cty'" == "TGO"{
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(GMD) sur(`survey')
		
		rename (countrycode hhid) (country hid) 		
	}
	else {
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(L) sur(`survey')
	}	

	// Keep only the variables we need and save in temporary file for posterior merges
	keep country hid pid lstatus industrycat4 ocusec contract socialsec

	tempfile `cty'_L
	save ``cty'_L', replace			


	***************************
	***# I module - SSAPOV #***

	** Open I module (considering the Nigerian - NGA - exception)
	if "`cty'" == "NGA"{
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(GMD) verm(02) vera(02) sur(`survey')
		
		rename (hhid countrycode weight_h male age educy school) (hid country wta_hh sex ageyrs educyrs atschool)		
	}
	else {
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(I) sur(`survey')
	}


	// Keep only the variables we need and save in temporary file for posterior merges
	keep country hid wta_hh pid pid_orig sex ageyrs educat5 educyrs ///
		atschool eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty

	tempfile `cty'_I
	save ``cty'_I', replace			

	// Merge all files per country and save in temporary file
	use ``cty'_P', clear
	merge 1:1 hid using ``cty'_H', nogen
	merge 1:m hid using ``cty'_L', nogen
	merge 1:1 hid pid using ``cty'_I', nogen 

	drop if year==. // This eliminates observations with no information (year, region, etc.) and not considered in the P file for poverty measurement


	tempfile `cty'_pSSAPOV
	save ``cty'_pSSAPOV', replace			
	

	***************************************
	***# Sections 4b, 6 and 15 - EHCVM #***

	** Loop for countries with EHCVM
	if "`survey'" == "EHCVM" & "`cty'" != "CAF"{


		// Consider different path and file name for Chad (TCD) and Guinea (GIN)
		
		***# Section 4b (for contributions to social security)
		if "`cty'" == "TCD"{ 	
			use "$EHCVM2_data\\`cty'\Datain\Menage\Ordinaire\\s04b_me_`cty'_`year'.dta"
		}
		else if "`cty'" == "GIN"{ 	
			use "$EHCVM1_data\\`cty'\Datain\\s04_me_`cty'`year'.dta"
		}			
		else{
			use "$EHCVM2_data\\`cty'\Datain\Menage\\s04b_me_`cty'`year'.dta"
		}
		
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
		if "`cty'" == "TCD"{
			use "$EHCVM2_data\\`cty'\Datain\Menage\Ordinaire\\s06_me_`cty'_`year'.dta"
		}	
		else if "`cty'" == "GIN"{ 	
			use "$EHCVM1_data\\`cty'\Datain\\s06_me_`cty'`year'.dta"
		}			
		else{		
			use "$EHCVM2_data\\`cty'\Datain\Menage\\s06_me_`cty'`year'.dta", clear
		}
		
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
		if "`cty'" == "TCD"{
			use "$EHCVM2_data\\`cty'\Datain\Menage\Ordinaire\\s15_me_`cty'_`year'.dta"
		}	
		else if "`cty'" == "GIN"{ 	
			use "$EHCVM1_data\\`cty'\Datain\\s15_me_`cty'`year'.dta"
			drop s15q05
			rename s15q02 s15q05
		}					
		else{
			use "$EHCVM2_data\\`cty'\Datain\Menage\\s15_me_`cty'`year'.dta", clear
		}
		
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


		drop if year==. 	// This eliminates observations with no information (year, region, etc.) and not considered in the P file for poverty measurement. Applies to GIN NER GNB	
	
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
		
		gen survey = "`survey'"
		
		// Save initial data set
		save "$data_hhss\\`cty'\\RS_`cty'.dta", replace
	}

}


