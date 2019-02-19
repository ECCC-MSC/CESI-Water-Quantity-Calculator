###############################################################-
#                       GET FLOW DATA
#
# Objective: Queries the HYDAT database for flow data from the
# current year and normal period years. 
# 
# Date Modified: November 2018
###############################################################-

### Get flow data for normal period and indicator calculation ###

# Get flow data for the current year

  current_year <- dbGetQuery(con, paste("select * from DLY_FLOWS where YEAR = (", year_id, ")", sep="")) 
  
# Count how many stations have data for the internal report
  flow_records <- as.numeric(nrow(distinct(select(current_year, STATION_NUMBER))))

# Create a data table and transform the DLY_FLOW table to long format
  current_year <- data.table(current_year)
  value_cols <- colnames(current_year)[grep("^FLOW\\d+", colnames(current_year))]
  current_year <- melt(current_year, id.vars = c("STATION_NUMBER", "YEAR", 
                                               "MONTH"), measure.vars = value_cols)
  current_year$DAY <- as.numeric(substr(current_year$variable, 5, 6))

# Select relevant columns and remove all "NA" flow values
  current_year <- current_year[ ,.(STATION_NUMBER, YEAR, MONTH, DAY, value)] %>%
    .[order(STATION_NUMBER, YEAR, MONTH, DAY)] %>%
    .[value != "NA"]

# Get flow data for the normal period
  normal_period <- dbGetQuery(con, paste("select * from DLY_FLOWS where YEAR BETWEEN (", normal_start, ") AND (", normal_end, ")", sep ="")) 

# Keep only the records relevant to the year of interest and create a data table - transform
  normal_period <- normal_period[normal_period$STATION_NUMBER %in% current_year$STATION_NUMBER, ]
  normal_period <- data.table(normal_period)

  value_cols <- colnames(normal_period)[grep("^FLOW\\d+", colnames(normal_period))]
  normal_period <- melt(normal_period, id.vars = c("STATION_NUMBER", "YEAR", 
                                                 "MONTH"), measure.vars = value_cols)
  normal_period$DAY <- as.numeric(substr(normal_period$variable, 5, 6))

# Select relevant columns and remove all "NA" flow values
  normal_period <- normal_period[ ,.(STATION_NUMBER, YEAR, MONTH, DAY, value)] %>%
    .[order(STATION_NUMBER, YEAR, MONTH, DAY)] %>%
    .[value != "NA"]
    
# Remove intermediary files
  rm("value_cols")
  gc()    
  