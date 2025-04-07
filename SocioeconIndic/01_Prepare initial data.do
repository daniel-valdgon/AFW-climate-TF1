*---------------------------------------------------------------------------------------------------
*	Title: Prepare initial data from SSAPOV (datalibweb), EHCVM and Nigeria's NLSS 2022/23 survey
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: Mar 13, 2025
*   Last updated : Mar 15, 2025 by Bernardo Atuesta
*---------------------------------------------------------------------------------------------------

*Set Directories

* Bernardo Atuesta
if inlist("`c(username)'","wb384997") {
	// Project paths
	global userpath "C:\Users\wb384997\OneDrive - WBG\Documents" // CHANGE
	global projectpath "$userpath\Climate Change\Regional study on Exposure to shocks\Shared folders\West_Africa_Exposure" // CHANGE
	global data_hhss "$projectpath\1_data\Household_survey"
	
	// Additional paths
	global EHCVM2_data "$userpath\EHCVM2022\Shared folders\EHCVM2"  
	global EHCVM1_data "$userpath\West Africa BA\Data\EHCVM2018"  
}

// Set globals for the countries in SSAPOV with admin2 regions available
global countries "BEN   BFA 	 CAF   CIV 	 CMR 	CPV  GHA	  GIN   GMB  GNB   LBR  MLI   MRT  NER   NGA 	 SEN   SLE   TCD   TGO"
global years 	"2021  2021  2021  2021  2021 	2015 2016	  2018  2020 2021  2016 2021  2019 2021  2018    2021  2018  2022  2021"
global surveys 	"EHCVM EHCVM EHCVM EHCVM ECAM-V IDRF GLSS-VII EHCVM IHS  EHCVM HIES EHCVM EPCV EHCVM GHSP-W4 EHCVM SLIHS EHCVM EHCVM"

 
// Loop over countries and increase local i 1 by 1 to go over the corresponding year and survey of each country
local i=0
foreach cty in $countries{

	local ++i

	local year : word `i' of $years
	local survey : word `i' of $surveys

	display in red "`cty' - `year' - `survey'"

	
	***************************
	***# P module - SSAPOV #***

	** Open P module (considering the Nigerian - NGA - exception)
	if "`cty'" == "NGA"{
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(P) sur(`survey') verm(01) vera(02) 
	}
	else {
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(P) sur(`survey')
	}

	// Keep only the variables we need and save in temporary file for posterior merges
	keep country year region* subnatidsurvey strata rururb capital cluster hhno hid hid_orig ///
		int_month int_year hhsize ctry_adq wta_hh wta_pop wta_cadq fdtexp nfdtexp hhtexp wel_PPP ///
		icp2017 cpi2017 pc_fd pc_hh
	
	tempfile `cty'_P
	save ``cty'_P', replace			


	***************************
	***# H module - SSAPOV #***

	** Open H module (considering the Nigerian - NGA - exception)
	if "`cty'" == "NGA"{
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(H) sur(`survey') verm(01) vera(02) 
	}
	else {
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(H) sur(`survey')
	}

	// Keep only the variables we need and save in temporary file for posterior merges
	keep country hid wta_hh water8 imp_wat_rec w_30 electricity roof wall floor fuelcook ///
		imp_san_rec radio television cellphone fridge computer bcycle mcycle car internet des_mig_*	///
		origin_rmt amt_rmt_1 amt_rmt_2 amt_rmt_3 dispsch	disheal hh_remit

	tempfile `cty'_H
	save ``cty'_H', replace			


	***************************
	***# L module - SSAPOV #***

	** Open L module (considering the Nigerian - NGA - exception)
	if "`cty'" == "NGA"{
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(L) sur(`survey') verm(01) vera(02) 
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
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(I) sur(`survey') verm(01) vera(02) 
	}
	else {
		dlw, coun(`cty') y(`year') t(SSAPOV) mod(I) sur(`survey')
	}

	// Keep only the variables we need and save in temporary file for posterior merges
	keep country hid wta_hh pid pid_orig sex ageyrs relathhcs relathh9 marital6 educat5 educyrs ///
		atschool eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty

	tempfile `cty'_I
	save ``cty'_I', replace			

	// Merge all files per country and save in temporary file
	use ``cty'_P', clear
	merge 1:1 country hid using ``cty'_H', nogen
	merge 1:m country hid using ``cty'_L', nogen
	merge 1:m country hid pid using ``cty'_I', nogen keep(match)

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
		gen hid=grappe*1000+menage

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
		gen hid=grappe*1000+menage

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
		gen hid=grappe*1000+menage

		// Save in temporary file
		tempfile `cty'_soctransf
		save ``cty'_soctransf', replace	


		***# Open file with SSAPOV variables and merge with additional variables from EHCVM
		use ``cty'_pSSAPOV', clear
		merge m:1 hid using ``cty'_socsec', nogen
		merge m:1 hid using ``cty'_bankacc', nogen
		merge m:1 hid using ``cty'_soctransf', nogen
		
		gen survey = "`survey'"
		
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

