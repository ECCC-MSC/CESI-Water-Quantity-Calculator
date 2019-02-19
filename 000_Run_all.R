#######################################################################
#
#    -###- CANADIAN ENVIRONMENTAL SUSTAINABILITY INDICATORS -###-  
#             -- Water Quantity Indicator Calculator --
#
#              ** USE AT YOUR OWN RISK, NO WARRANTY **
#
#  This project contains scripts used to automate the calculation 
#          of CESI Local, Regional, and National Indicators. 
#
#  Michelle Fairbrother, M.Sc.
#  Environment and Climate Change Canada
#  Created: June 2016 | Updated: January 2019
#
#######################################################################

### (1) Run the scripts below to generate the indicators ("-> Run" button or CTRL-ENTER) ###

  source("00_Packages.R")
  source("01_Configuration.R") # Update year values and thresholds first
  source("02_Get_flow_data.R", echo = TRUE)
  source("03_Percentiles.R", echo = TRUE)
  source("03a_QuebecPercentiles.R", echo = TRUE)
  source("04_ContinuousSeasonal.R", echo = TRUE)
  source("05_LocalIndicator.R") # If you receive an error from this code, add the station codes indicated to the pearse_short_codes.csv
  source("06_RegionalIndicator.R") # If error, add the station to the list of stations to be added to the coverage tree (in code), then redo
  source("07_NationalIndicator.R") 
  source("08_ReportItems.R")

### (2) Create jpg maps with the Map Creation document ###

  # Follow the instructions in the Map Creation folder to create maps for the local and regional indicators. 
  # Save the newly created jpg files in the respective output folders. 

### (3) Create R Markdown report ###

  # This report summarizes the analysis and output information. 
  # Update the computer directory pathways to the 3 images (2 maps and 1 national indicator pie chart) manually in the .Rmd
  # If running the report creator in a new session, ensure Packages and Configuration have been run first. 

    tinytex::install_tinytex() # Downloads Latex 
    tinytex:::is_tinytex() # Should be TRUE - may have to restart R and/or computer
    tlmgr_search('/float.sty')  # If error appears that float.sty cannot be found
    tlmgr_install('float') # Install float 

  # Generate the PDF report (once image paths have been updated)
    rmarkdown::render('CESI_Internal_Report.Rmd',
                  output_file = paste("Output/", year.id, "/", year.id, '_CESI_Internal_Report_', Sys.Date(),'.pdf', sep=''))
