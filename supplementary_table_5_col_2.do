set more off
clear all
capture log close

cd ..
log using "results/supplementary_t5_c2", replace text

// Load the dataset
use "data/capital_panel", clear

// Create a local list with the township_id of missing urban area values
local numlist 15 24 37 42 52 56 57 58 59 62 64 67 69 70 75 76 78 79 80 82 83 84 ///
86 88 91 93 94 101 103 109 111 112 113 116 117 128 141 142 147 159 160 161 163 ///
164 167 168 169 170 172 174 175 176 177 178 180 182 184 185 186 187 190 191 192 ///
194 196 198 199 205 215 220 222 224 227 228 229 230 231 232 234 240 244 247 250 ///
258 260 264 267 269 // Townships with missing urban area values

foreach num in `numlist' {
   drop if township_id == `num'
}

// Generate treated variables
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

sdid log_urban `X2' year npw_post if ygn != 1, vce(placebo) covariates(`X1') seed(1000) graph
eststo r1_`var'

sdid log_urban `X2' year ygn_post if npw != 1, vce(placebo) covariates(`X1') seed(1000) graph
eststo r2_`var'

esttab r1_* r2_* using "results/supplementary_t5_c2.csv", replace se r2 b(%10.3f) ///
keep(npw_post ygn_post) star(* 0.10 ** 0.05 *** 0.01) label

clear all
log close
