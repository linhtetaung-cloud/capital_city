set more off
clear all
capture log close

cd ..
log using "results/supplementary_t5_c3", replace text

*Load the dataset
use "data/capital_panel", clear

*Generate treated variables
gen post = 0 // Period 1
replace post = 1 if year >= 2003 

gen npw = 0 // Treated 1 the new capital
replace npw = 1 if township_id == 157
gen npw_post = npw * post
la var npw_post "NPW Post 2003"

gen ygn = 0 // Treated 2 the old capital
replace ygn = 1 if inlist(township_id, 274, 275, 276, 277, 279, 280, 283, 284, 286)
gen ygn_post = ygn * post
la var ygn_post "YGN Post 2003"

local X1 "log_pop_02 area x y"
local X2 "township_id"

sdid log_aod `X2' year npw_post if ygn != 1 & year > 2000, vce(placebo) covariates(`X1') seed(1000) graph
eststo r1_`var'

sdid log_aod `X2' year ygn_post if npw != 1 & year > 2000, vce(placebo) covariates(`X1') seed(1000) graph
eststo r2_`var'

esttab r1_* r2_* using "results/supplementary_t5_c3.csv", replace se r2 b(%10.3f) ///
keep(npw_post ygn_post) star(* 0.10 ** 0.05 *** 0.01) label

clear all
log close
