set more off
clear all
capture log close

cd ..
log using "results/supplementary_table_1", replace text

*Load the dataset
use "data/capital_panel", clear

*Define dependent and control variables 
local var_list "light log_urban log_aod"
local X1 "i.year##c.log_pop_02 i.year##c.area i.year##c.x i.year##c.y"
local X2 "township_id year"

*Generate treatment variables
gen cons = 0 // Period 1
replace cons = 1 if year == 2003 | year == 2004 // Constructed during 2003-2004

gen relo = 0 // Period 2
replace relo = 1 if year >= 2005 // Relocated in 2005

gen npw = 0 // Treated 1 the new capital
replace npw = 1 if township_id == 157
gen npw_cons = npw*cons
la var npw_cons "NPW in 2003-04"
gen npw_relo = npw*relo
la var npw_relo "NPW Post 2005"

gen ygn = 0 // Treated 2 the old capital
replace ygn = 1 if inlist(township_id, 274, 275, 276, 277, 279, 280, 283, 284, 286)
gen ygn_cons = ygn*cons
la var ygn_cons "YGN in 2003-04"
gen ygn_relo = ygn*relo
la var ygn_relo "YGN Post 2005"

foreach var of local var_list{
reghdfe `var' npw_cons npw_relo if ygn != 1, a(`X2' `X1') cl(district_id)
eststo r1_`var'
}

foreach var of local var_list{
reghdfe `var' ygn_cons ygn_relo if npw != 1, a(`X2' `X1') cl(district_id)
eststo r2_`var'
}

esttab r1_* r2* using "results/supplementary_table_1.csv", replace se r2 b(%10.3f) ///
keep(npw_cons npw_relo ygn_cons ygn_relo) star(* 0.10 ** 0.05 *** 0.01) label

clear all
log close
