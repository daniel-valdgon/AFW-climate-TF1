*--------------------------------------------------------------------------------------
*	Title: Editing and ordering variables in the harmonized data with geo_code and h3
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: Aug 11, 2025
*--------------------------------------------------------------------------------------


// Open loop for countries
foreach cty in $countries{
local cty = "GAB"
	use "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode_h3.dta", clear

	gen sep0 = "sep0"
	label var sep0 "******* Section 0: ID variables *******"
	if survey[1]=="EHCVM" & country[1]!="CAF"{
		local sec0 "sep0 hid pid hid_orig hhno pid_orig hhpovm indpovm grappe menage"
		label var grappe "Cluster of household in EHCVM raw data"
		label var menage "Household ID in EHCVM raw data"
		drop onlyehcvm
	}
	else{
		local sec0 "sep0 hid pid hid_orig hhno pid_orig hhpovm indpovm"
	}

	gen sep1 = "sep1"
	label var sep1 "******* Section 1: Household size and weights *******"
	local sec1 "sep1 hhsize ctry_adq wta_hh wta_pop wta_cadq"

	gen sep2 = "sep2"
	label var sep2 "******* Section 2: Survey variables *******"
	local sec2 "sep2 year survey"

	if "`cty'" == "GAB"{
		gen region4 = ""
		replace subnatidsurvey = region1
	}

	gen sep3 = "sep3"
	label var sep3 "******* Section 3: Location and GPS variables *******"
	local sec3 "sep3 country region1 region2 region3 region4 subnatidsurvey strata rururb capital cluster region0 adm*_pcode adm*_name geo_code loc_id loc_type gps_lat gps_lon gps_level gps_mod gps_priv h3_6 h3_7"	

	gen sep4 = "sep4"
	label var sep4 "******* Section 4: Price index variables *******"
	local sec4 "sep4 cpi2017 cpi2021 icp2017 icp2021" 

	gen sep5 = "sep5"
	label var sep5 "******* Section 5: Consumption and poverty variables *******"
	local sec5 "sep5 fdtexp nfdtexp hhtexp pc_fd pc_hh wel_PPP dpcexp_pov_2017 dpcexp_pov_2021 p_2_15 p_3_65 p_6_85 p_3 p_4_2 p_8_3 pcfoodexp"

	gen sep6 = "sep6"
	label var sep6 "******* Section 6: Household variables *******"
	local sec6 "sep6 roof lowq_roof wall lowq_wall floor lowq_floor lowq_mat water8 water8_1 water8_2 water8_3 water8_4 water8_5 water8_6 water8_7 water8_8 w_30m noimpwater nobaswater notimprsanit fuelcook scookfl noelec internet accinter adultshh n_12older"
			
	gen sep7 = "sep7"
	label var sep7 "******* Section 7: Assets ownership variables *******"
	local sec7 "sep7 radio television cellphone fridge computer bcycle mcycle car othassets noassets"

	gen sep8 = "sep8"
	label var sep8 "******* Section 8: Remittances variables *******"
	local sec8 "sep8 hh_remit des_mig_1 des_mig_2 des_mig_3 origin_rmt amt_rmt_1 amt_rmt_2 amt_rmt_3 hhtremit pcremit"

	gen sep9 = "sep9"
	label var sep9 "******* Section 9: Individual characteristics variables *******"
	local sec9 "sep9 relathh6 sex female ageyrs ageg ageg_1 ageg_2 ageg_3 ageg_4"

	gen sep10 = "sep10"
	label var sep10 "******* Section 10: Education variables *******"
	local sec10 "sep10 educat5 educat5_1 educat5_2 educat5_3 educat5_4 educat5_5 educyrs atschool loweduc yrsschol_hh scholatt"

	gen sep11 = "sep11"
	label var sep11 "******* Section 11: Dissability variables *******"
	local sec11 "sep11 eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty disability"

	gen sep12 = "sep12"
	label var sep12 "******* Section 12: Labor variables *******"
	local sec12 "sep12 lstatus lstatus_1 lstatus_2 lstatus_3 ocusec industrycat4 indcat4_1 indcat4_2 indcat4_3 indcat4_4 contract socialsec"

	gen sep13 = "sep13"
	label var sep13 "******* Section 13: Safety nets and financial inclusion variables *******"
	local sec13 "sep13 socsec bankacc nosoctrss mobbankacc soctransf"

	// Labeling variables without label
	label var h3_6 "H3 index (hexagonal cells) at resolution 6 (merges with hazard h3 data)"
	label var h3_7 "H3 index (hexagonal cells) at resolution 7"
	label var gps_lat "GPS latitude coordinates" 
	label var gps_lon "GPS longitude coordinates"
	label var region0 "Country"
	label var socsec "At least one household member contributes to social security"
	label var soctransf "At least one household member receives social transfers"
	label var loc_id "Spatial unit ID for GPS"

	// Drop unnecessary or redundant variables
	drop int_month int_year code imp_wat_rec electricity imp_san_rec male adleduhh yrsschol_ind tyrsschol_hh scholatt_in

	order `sec0' `sec1' `sec2' `sec3' `sec4' `sec5' `sec6' `sec7' `sec8' `sec9' `sec10' `sec11' `sec12' `sec13'
	
	save "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode_h3.dta", replace
}

