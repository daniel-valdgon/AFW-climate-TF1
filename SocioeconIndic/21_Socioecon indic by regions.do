*-----------------------------------------------------------------------
*	Title: Calculate socioeconomic indicators by admin1-2-3 regions
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: Mar 17, 2025
*-----------------------------------------------------------------------

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


*******************************************************************
***# Calculate socio-economic indicators by admin1-2-3 regions #***
*******************************************************************

// Save lists of variables in two locals (one for continuous variables and one for dummy variables)
local varsc "dpcexp_pov_2017 dpcexp_pov_2021 pcfoodexp educyrs pcremit"
local varsp "p_2_15 p_3_65 p_6_85 p_3 p_4_2 p_8_3 educat5_* ageg_* male female disability lstatus_* indcat4_* loweduc yrsschol_hh scholatt water8_* noimpwater nobaswater noelec lowq_mat scookfl notimprsanit cellphone car fridge noassets accinter hh_remit bankacc mobbankacc nosoctrss"


// Open loop for countries
foreach cty in $countries{

	// Open initial data with main harmonized variables
	use "$data_hhss\\`cty'\\RS_`cty'_se.dta", clear

	// Multiply the dummy variables by 100 to obtain results in percentages
	foreach v of varlist `varsp'{
		replace `v' = 100*`v'
	} 

	// Generate a variable for National statistics
	gen region0 = "0 - `cty'"

	// Not al countries have non-missing region3, so this identifies the ones that do and considers it for the next loop
	tab region3
	local r3=r(r)

	if `r3' == 0{
		local ur = 2
	}
	else{
		local ur = 3
	}	

	// Create a loop to obtain results at the national level (region0), admin1 (region1), admin2 (region2) and admin3 (region3)
	forvalues r=0(1)`ur'{
		preserve
			// Collapse to obtain the indicator value of all variables by region
			collapse (mean) `varsc' `varsp' (rawsum) wta_hh [pw= wta_hh], by(country year region`r')
			
			// Rename variables for the next reshape
			foreach v of varlist `varsc' `varsp' wta_hh{
				rename `v'  v_`v'
			} 
			
			// Reshape file to long format
			reshape long v_, i(country year region`r') j(indicator) string
			
			// Rename variable with values
			rename v_ values
			
			// Save in a temporary file for posterior appending
			save "$data_hhss\\`cty'\\SocEcon_`cty'_reg`r'.dta", replace	
			
		restore
	}
}


// Create a loop for type of admin region to append results by country
forvalues r=0(1)3{

	// Create an empty file with an empty variable to be able to append 
	clear
	gen A=.

	** Countries with information up to admin2: BEN CIV CPV GHA GMB GNB LBR NER SLE TGO
	** Countries with information up to admin3: BFA CAF CMR GIN MLI MRT NGA SEN TCD
 
	// Consider different lists of countries for admin3 and the rest
	if (`r' == 3){
		local clist "BFA CAF CMR GIN MLI MRT NGA SEN TCD" 
	}
	else{
		local clist "$countries"
	}

	// Create a loop for countries and append the corresponding tempfile	
	foreach cty in `clist'{
		append using "$data_hhss\\`cty'\\SocEcon_`cty'_reg`r'.dta"
	}
	
	drop A // drop empty variable
	
	// Export results to Excel
	egen concat=concat(country year region`r' indicator), punct("_")
	order concat
	export excel using "$results_excel\\RS_SocioeconIndic.xlsx", sheet("reg`r'", replace) cell(A1) firstrow(variables)		
}



***************************************************************************************************
**# Create set of results for the lowest regional level of statistical significance per country #**
***************************************************************************************************

// Create an empty file with an empty variable to be able to append 
clear
gen A=.

// Define groups of countries depending on their lowest regional level of statistical significance
local regsig1 "BEN BFA CAF CIV CMR GIN GNB MLI NER SEN TCD TGO"
local regsig2 "CPV GHA GMB LBR NGA SLE"
local regsig3 "MRT"

** Append results of all countries, considering only the region of their lowest regional level of statistical significance
foreach cty in $countries {
    
    if strpos("`regsig1'", "`cty'") {
        local r = 1
    }
    else if strpos("`regsig2'", "`cty'") {
        local r = 2
    }
    else if strpos("`regsig3'", "`cty'") {
        local r = 3
    }

    append using "$data_hhss\\`cty'\\SocEcon_`cty'_reg`r'.dta"
}

drop A	// drop empty variable

// Generate one variable for the lowest regional level of statistical significance
gen regionsig = region1
replace regionsig = region2 if regionsig==""
replace regionsig = region3 if regionsig==""
label var regionsig "Lowest regional level of statistical significance"

order country year region1 region2 region3 regionsig

save "$data_hhss\\SocEcon_all_regsig.dta", replace

// Export results to Excel
egen concat=concat(country year regionsig indicator), punct("_")
order concat
export excel using "$results_excel\\RS_SocioeconIndic.xlsx", sheet("regsig", replace) cell(A1) firstrow(variables)		


