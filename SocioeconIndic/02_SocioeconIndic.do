*-----------------------------------------------------------------------
*	Title: Socioeconomic indicators
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: Mar 17, 2025
*   Last updated : Mar 18, 2025 by Bernardo Atuesta
*-----------------------------------------------------------------------

*Set Directories

* Bernardo Atuesta
if inlist("`c(username)'","wb384997") {
	// Project paths
	global userpath "C:\Users\wb384997\OneDrive - WBG\Documents" // CHANGE
	global projectpath "$userpath\Climate Change\Regional study on Exposure to shocks\Shared folders\West_Africa_Exposure" // CHANGE

	global data_hhss "$projectpath\1_data\Household_survey"
	global results_excel "$projectpath\3_results\SocioeconIndic\Excel"	
}


// Set globals for the countries in SSAPOV with admin2 regions available
global countries "BEN BFA CAF CIV CMR CPV GHA GIN GMB GNB LBR MLI MRT NER NGA SEN SLE TCD TGO"


***********************************
***# Socio-economic indicators #***
***********************************

// Open loop for countries
foreach cty in $countries{

	// Open initial data with main harmonized variables
	use "$data_hhss\\`cty'\\RS_`cty'.dta", clear


	***# Income: People who live below $2.15/day, $3.65/day and $6.85/day 

	** Convert household welfare aggregate into USD 2017 PPPs per person per day and generate international poverty variables
	gen dpcexp_pov = wel_PPP /365 / icp2017 / cpi2017 
	label var dpcexp_pov "Daily per capita expenditure 2017PPP - for international poverty measurement"

	// Identify households in poverty
	gen p_2_15 = (dpcexp_pov < 2.15)
	label var p_2_15 "Poverty - US 2.15 line"

	gen p_3_65 = (dpcexp_pov < 3.65)
	label var p_3_65 "Poverty - US 3.65 line"

	gen p_6_85 = (dpcexp_pov < 6.85)
	label var p_6_85 "Poverty - US 6.85 line"	

	***# Expenditure: % of food in total household per capita expenditure
	gen pcfoodexp = pc_fd / pc_hh
	label var pcfoodexp "Share of food in total household per capita expenditure"

	***# No adults in the household have completed primary education
	** Total of adults per household
	egen adultshh = total(ageyrs>=18 & ageyrs!=.), by(hid)
	** Total of adults per household with low education (less than primary complete)
	egen adleduhh = total(ageyrs>=18 & ageyrs!=. & inlist(educat5, 1, 2)), by(hid)
	** Generate variable of indicator (no adults in hh have completed primary educ)
	gen loweduc = (adultshh == adleduhh)
	label var loweduc "No adults in household have completed primary education"

	***# Education categories
	tab educat5, gen(educat5_)
	// Exception: Some countries have no values in educat5	
	if ("`cty'" == "TCD"){
		forvalues x=1(1)5{
			gen educat5_`x' = .
		}
	}

	***# Years of completed education(educyrs)

	***# Households where no members 12yo+ have completed 6 years of schooling

	// Generate number of individuals 12+yo by household
	egen n_adult0 = count(ageyrs) if ageyrs>=12, by(hid)
	egen n_adult = max(n_adult0), by(hid)
	drop n_adult0
	// Identify individuals 12yo+ with less than 6 years of education
	gen yrsschol_ind = 1 if ageyrs>=12 & (inrange(educyrs,0,5) | educyrs==.)
	label var yrsschol_ind "Not completed six years of schooling (12 years or older)"
	// Generate number of individuals 12yo+ with less than 6 years of education by HH
	egen tyrsschol_hh = total(yrsschol_ind), by(hid)
	label var tyrsschol_hh "Number of HH members aged 12+ with less than 6 years of schooling"
	// Identify households where no members 12yo+ have completed 6 years of schooling
	gen yrsschol_hh = (n_adult == tyrsschol_hh) 
	label var yrsschol_hh "No HH member aged 12 or older has completed 6 years of schooling"


	***# At least one child aged 6-18 does not attend school
	gen  scholatt_in = 0
	replace scholatt_in = 1 if atschool!=1 & (ageyrs>=6 & ageyrs<=18 & ageyrs!=.) 
	lab var scholatt_in "Child aged 6-18 does not attent school"
	label def yesno 1 "Yes" 0 "No", replace
	lab val scholatt_in yesno
	bys hid: egen scholatt=max(scholatt_in)
	lab var scholatt "At least one child aged 6-18 does not attent school"

	***# Age categories
	gen ageg = 1 if ageyrs>=0 & ageyrs<=14
	replace ageg = 2 if ageyrs>=15 & ageyrs<=39
	replace ageg = 3 if ageyrs>=40 & ageyrs<=64
	replace ageg = 4 if ageyrs>=65 & ageyrs!=.
	label def ageg 1 "0 to 14 years old" 2 "15 to 39 years old" 3 "40 to 64 years old" 4 "65 and older", replace
	label val ageg ageg
	label var ageg "Age groups"

	tab ageg, gen(ageg_)	

	***# Gender categories
	gen male=(sex==1)
	label var male "Male = 1"
	gen female=(sex==0)
	label var female "Female = 1"

	***# Disability (at least one domain reported as 3 "Yes - a lot of difficulty" or 4 "Cannot do at all")
	gen disability = (inrange(eye_dsablty,3,4) | ///
					inrange(hear_dsablty,3,4) | /// 
					inrange(walk_dsablty,3,4) | /// 
					inrange(conc_dsord,3,4) | /// 
					inrange(slfcre_dsablty,3,4) | /// 
					inrange(comm_dsablty,3,4))
	label var disability "Disability = 1"

	***# Main source of drinking water
	// Not all countries have values in all categories, so I create a variable for each category
	forvalues x=1(1)8{
		gen water8_`x' = 0
		replace water8_`x' = 1 if water8==`x'
	}	
	label var water8_1 "water8==1.Piped water -own tap"
	label var water8_2 "water8==2.Public tap or standpipe"
	label var water8_3 "water8==3.Protected well"
	label var water8_4 "water8==4.Unprotected well"
	label var water8_5 "water8==5.Surface water"
	label var water8_6 "water8==6.Rainwater"
	label var water8_7 "water8==7.Tanker-truck/ vendor"
	label var water8_8 "water8==8.Other"
	

	***# Does not have access to improved water
	gen noimpwater = (imp_wat_rec == 0)
	label def noimpwater 0 "Improved water" 1 "No improved water", replace
	label val noimpwater noimpwater
	label var noimpwater "Household has no access to improved water"

	***# Does not have access to basic water (improved + available within 30 min)
	gen nobaswater = (w_30 != 1)
	label def nobaswater 0 "Access to basic water" 1 "No access to basic water", replace
	label val nobaswater nobaswater
	label var nobaswater "Household has no access to basic water (improved + available within 30 min)"	


	***# Does not have access to electricity
	gen noelec = (electricity == 0)
	label def noelec 0 "Access to electricity" 1 "No access to electricity", replace
	label val noelec noelec
	label var noelec "Household has no access to electricity"

	***# Low quality materials: Natural or rudimentary
	gen lowq_roof = (inrange(roof,1,7) | roof==15) // Roof with low quality materials
	gen lowq_wall = (inrange(wall,1,10) | wall==19) // Walls with low quality materials
	gen lowq_floor = (inrange(floor,1,6) | floor==14) // Walls with low quality materials

	gen lowq_mat = (lowq_roof==1 | lowq_wall==1 | lowq_floor==1)
	label var lowq_mat "At least one low quality material in walls floors or roof"

	***# Household uses solid for cooking (wood, charcoal, peroleum, others)
	gen scookfl = (inrange(fuelcook,1,3) | fuelcook==9)
	label var scookfl "Use of solid cooking fuel"	

	***# Shared or not improved toilet (equivalent to not improved sanitation)
	gen notimprsanit = (imp_san_rec==0)
	label var notimprsanit "Shared or not improved toilet (not improved sanitation)"	

	***# Distance to nearest primary school (dispsch)
	***# Distance to nearest health facility (disheal)
	***# Ownership of at least one cellular phone (cellphone)
	***# Ownership of a car (car)
	***# Ownership of a fridge (fridge)

	***# Ownership of other assets
	gen othassets = radio + television + cellphone + fridge + computer + bcycle + mcycle
	label var othassets "Number of other assets owned by household"

	gen noassets = (car==0 & othassets<=1 & othassets!=.)
	tab noassets
	label var noassets "Household does not own a car and more than 1 other durable asset"

	***# Access to internet inside the house
	gen accinter = (internet==1)
	label var accinter "Access to internet inside the house"
		
	***# Did household receive any remittances? (hh_remit)	

	***# Source of remittances
	// Destination of migration of the 1st remittance sending member.
	*tab des_mig_1, gen(destmigremit_)

	***# Per capita income from remittances
	egen hhtremit = rowtotal(amt_rmt_1 amt_rmt_2 amt_rmt_3)
	gen pcremit = hhtremit/hhsize
	label var pcremit "Household per capita income from remittances"

	***# Labor status (Employed, Unemployed, Out of labor force)
	tab lstatus, gen(lstatus_)
	// Exception: Some countries have no values in lstatus	
	if ("`cty'" == "NGA"){
		forvalues x=1(1)3{
			gen lstatus_`x' = .
		}
	}

	***# Workers per sector of labor activity (agriculture, industry and services)	
	tab industrycat4, gen(indcat4_)
	// Exception: Some countries have no values in industrycat4	
	if ("`cty'" == "CAF" | "`cty'" == "CMR" | "`cty'" == "CPV" | "`cty'" == "GIN" | "`cty'" == "LBR" | "`cty'" == "MRT"){
		forvalues x=1(1)4{
			gen indcat4_`x' = .
		}
	}
	
	***# At least one household member contributes to social security (socsec)
	***# At least one household member has access to any bank account (bankacc)
	label var bankacc "At least one household member has access to any bank account"
	***# At least one household member has access to a mobile bank account (mobbankacc)
	label var mobbankacc "At least one household member has access to a mobile bank account"
	***# At least one household member receives social transfers (soctransf)

	***# Household neither receives social transfers nor contributes to social insurance
	gen nosoctrss = (socsec==0 & soctransf==0)
	label var nosoctrss "Household neither receives social transfers nor contributes to social insurance"	


	** Save file
	save "$data_hhss\\`cty'\\RS_`cty'_soceconind.dta", replace
}

*******************************************************************
***# Calculate socio-economic indicators by admin1-2-3 regions #***
*******************************************************************

// Save lists of variables in two locals (one for continuous variables and one for dummy variables)
local varsc "dpcexp_pov pcfoodexp educyrs dispsch disheal pcremit"
local varsp "p_2_15 p_3_65 p_6_85 educat5_* ageg_* male female disability lstatus_* indcat4_* loweduc yrsschol_hh scholatt water8_* noimpwater nobaswater noelec lowq_mat scookfl notimprsanit cellphone car fridge noassets accinter hh_remit bankacc mobbankacc nosoctrss"


// Open loop for countries
foreach cty in $countries{

	// Open initial data with main harmonized variables
	use "$data_hhss\\`cty'\\RS_`cty'_soceconind.dta", clear

	drop if year== . // OJO!! CAF has 129 observations with year ==. (Pending for checking)
	
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
			collapse (mean) `varsc' `varsp' [pw= wta_hh], by(country year region`r')
			
			// Rename variables for the next reshape
			foreach v of varlist `varsc' `varsp'{
				rename `v'  v_`v'
			} 
			
			// Reshape file to long format
			reshape long v_, i(country year region`r') j(indicator) string
			
			// Rename variable with values
			rename v_ values
			
			// Save in a temporary file for posterior appending
			tempfile `cty'_reg`r'
			save ``cty'_reg`r'', replace	
			
		restore
	}
}


// Create a loop for type of admin region to append results by country
forvalues r=0(1)3{

	// Create an empty file with an empty variables to be able to latter append
	clear
	gen A=.

	** Countries with information up to admin2: BEN CIV CPV GHA GMB GNB LBR NER NGA SLE TGO
	** Countries with information up to admin3: BFA CAF CMR GIN MLI MRT SEN TCD
 
	// Consider different lists of countries for admin3 and the rest
	if (`r' == 3){
		local clist "BFA CAF CMR GIN MLI MRT SEN TCD" 
	}
	else{
		local clist "$countries"
	}

	// Create a loop for countries and append the corresponding tempfile	
	foreach cty in `clist'{
		append using ``cty'_reg`r''
	}
	
	drop A // drop empty variable
	
	// Export results to Excel
	egen concat=concat(country year region`r' indicator), punct("_")
	order concat
	export excel using "$results_excel\\RS_SocioeconIndic.xlsx", sheet("reg`r'", replace) cell(A1) firstrow(variables)		
}



