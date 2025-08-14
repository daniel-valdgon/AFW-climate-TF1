******************************************
***# Checking merge with SSAPOV files #***
******************************************


log using  "$projectpath\3_results\SocioeconIndic\Logs\merge with SSAPOV.log", replace

*******************************************
***# Merge with P module of the SSAPOV #***

foreach cty in $countries{
	display in red "`cty'" 
	use "$data_hhss\\`cty'\\RS_`cty'.dta", clear
	tab indpovm, m
	merge m:1 hid using "$data_hhss\\`cty'\\SSAPOV_P_`cty'.dta"
	tab onlyehcvm, m
}
// The only two countries without perfect matching with the P module of the SSAPOV are CIV: 728 obs (5.3%), and MRT: 3 obs (0.03%). These households are not considered for poverty measurement because they had no weights (wta_hh==.).

*******************************************
***# Merge with I module of the SSAPOV #***

foreach cty in $countries{
	display in red "`cty'" 
	use "$data_hhss\\`cty'\\RS_`cty'.dta", clear
	tab indpovm, m
	if "`cty'" != "NGA"{
		merge 1:1 hid pid using "$data_hhss\\`cty'\\SSAPOV_I_`cty'.dta"
	}
	else {
		rename (hid) (hhid)	
		merge 1:1 hhid pid using "$data_hhss\\`cty'\\SSAPOV_GMD_`cty'.dta"
	}
	tab onlyehcvm, m
}

log close



* These countries do not have a perfect match with the I module of the SSAPOV, using hid pid: 
	* BEN (6,144 obs), CMR (24 obs), GNB (341 obs), NER (5,328 obs), SEN (15,202 obs): These observations correspond to non-household members, not consider for poverty measurement.
	* CAF (123 obs), CIV (728 obs), LBR (510 obs), MRT (6 obs), SLE (29 obs): These observations correspond to members in households that have no information about income or expenditure, or no weights (in the case of MRT) and thus are not considered for poverty measurement.


	* BEN (6,144 obs), GNB (341 obs), NER (5,328 obs), SEN (15,202 obs): These observations correspond to non-household members, not consider for poverty measurement.
	* CAF (129 obs), LBR (515 obs), MRT (6 obs), SLE (29 obs): These observations correspond to members in households that have no information about income or expenditure, or no weights (in the case of MRT) and thus are not considered for poverty measurement.
	

use "$data_hhss\\BEN\\RS_BEN_se_geocode.dta", clear



/*
** Variables que quiero eliminar: OJO!! PARTE DE ESTO ME SIRVE, PERO TENGO QUE VER LAS VARIABLES QUE QUEDAN EN EL ARCHIVO QUE YA TIENE LAS VARIABLES DEL GEOCODE (LAS DEL DOFILE 12_Merging socioecon and exposure indic.do ... QUE DEBERIA CAMBIAR DE NOMBRE, DE HECHO.

	region1_prev region2_prev region3_prev region4_prev

** Subsecciones de las variables que quiero dejar (no estan ordenadas). OJO!! tengo que revisar cuales quiero dejar (no es necesario incluir todas las que genere para generar otras variables - por ejemplo, algunas de las dummies que vienen de las categoricas):

- Location variables
country region1 region2 region3 region4 subnatidsurvey strata rururb capital cluster 

- ID variables (estas estan semi-ordenadas)
hid pid hid_orig hhno pid_orig int_month int_year 
grappe menage (remember to label these variables and indicate that they merge with the EHCVM, and put a note in the word document)

- Household size and survey weights
hhsize ctry_adq wta_hh wta_pop wta_cadq

- Consumption and poverty variables
fdtexp nfdtexp hhtexp pc_fd pc_hh wel_PPP 
dpcexp_pov_2017 dpcexp_pov_2021 p_2_15 p_3_65 p_6_85 p_3 p_4_2 p_8_3 pcfoodexp
hhpovm indpovm

- Survey name and year
year survey

- Price indexes
cpi2017 cpi2021 icp2017 icp2021 

- GPS variables
loc_id loc_type gps_lat gps_lon gps_level gps_mod gps_priv

- Household characteristics
roof wall floor water8 imp_wat_rec w_30m imp_san_rec fuelcook electricity internet
adultshh n_12older
water8_1 water8_2 water8_3 water8_4 water8_5 water8_6 water8_7 water8_8 noimpwater nobaswater noelec lowq_roof lowq_wall lowq_floor lowq_mat scookfl notimprsanit
accinter
relathh6

- Ownership of goods (Assets)
radio television cellphone fridge computer bcycle mcycle car 
othassets noassets

- Remittances
hh_remit des_mig_1 des_mig_2 des_mig_3 origin_rmt amt_rmt_1 amt_rmt_2 amt_rmt_3
hhtremit pcremit

- Labor
lstatus ocusec industrycat4 contract socialsec
lstatus_1 lstatus_2 lstatus_3 indcat4_1 indcat4_2 indcat4_3 indcat4_4

- Individual characteristics
ageyrs sex 
ageg ageg_1 ageg_2 ageg_3 ageg_4 male female

- Education
educat5 educyrs atschool
adleduhh loweduc educat5_1 educat5_2 educat5_3 educat5_4 educat5_5 yrsschol_ind tyrsschol_hh yrsschol_hh scholatt_in scholatt

- Health and dissability
eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty
disability

- Household social safety nets and financial inclusion
socsec bankacc mobbankacc soctransf
nosoctrss

A estas les faltan labels:
socsec soctransf loc_id gps_lat gps_lon region0 h3_6 h3_7  
grappe menage (only for EHCVM countries)


*/

	// Save lists of variables in two locals (one for continuous variables and one for dummy variables)
	local varsc "dpcexp_pov_2017 dpcexp_pov_2021 pcfoodexp educyrs pcremit"
	local varsp "p_2_15 p_3_65 p_6_85 p_3 p_4_2 p_8_3 educat5_* ageg_* male female disability lstatus_* indcat4_* loweduc yrsschol_hh scholatt water8_* noimpwater nobaswater noelec lowq_mat scookfl notimprsanit cellphone car fridge noassets accinter hh_remit bankacc mobbankacc nosoctrss"

/*
foreach cty in $countries{
	use "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode.dta", clear
	label var geo_code "Lowest regional level available hhss (merges with hazard geo_code data)"
	*label var h3_6 "H3 index (hexagonal cells) at resolution 6 (merges with hazard h3 data)"	
	save "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode.dta", replace
}
*/