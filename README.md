# CESI Water Quantity Calculator
### Version 2.1

## Overview
R Project for the Canadian Environmental Sustainability Indicators bi-annual reports 

## Features
This R Project is used to calculate [Water Quantity in Canadian rivers](https://www.canada.ca/en/environment-climate-change/services/environmental-indicators/water-quantity-canadian-rivers.html) as part of the Canadian Environmental Sustainability Indicators. The National Water Data Archive [(HYDAT)](https://www.canada.ca/en/environment-climate-change/services/water-overview/quantity/monitoring/survey/data-products-services/national-archive-hydat.html) is used to compare current year flow values against the 1981-2010 normal period. The output information can be used to produce maps, graphs, and an R Markdown report for monitoring changes in flow data.

## Dependencies 
This R Project is best viewed in RStudio, as the Run All script aligns with the stepped calculation of all indicators. Once all scripts until 08_Report_Items have been run, [QGIS](https://qgis.org/en/site/forusers/download.html) is used to produce maps with existing symbology saved in the Map_symbols.xml file. 

## Usage
Introductory documentation is provided in the CESI in R file, with additional steps, comments and data sources noted throughout the code. To generate the indicators, the user sets the current year and the normal period years and values, and can make threshold adjustments for data completeness. 

### INPUT: 
* HYDAT database daily flow values
### OUTPUT: 
* Local indicator values
* Regional indicator values 
* National indicator values
* Maps
* Graphs
* R Markdown Report

## Source Data
The HYDAT database is licenced under the [License Agreement for Use of Environment and Climate Change Canada Data](http://climate.weather.gc.ca/prods_servs/attachment1_e.html) and the [Disclaimer for Near Real-Time and Historical Water Level and Streamflow Information](https://wateroffice.ec.gc.ca/disclaimer_info_e.html). 

## Licence

Copyright 2019 National Hydrological Services

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
