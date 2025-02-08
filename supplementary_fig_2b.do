set more off
clear all
capture log close

cd ..
log using "results/supplementary_fig_5b", replace text

*Load the dataset
use "data/mys_panel", clear

*Installing the estimate_supt_critical_value package
cap ado uninstall estimate_supt_critical_value
net install estimate_supt_critical_value, from("https://raw.githubusercontent.com/ryanedmundkessler/simultaneous_confidence_bands/master/ado/")

*Generate variables
gen npw = 0 // Treatment 1 the new capital
replace npw = 1 if township_id == 77

gen ygn = 0 // Treatment 2 the old capital
replace ygn = 1 if township_id == 81

forvalues i = 1997/2010{
	gen npw_`i' = 0
	replace npw_`i' = 1 if year == `i' & npw == 1
}

forvalues i = 1997/2010{
	gen ygn_`i' = 0
	replace ygn_`i' = 1 if year == `i' & ygn == 1
}

*Define variables
local NPW "npw_19* npw_*00 npw_*02 npw_*03 npw_*04 npw_*05 npw_*06 npw_*07 npw_*08 npw_*09 npw_*10 npw_*01"
local YGN "ygn_19* ygn_*00 ygn_*02 ygn_*03 ygn_*04 ygn_*05 ygn_*06 ygn_*07 ygn_*08 ygn_*09 ygn_*10 ygn_*01"
local X "i.year i.township_id i.year##c.log_pop_01 i.year##c.area i.year##c.x i.year##c.y"

*NPW the new capital
reghdfe log_urban `NPW' if ygn != 1, a(`X') cl(district_id)

local critical_value_new = invttail(e(df_r), 0.05 / 2)

matrix b_new = e(b)
matrix V_new = e(V)

* Create new variable for time event and coefficients
gen time_event = year

* First 5yrs 1997-2001 coefs
gen coef_new_5 = .
forvalues i = 1/4 {
	replace coef_new_5 = b_new[1, `i'] in `i'
}

* Last 7yrs 2003-2009 coefs
gen coef_new_7 = .
forvalues i = 5/13 {
	replace coef_new_7 = b_new[1, `i'] in `i'
}

* Standard errors for the first 5yrs and last 7yrs 
gen se_new_5 = .
forvalues i = 1/4 {
    replace se_new_5 = sqrt(V_new[`i', `i']) in `i'
}

gen se_new_7 = .
forvalues i = 5/13 {
    replace se_new_7 = sqrt(V_new[`i', `i']) in `i'
}

* Calculate confidence intervals for the new capital
gen ci_lower_new_5 = coef_new_5 - `critical_value_new' * se_new_5
gen ci_upper_new_5 = coef_new_5 + `critical_value_new' * se_new_5

gen ci_lower_new_7 = coef_new_7 - `critical_value_new' * se_new_7
gen ci_upper_new_7 = coef_new_7 + `critical_value_new' * se_new_7

* Calculate the simultaneous sup-t confidence band
estimate_supt_critical_value, vcov_matrix(V_new) num_sim(5000) conf_level(0.95)
matrix critical_value_new = r(critical_value)
scalar sim_multiplier_new = critical_value_new[1,1]

gen ci_lower_new_sim_5 = coef_new_5 - sim_multiplier_new * se_new_5
gen ci_upper_new_sim_5 = coef_new_5 + sim_multiplier_new * se_new_5

gen ci_lower_new_sim_7 = coef_new_7 - sim_multiplier_new * se_new_7
gen ci_upper_new_sim_7 = coef_new_7 + sim_multiplier_new * se_new_7

*YGN the new capital
reghdfe log_urban `YGN' if npw != 1, a(`X') cl(district_id)

local critical_value_old = invttail(e(df_r), 0.05 / 2)

* Extract coefficients and standard errors for the old capital
matrix b_old = e(b)
matrix V_old = e(V)

* Create new variable for coefficients and standard errors
* First 5yrs
gen coef_old_5 = .
forvalues i = 1/4 {
	replace coef_old_5 = b_old[1, `i'] in `i'
}

* Last 7yrs
gen coef_old_7 = .
forvalues i = 5/13 {
	replace coef_old_7 = b_old[1, `i'] in `i'
}
* Standard errors
gen se_old_5 = .
forvalues i = 1/4 {
    replace se_old_5 = sqrt(V_old[`i', `i']) in `i'
}

gen se_old_7 = .
forvalues i = 5/13 {
    replace se_old_7 = sqrt(V_old[`i', `i']) in `i'
}

* Calculate confidence intervals for the old capital
gen ci_lower_old_5 = coef_old_5 - `critical_value_old' * se_old_5
gen ci_upper_old_5 = coef_old_5 + `critical_value_old' * se_old_5

gen ci_lower_old_7 = coef_old_7 - `critical_value_old' * se_old_7
gen ci_upper_old_7 = coef_old_7 + `critical_value_old' * se_old_7

* Calculate the simultaneous sup-t confidence band
estimate_supt_critical_value, vcov_matrix(V_old) num_sim(5000) conf_level(0.95)
matrix critical_value_old = r(critical_value)
scalar sim_multiplier_old = critical_value_old[1,1]

gen ci_lower_old_sim_5 = coef_old_5 - sim_multiplier_old * se_old_5
gen ci_upper_old_sim_5 = coef_old_5 + sim_multiplier_old * se_old_5

gen ci_lower_old_sim_7 = coef_old_7 - sim_multiplier_old * se_old_7
gen ci_upper_old_sim_7 = coef_old_7 + sim_multiplier_old * se_old_7

* Limit the x-axis from 1997 to 2010
local xmin = 1997  //Minimum year relative to the intervention (1997)
local xmax = 2010   //Maximum year relative to the intervention (2010)

* Create new time_event variables with offsets for plotting
gen time_event_new = time_event - 0.15 //Offset for the first 5 coefs of the new capital to the left
gen time_event_old = time_event + 0.15 //Offset for the first 5 coefs of the old capital to the right
gen time_event_new_7 = time_event + 0.85 //Offset for the last 7 coefs of the new capital to the left of the next year
gen time_event_old_7 = time_event + 1.15 //Offset for the last 7 coefs of the old capital to the right of the next year

* Insert zero for the year before policy intervention (2002) for both coefficients
gen coef_new =.
replace coef_new = 0 if time_event == 2001
gen coef_old =.
replace coef_old = 0 if time_event == 2001

* Create twoway scatterplot with adjusted x-coordinates for clarity
twoway (scatter coef_new_5 time_event_new, mcolor(cranberry) msymbol(smcircle) msize(medium)) /// //New cap Coeffs
(scatter coef_new time_event_new, mcolor(cranberry) msymbol(smcircle) msize(medium)) ///
(scatter coef_new_7 time_event_new_7, mcolor(cranberry) msymbol(smcircle) msize(medium)) ///
(rcap ci_lower_new_5 ci_upper_new_5 time_event_new, lcolor(cranberry)) /// //New cap CIs
(rcap ci_lower_new_7 ci_upper_new_7 time_event_new_7, lcolor(cranberry)) ///
(scatter coef_old_5 time_event_old, mcolor(midblue) msymbol(smtriangle) msize(medium)) /// //Old cap Coeffs
(scatter coef_old time_event_old, mcolor(midblue) msymbol(smtriangle) msize(medium)) ///
(scatter coef_old_7 time_event_old_7, mcolor(midblue) msymbol(smtriangle) msize(medium)) ///
(rcap ci_lower_old_5 ci_upper_old_5 time_event_old, lcolor(midblue)) /// //Old cap CIs
(rcap ci_lower_old_7 ci_upper_old_7 time_event_old_7, lcolor(midblue)) ///
(rspike ci_lower_new_sim_5 ci_upper_new_sim_5 time_event_new, color(cranberry%50)) /// //New cap CI bands
(rspike ci_lower_new_sim_7 ci_upper_new_sim_7 time_event_new_7, color(cranberry%50)) ///
(rspike ci_lower_old_sim_5 ci_upper_old_sim_5 time_event_old, color(midblue%50)) /// //Old cap CI bands
(rspike ci_lower_old_sim_7 ci_upper_old_sim_7 time_event_old_7, color(midblue%50)), ///
ylabel(, nogrid angle(horizontal)) ytitle("Coefficient") ///
yline(0, lcolor(grey) lpattern(dash)) ///
xscale(range(`xmin', `xmax')) /// Limit the x-axis from 1997 to 2010
xlabel(1997(1)2010, angle (45) nogrid format(%9.0f)) /// Customize x-axis labels
xline(2001, lcolor(navy) lpattern(dash)) xtitle("Year") /// Add a vertical dotted line at 2001 and the X-axis title
legend(order(1 "Putrajaya" 6 "Kuala Lumpur") region(lcolor(none)) position(1) col(2)) //

graph export "results/supplementary_fig_5b.eps", replace

clear all
log close

