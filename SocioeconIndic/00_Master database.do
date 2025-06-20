*-----------------------------------------------------------------------------------------------------------------------------------
*	Title: Master file to generate a database with harmonized socioeconomic indicators and climate exposure data for SSA countries
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: Mar 13, 2025
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
global countries "BEN   BFA 	 CAF   CIV 	 CMR 	CPV  GHA	  GIN   GMB  GNB   LBR  MLI   MRT  NER   NGA  SEN   SLE   TCD   TGO"
global years 	"2021  2021  2021  2021  2021 	2015 2016	  2018  2020 2021  2016 2021  2019 2021  2018 2021  2018  2022  2021"
global surveys 	"EHCVM EHCVM EHCVM EHCVM ECAM-V IDRF GLSS-VII EHCVM IHS  EHCVM HIES EHCVM EPCV EHCVM LSS  EHCVM SLIHS EHCVM EHCVM"


// Prepare initial data from SSAPOV (datalibweb), EHCVM and Nigeria's NLSS 2022/23 survey
do "$dofiles//01_Prepare initial data.do"

// Harmonize socio-economic variables using prepared data
do "$dofiles//02_Harmonize socioecon vars.do"

// Harmonize geocode with regional admin variables form household surveys
*do "$dofiles//11_Harmonize geocode-admin3.do" // Not necessary (kept just for reference of the steps followed)

// Calculating socioeconomic indicators by geocode and merge with exposure data
do "$dofiles//12_Merging socioecon and exposure indic.do"
	// Note: After this do-file, use the R script "$projectpath\\2_scripts\wb384997\SocioeconIndic\\22_Socioecon and exposure indic by geocode.R" to merge the "$data_hhss\\`cty'\\RS_`cty'_se_adminX.dta" file with climate exposure data, or to check the instructions on how to use R to create a Stata file for each country and merge it at the country level

* run in R: "$dofiles//13_Socioecon and exposure indic by geocode.R"

// Calculate socioeconomic indicators by admin1-2-3 regions
do "$dofiles//21_Socioecon indic by regions.do"

