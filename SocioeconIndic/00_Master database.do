*-----------------------------------------------------------------------------------------------------------------------------------
*	Title: Master file to generate a database with harmonized socioeconomic indicators and climate exposure data for SSA countries
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: Aug 1, 2025
*-----------------------------------------------------------------------------------------------------------------------------------

*Set Directories

* Bernardo Atuesta
if inlist("`c(username)'","wb384997") {
	// Project paths
	global userpath "C:\Users\wb384997\OneDrive - WBG\Documents" // CHANGE
	global projectpath "$userpath\Climate Change\Regional study on Exposure to shocks\Shared folders\West_Africa_Exposure" // CHANGE
	global data_hhss "$projectpath\1_data\Household_survey"
	global results_excel "$projectpath\3_results\SocioeconIndic\Excel"	
	
	// Additional paths
	global EHCVM2_data "$userpath\EHCVM2022\Shared folders\EHCVM2"   // CHANGE
	global EHCVM1_data "$userpath\West Africa BA\Data\EHCVM2018"   // CHANGE
}

// Set globals for the countries in SSAPOV with admin2 regions available
global countries "BEN   BFA 	 CAF   CIV 	 CMR 	CPV  GAB  GHA	   GIN   GMB  GNB   LBR  MLI   MRT  NER   NGA  SEN   SLE   TCD   TGO"
global years 	"2021  2021  2021  2021  2021 	2015 2017 2016	   2018  2020 2021  2016 2021  2019 2021  2018 2021  2018  2022  2021"
global surveys 	"EHCVM EHCVM EHCVM EHCVM ECAM-V IDRF EGEP GLSS-VII EHCVM IHS  EHCVM HIES EHCVM EPCV EHCVM LSS  EHCVM SLIHS EHCVM EHCVM"


***************************************************
***# Generate harmonized household survey data #***
***************************************************

// Prepare initial data from SSAPOV (datalibweb) and EHCVM data
do "$dofiles//01_Prepare initial data.do"

// Harmonize socio-economic variables using prepared data
do "$dofiles//02_Harmonize socioecon vars.do"

// Harmonize geocode with regional admin variables form household surveys
*do "$dofiles//11_Harmonize geocode-admin3.do" // Not necessary (kept just for reference of the steps followed)

// Adding geo_code to the harmonized dataset
do "$dofiles//12_Adding geo_code.do"

// Adding h3 variables (where available) to harmonized survey data
* run in R: "$dofiles//13_Adding h3 variables.R"
	* Note: The resulting files are called "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode_h3.dta"

// Editing and ordering variables in the harmonized data with geo_code and h3
do "$dofiles//13_Editing data geo_code h3.do"


*********************************************************
***# Generate exposure data at lowest regional level #***
*********************************************************

// Generate exposure data at the lowest regional level available (geo_code)
do "$dofiles//21_Exposure data geo_code by hazard.do"

********************************************
***# Generate exposure data at h3 level #***
********************************************

// Generate exposure data files at the h3_6 level to merge with harmonized survey data
* run in R: "$dofiles//31_Exposure data h3 by hazard.R"

// Editing exposure data at the h3_6 level
do "$dofiles//32_Editing exposure data h3.do"


*********************************************************************************
***# Merge harmonized household survey data with hazard geo_code and h3 data #***
*********************************************************************************

// Merge exposure data to harmonized household survey files by geo_code and h3
do "$dofiles//41_Merging exposure data by geo_code h3.do"



