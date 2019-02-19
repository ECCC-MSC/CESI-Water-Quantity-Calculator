#############################################################-
#                     CONFIGURATION
#
# Objective: Update the customizeable year values and 
# thresholds before saving and running this script. Connects
# to the HYDAT database or downloads the file if not present.
# 
# Date Modified: November 2018
#############################################################-

### (1) Date specifications ###

# Specify the year of interest
  year_id <- 2012
  
# Set the normal period dates
  normal_start <- 1981
  normal_end <- 2010

### (2) Threshold values ###
  
# The number of years of data required for each day in the normal period
# For instance, January 1st must have at least 25/30 flow values in 30 years of data
  normal_threshold <- 25
  
# The number of days with flow values required in the analysis for different types of stations
  seasonal_threshold <- 174 # Missing no more than 43 days of 217 for seasonal stations 
  continuous_threshold <- 292 # Missing no more than 73 days of 365 for continuous stations
  
### (3) Quebec dates ###
  
# Set the normal period dates for northern Quebec stations
  qc_nrm_start <- 1981
  qc_nrm_end <- 2010

### (4) Connect to the database ###
  
  # If the most recent Hydat.sqlite file is not already in the Packages folder, it will be downloaded
  
  HYDAT_URL <- "http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/"
  result <- getURL(HYDAT_URL,verbose=TRUE,ftp.use.epsv=TRUE, dirlistonly = TRUE)
  SQLite_file <- getHTMLLinks(result, xpQuery = "//a/@href[contains(., 'sqlite')]")
  
  if( length( grep("Hydat", list.files("./Dependencies/Hydat/")))==0){
    
    dir.create("./Dependencies")
    dir.create("./Dependencies/Hydat")
    URL = paste0(HYDAT_URL, SQLite_file); download.file(URL, "./Dependencies/Hydat.zip"); 
    unzip("./Dependencies/Hydat.zip", exdir="./Dependencies/Hydat")	
    
  }
  
  ## Connect to the HYDAT database ##
  con <- dbConnect(RSQLite::SQLite(), "./Dependencies/Hydat/Hydat.sqlite3")
  
### (5) No changes required to this section, necessary for output file naming ###
###  and identification for the R Markdown report ###
  
# Version number for file naming
  version <- dbGetQuery(con, "select* from VERSION") %>% 
    select(Date) %>% 
    substr(0, 7) # Select the year and month
  
# Clear objects for memory space
    rm("HYDAT_URL", "result", "SQLite_file")
  