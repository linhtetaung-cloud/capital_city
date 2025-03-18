# Economic impacts of capital city relocation in Myanmar

## Overview
This repository contains the datasets and Stata codes used in the study:

**Huang, X., Yan, H., & Zhang, Z.** (2025). *Economic Impacts of Capital City Relocation in Myanmar*. Nature Cities. [DOI: 10.1038/s44284-025-00217-x](https://doi.org/10.1038/s44284-025-00217-x)

## Prerequisites
Before running the Stata codes, ensure that the following packages are installed in your Stata environment:
- `reghdfe`
- `ftools`
- `estout`
- `sdid`

The `estimate_supt_critical_value` package is required and has been integrated into the respective code files.

## Data and Code Files
The repository includes multiple `.do` files and datasets necessary for the analysis. Please use the following datasets with their corresponding scripts:

- **`fig_2a-c.do`** & **`supplementary_table_1-5.do`** → Use `capital_panel.dta`
- **`supplementary_fig_1.do`** → Use `China_light_grp.dta`
- **`supplementary_fig_2a-c.do`** → Use `mys_panel.dta`

## Usage
1. Install the required Stata packages using the `ssc install` command where necessary.
2. Update the data directory in the `.do` files to match your corresponding directory, or load the appropriate dataset before executing the `.do` files.
3. Run the `.do` files in Stata sequentially for reproducing the results.

## License
This project is licensed under the MIT License.

---
**Citation:** If you use this repository, please cite the corresponding paper:
> Huang, X., Yan, H., & Zhang, Z. (2025). *Economic Impacts of Capital City Relocation in Myanmar*. Nature Cities. DOI: [10.1038/s44284-025-00217-x](https://doi.org/10.1038/s44284-025-00217-x)
