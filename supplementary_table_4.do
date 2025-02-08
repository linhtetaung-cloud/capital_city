set more off
clear all
capture log close

cd ..
log using "results/supplementary_table_4", replace text

*Load the dataset
use "data/capital_panel", clear

*Define dependent and control variables 
local var_list "light log_urban log_aod"
local X1 "i.year##c.log_pop_02 i.year##c.area i.year##c.x i.year##c.y"
local X2 "township_id year"

// Create a local list with the township_id of contested areas
local numlist 31 32 33 42 45 46 57 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 ///
 79 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 140 147 148 149 150 151 152 153 154 155 156 ///
 165 166 174 175 176 177 178 179 189 212 213 214 215 216 217 218 219 220 221 222 223 224 225 ///
 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 ///
 249 250 251 252 253 254 255 256 258 259 260 261 262 264 265 266 267 268 269 270 271 272 273 // Contested areas 122 in total

// Generate the treated+control group for spillovers
gen spillovers = 0

foreach num in `numlist' {
    replace spillovers = 1 if township_id == `num'
}

replace spillovers = 0 if inlist(township_id, 74, 87, 92, 149, 262, 266) // Remove the regional capitals
replace spillovers = 1 if township_id == 157 // Add the NPW township
replace spillovers = 1 if inlist(township_id, 274, 275, 276, 277, 279, 280, 283, 284, 286) // Add the YGN townships

* Drop all other townships
drop if spillovers != 1

*Generate treated variables
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
replace ygn = 1 if inlist(township_id, 274, 275, 276, 277, 279, 280, 283, 284, 286) //274 and 286 are the central townships
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

esttab r1_* r2* using "results/supplementary_table_4.csv", replace se r2 b(%10.3f) ///
keep(npw_cons npw_relo ygn_cons ygn_relo) star(* 0.10 ** 0.05 *** 0.01) label

clear all
log close
