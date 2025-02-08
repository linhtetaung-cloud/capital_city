set more off
clear all
capture log close

cd ..
log using "results/supplementary_fig_1", replace text

*Load the dataset
use "data/China_light_grp", clear

reg ln_grp ln_light if year == 2006
drop if ln_grp == .
graph twoway (lfitci ln_grp ln_light if year == 2006) (scatter ln_grp ln_light if year == 2006), ylabel(, nogrid) ytitle("Gross Regional Product") xlabel(, nogrid) xtitle("Light Density") legend(off)

graph export "results/supplementary_fig_1.eps", replace

clear all
log close
