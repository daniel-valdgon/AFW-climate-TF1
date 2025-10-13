*--------------------------------------------------------------------------
*	Title: Calculating socioeconomic indicators by geocode
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: June 5, 2025
*--------------------------------------------------------------------------


	local varsc "dpcexp_pov_2017 dpcexp_pov_2021 pcfoodexp educyrs pcremit"
	local varsp "p_2_15 p_3_65 p_6_85 p_3 p_4_2 p_8_3 educat5_* ageg_* female disability lstatus_* indcat4_* loweduc yrsschol_hh scholatt water8_* noimpwater nobaswater noelec lowq_mat scookfl notimprsanit cellphone car fridge noassets accinter hh_remit bankacc mobbankacc nosoctrss"
	
// Open loop for countries and generate a file by the lowest available admin regional level per country
foreach cty in $countries{

	*use "$data_hhss\\`cty'\\RS_`cty'_se_geocode.dta", clear
	use "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode_h3_exp.dta", clear
	
	*collapse (mean) `varsc' `varsp' (rawsum) wta_hh (first) region* subnatidsurvey code adm* [pw= wta_hh], by(country year geo_code)
	collapse (mean) `varsc' `varsp' (rawsum) wta_hh (first) region* subnatidsurvey adm* if indpovm==1 [pw= wta_hh], by(country year geo_code)
	
	save "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se-gc-h3_adminX.dta", replace
}


// Create an empty file with an empty variable to be able to append 
clear
gen A=.
// Open loop for countries
foreach cty in $countries{
	*append using "$data_hhss\\`cty'\\RS_`cty'_se_adminX.dta"
	append using "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se-gc-h3_adminX.dta"
}
drop A
*save "$data_hhss\\RS_All_se_adminX.dta", replace
save "$projectpath\3_results\hhss-exposure\\RS_All_se-gc-h3_adminX.dta", replace


