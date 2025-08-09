set more off
clear all
capture log close

log using "reply_table1_logs", replace text

use "matters_arising.dta", clear

local var_list "light cal_ntl"
local X1 "i.year##c.log_pop_02 i.year##c.area i.year##c.x i.year##c.y"
local X2 "township_id year"

gen cons = 0
replace cons = 1 if year == 2003 | year == 2004

gen relo = 0
replace relo = 1 if year >= 2005

gen npw = 0
replace npw = 1 if township_id == 157
gen npw_cons = npw*cons
la var npw_cons "NPW in 2003-04"
gen npw_relo = npw*relo
la var npw_relo "NPW Post 2005"

gen ygn = 0
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

esttab r1_* r2* using "reply_table1.csv", replace se r2 b(%10.3f) ///
keep(npw_cons npw_relo ygn_cons ygn_relo) star(* 0.10 ** 0.05 *** 0.01) label

clear all
log close
