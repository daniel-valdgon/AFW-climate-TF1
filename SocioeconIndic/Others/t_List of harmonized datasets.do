*******************************************************************************************************
**# Lists of datasets of the harmonized data files with socioeconomic and hazard exposure variables #**
*******************************************************************************************************

** Harmonized dataset of socioeconomic variables
use "$projectpath\3_results\hhss-exposure\\BEN\\RS_BEN_se_geocode_h3.dta", clear

** Harmonized datasets of hazard exposure variables at the geo_code
use "$projectpath\3_results\exposure\Agricultural drought - AEP2p5.dta", clear
use "$projectpath\3_results\exposure\Flood - any (90m) - RP100.dta", clear
use "$projectpath\3_results\exposure\Heat - 5-day mean maximum daily ESI - RP100.dta", clear
use "$projectpath\3_results\exposure\Air pollution - annual median PM2.5 (2018-2022).dta", clear
use "$projectpath\3_results\exposure\Sea level rise - change in coastal flood depth (90m) - RP100.dta", clear

** Harmonized datasets of hazard exposure variables at h3 level
use "$projectpath\3_results\exposure\Agricultural drought - AEP2p5_h3_c.dta", clear
use "$projectpath\3_results\exposure\Flood - any (90m) - RP100_h3_c.dta", clear
use "$projectpath\3_results\exposure\Heat - 5-day mean maximum daily ESI - RP100_h3_c.dta", clear
use "$projectpath\3_results\exposure\Air pollution - annual median PM2.5 (2018-2022)_h3_c.dta", clear
use "$projectpath\3_results\exposure\Sea level rise - change in coastal flood depth (90m)_h3_c.dta", clear


