*-----------------------------------------------------------------------------
*	Title: Table with missing observations per variable of countrys' datasets
*   Project: Regional study on exposure to shocks in SSA countries 
*	Author: Bernardo Atuesta
*   First written: Oct 6, 2025
*-----------------------------------------------------------------------------

* Loop over countries
foreach cty in $countries {

    * Load the dataset
    use "$projectpath\3_results\hhss-exposure\\`cty'\\RS_`cty'_se_geocode_h3_exp.dta", clear

    * Get list of variables
    ds
    local vars `r(varlist)'

	* Count total number of observations
    count
    local totaln = r(N)
		
    * Loop over variables to calculate missing percentage
    foreach var of local vars {
        count if missing(`var')
        local miss = r(N)
        local pct = 100 * `miss' / `totaln'
        matrix M_`cty' = [nullmat(M_`cty') \ `pct'] 
    }
	
	* Add first row with total number of observations
	matrix M_`cty' = [`totaln' \ M_`cty']

	* Name country column
	matrix colnames M_`cty' = `cty'

	* Clear and convert to Stata file and create a variable with the row names
	clear
	svmat M_`cty', names(col)
	gen variable = ""
	local i = 1
	foreach name in TotalObs `vars' {
		replace variable = "`name'" in `i'
		local ++i
	}
	order variable

	tempfile F_`cty'
	save `F_`cty'', replace	
}

* Append all country files
foreach cty in $countries {
	if "`cty'" == "BEN"{
		use `F_`cty'', clear
		* Generate variable with the order of the variables I want
		egen order = seq()
	}
	else {
		merge 1:1 variable using `F_`cty'', nogen
	} 
}

drop order

* Drop order variable and export to Excel
export excel using "$projectpath\3_results\hhss-exposure\\Missing obs per variable.xlsx", firstrow(variables) sheet("Missings") replace


