#######################################################-
#                  LOCAL INDICATOR
#
# Objective: Combine the output values with station 
# information to produce the local indicator table. 
# 
# 
# Date Modified: November 2018
#######################################################-

# First, need to combine all of the relevant columns from the HYDAT database to the all.data table
# This information is from multiple tables in HYDAT in differing formats/with differing headers than
# than the output spreadsheet, so there are a few alterations performed here to make them align

# Select and rename the final all.tally columns (STATION_NUMBER required for matching in HYDAT)
  output_table <- select(all_data, STATION_NUMBER, Low, Normal, High, Flow_Type = Label, OperSched = OPERATION_CODE)

# Replace "C" and "S" with "Continuous" and "Seasonal"
  output_table$OperSched <- gsub("C", "Continuous", output_table$OperSched)
    output_table$OperSched <- gsub("S", "Seasonal", output_table$OperSched)

# Extract relevant columns from the STATIONS table in HYDAT and connect them to the final list
  stations <- dbGetQuery(con, "select STATION_NUMBER, STATION_NAME, PROV_TERR_STATE_LOC, LATITUDE, LONGITUDE, DRAINAGE_AREA_GROSS, OPERATOR_ID from STATIONS" )
    output_table <- inner_join(output_table, stations, by = "STATION_NUMBER")
  
# Extract the years of operation for flow data from the STN_DATA_RANGE table and append to the list 
  year_range <- dbGetQuery(con, "select STATION_NUMBER, YEAR_FROM, YEAR_TO, RECORD_LENGTH from STN_DATA_RANGE where DATA_TYPE == 'Q'" )
    output_table <- inner_join(output_table, year_range, by = "STATION_NUMBER")

# Extract the Regulated/Natural information from the STN_REGULATION table
  stn_regulation <- dbGetQuery(con, "select STATION_NUMBER, REGULATED from STN_REGULATION")
    output_table <- inner_join(output_table, stn_regulation, by = "STATION_NUMBER")

# Replace the OPERATOR_ID with the full operator's name
  agency_names <- dbGetQuery(con, "select AGENCY_ID, AGENCY_EN from AGENCY_LIST")
    output_table <- merge(output_table, agency_names, by.x = "OPERATOR_ID", by.y = "AGENCY_ID") 

# Match up the Pearse Drainage Areas - make a copy and get the first four characters of each code
  yoi_copy <- output_table
    yoi_copy$STATION_NUMBER <- substr(yoi_copy$STATION_NUMBER, 0, 4)
      stn_short <- select(yoi_copy, STATION_NUMBER)

# Call on the list of Pearse codes and match it with year of interest station codes
  pearse_short_codes <- read.csv("./Dependencies/pearse_short_codes.csv")
    pearse_complete <- join(stn_short, pearse_short_codes, by = "STATION_NUMBER")
      pearse_cols <- select(pearse_complete, PEARSEDA, PERSEDA_CODE)
        yoi_with_pearse <- bind_cols(output_table, pearse_cols)

## Sanity Check ## 
  
# Check if any station codes do not have a Pearse Drainage Area code associated with them 
  
  pearse_complete$PERSEDA_CODE[is.na(pearse_complete$PERSEDA_CODE)] <- 0
    na_stations <- subset(pearse_complete, PERSEDA_CODE == 0) %>% select(STATION_NUMBER) %>% unique()

  try(if(nrow(na_stations) >= 1) stop(paste("Add Pearse Code to pearse_short_codes file for ", na_stations, sep = "")))

# If there are any records without a Pearse Code, use ECDE or previous database entries to determine the name and code
# and add these to the pearse_short_codes csv in Excel. Then re-run the four lines before
# the sanity check and the code will appear. There are also some stations that do not follow
# the four character code naming pattern (on a border). Known exceptions are 02MB006
# (Great Lakes), and 05LL019 (Assiniboine Red). Have a look for these stations in the export
# file for the database, and adjust if necessary. 

# Round latitude, longitude, and drainage area columns
  yoi_with_pearse$LATITUDE <- round(yoi_with_pearse$LATITUDE, digits = 5)
    yoi_with_pearse$LONGITUDE <- round(yoi_with_pearse$LONGITUDE, digits = 5)
      yoi_with_pearse$DRAINAGE_AREA_GROSS <- round(yoi_with_pearse$DRAINAGE_AREA_GROSS, digits = 2)
  
# Extract the columns that match the ones in the annual reporting database (in that order)
  yoi_complete <- select(yoi_with_pearse, Station = STATION_NUMBER, Low, Normal, High, Flow_Type, PEARSEDA, PERSEDA_CODE, StationName = STATION_NAME,
                       Prov = PROV_TERR_STATE_LOC, Latitude = LATITUDE, Longitude = LONGITUDE, DrainageArea = DRAINAGE_AREA_GROSS,
                       Years = RECORD_LENGTH, From = YEAR_FROM, To = YEAR_TO, Reg.= REGULATED, OperSched, Operator = AGENCY_EN)
  yoi_complete <- yoi_complete[order(yoi_complete$Station),] # Order by station number

# Create output folder for the current year
  dir.create(paste("Output/", year_id, sep = ""), recursive = TRUE)

# Write the local entry to the output folder in a file for that year, with the HYDAT version appended
  write.csv(yoi_complete, file = paste("Output/", year_id, "/", year_id, "_local_entry_HYDAT_", version, ".csv", sep = ""), row.names = FALSE)

### Refer to the CESI_Map_Creation document for using this spreadsheet to create a local map for internal use ###
  
# Remove intermediate objects
  rm("agency_names", "na_stations", "output_table", "pearse_cols", "pearse_complete", "pearse_short_codes", "stations",
     "stn_short", "year_range", "stn_regulation", "yoi_with_pearse", "yoi_copy")
  