#######################################################-
#                 REGIONAL INDICATOR
#
# Objective: The most downstream stations in each  
# Pearse Drainage Area are identified. These stations 
# are used to create the regional indicator table.
# 
# Date Modified: November 2018
#######################################################-

# Source the upstReam package and coverage tree file
  source('./Dependencies/upstReam.R')
  coverage <- "./Dependencies/coverage.txt"  

# Remove stations that are not yet in the coverage tree
# ADD STATIONS THAT CAUSE AN ERROR HERE
  yoi_complete <- filter(yoi_complete, !Station %in% c("05PE006", "02HA003", "02HA019", 
                                                       "02OA003", "02OA016", "05HF015", 
                                                       "05JC005", "05KA001", "05AF029",
                                                       "05EB910", "05ED003", "05GA011",
                                                       "05AF031", "05CK007", "07GD002", 
                                                       "10LC003", "10LC007", "11AC065", 
                                                       "11AC066", "03OD006", "05AD027", 
                                                       "05BD004", "05PE005", "05PE020", 
                                                       "11AB114", "11AB115", "10LC002", 
                                                       "05AA023", "05AC025", "05OJ010",
                                                       "07JF004", "08HA033", "08HB024")) # For stations not yet in the tree
  
# Create list of Pearse Drainage Areas
  p_drainage <- select(yoi_complete, PEARSEDA) %>% unique()
  p_drainage <- data.table(as.character(unlist(p_drainage)))
  colnames(p_drainage) <- "PEARSEDA"

# Read the coverage tree (downstream station relations)
  x <- read_coverage_tree(coverage)

## Convert tree to matrix for ease-of-use
##  Warnings occur when trying to set upstream stations for a station with nothing upstream
  M <- tree_to_matrix(x)

# Find most downstream stations for all Pearse Drainage Areas
  findDownstreamStations <- function(p_drainage) {
  
    p_drainage_select <- p_drainage[["PEARSEDA"]] # Select PDA
 
    station_select <- filter(yoi_complete, PEARSEDA == p_drainage_select) %>% select(Station) # Grab all stations
    
    Msmall <- subset_table(M, stn_list = unlist(station_select, use.names=FALSE)) # Select relevant matrix rows
  
    downstream_result <- most_downstream(Msmall) # Identify most downstream
  
    return(downstream_result)
  
  }

  downstream_stations <- apply(p_drainage, 1, findDownstreamStations) 

# Create list and add header
  downstream_stations <- data.table(unlist(downstream_stations))
  colnames(downstream_stations) <- "Station"

# Obtain details from overall spreadsheet with records from all stations
  downstream_details <- yoi_complete[yoi_complete$Station %in% downstream_stations$Station,]

# Extract columns in the order that is in the database
  regional_entry <- select(downstream_details, Station, Flow_Type, PEARSEDA, PERSEDA_CODE, StationName, Prov,
                         Latitude, Longitude, DrainageArea, Years, From, To, Reg., OperSched, Operator)

# Export to csv for entry into the database
  write.csv(regional_entry, file = paste("Output/", year_id, "/", year_id, "_regional_entry_HYDAT_", version, ".csv", sep = ""), row.names = FALSE) # Customize name for year of interest

### Regional map section, and calculation of percent gaged for each region ###

# Import total drainage areas for all Pearse Drainage Areas 
  pd_area <- read.csv("./Dependencies/Total_PDA_areas.csv", header = TRUE)

# Import updated station drainage areas, created by clipping border stations and those that cross PDA borders
  station_drainage <- read.csv("./Dependencies/Updated_drainage_areas.csv", header = TRUE)
  station_new_drainage <- select(station_drainage, Station, FinalArea)

# Add the percent drainage area for each category, and sum by region and then type
  regional_area <- left_join(regional_entry, station_new_drainage, by = "Station")
  regional_area[is.na(regional_area)] <- 0
  regional_area <- right_join(regional_area, pd_area, by = "PERSEDA_CODE")
  regional_area <- regional_area %>% group_by(PERSEDA_CODE, Flow_Type) %>% mutate(AreaByClass = sum(FinalArea))
  regional_area <- select(regional_area, Flow_Type, PERSEDA_CODE, TOTAL_DA, AreaByClass)
  regional_area <- distinct(regional_area, TOTAL_DA, AreaByClass)

# Compute percentages and classify with the largest category in terms of total drainage area
  regional_area <- regional_area %>% mutate(MajorDrainage = AreaByClass/TOTAL_DA)
  regional_area <- regional_area %>% group_by(PERSEDA_CODE) %>% mutate(MaxArea = max(MajorDrainage))  
  regional_area <- regional_area %>% group_by(PERSEDA_CODE) %>% mutate(TotalGauged = sum(MajorDrainage))

# Additional variables for report - Percent gauged by each category
  low_areas <- subset(regional_area, Flow_Type== "Low") %>% select(PERSEDA_CODE, LowDrainage = MajorDrainage)
  normal_areas <- subset(regional_area, Flow_Type == "Normal") %>% select(PERSEDA_CODE, NormalDrainage = MajorDrainage)
  high_areas <- subset(regional_area, Flow_Type == "High") %>% select(PERSEDA_CODE, HighDrainage = MajorDrainage)

# Number of stations in each category
  no_stations <- regional_area %>%
    group_by(PERSEDA_CODE, Flow_Type) %>%
    tally() %>%
    ungroup() %>%
    spread(Flow_Type, n)

# Separate only the rows that have the category with the largest drainage area to create the final table structure
  major_class <- subset(regional_area, MajorDrainage == MaxArea)

# Append all additional variables to the final table 
  reg_table <- left_join(major_class, no_stations, by = "PERSEDA_CODE") %>% 
                           left_join(., low_areas, by = "PERSEDA_CODE") %>%
                           left_join(., normal_areas, by = "PERSEDA_CODE") %>% left_join(., high_areas, by = "PERSEDA_CODE")
  reg_table <- reg_table %>% mutate(funs(round(.,4)), TotalGauged, MajorDrainage, LowDrainage, NormalDrainage, HighDrainage) 

# Select relevant columns in order (for export)
  reg_table <- select(reg_table, PERSEDA_CODE, Flow_Type, TOTAL_DA, TotalGauged, MajorDrainage, 
                           Low, LowDrainage, Normal, NormalDrainage, High, HighDrainage) %>%
                           arrange(PERSEDA_CODE)

# This table shows the largest category by drainage area (Low, Normal, High) for each drainage region
# Flow_Type tells you the overall category based on the largest drainage area covered by stations
# Total_DA tells you the total area for the Pearse Drainage Region as per the PERSEDA_CODE
# TotalGauged is the sum of all three categories, or the percent of the overall area that is gaged by all downstream stations
# MajorDrainage is the percent of the overall region that is captured by the largest category by area
# The remainder of the columns describe the number of downstream stations contributing to the drainage area covered
# by each class (Low, Normal, High)

# Write to file for internal report and also to create the regional map
  write.csv(reg_table, file = paste("Output/", year_id, "/", year_id, "_regional_map_HYDAT_", version, ".csv", sep = ""), row.names = FALSE) # Customize output name

# Refer to the CESI_Map_Creation document for using this spreadsheet to create a regional map for internal use

  rm(downstream_details, downstream_stations, high_areas, low_areas, M, major_class, no_stations, normal_areas, pd_area, 
     reg_table, regional_area, regional_entry, station_drainage, station_new_drainage, x, yoi_complete, coverage, p_drainage, 
     add_station_to_table, check_symmetry, check_transitivity, findDownstreamStations, get_downstream, get_upstream, 
     initialize_matrix_from_stations, load_table, most_downstream, populate_table_from_delineations, read_coverage_tree,
     readsimple, save_table, set_downstream, set_downstream_recursive, set_relative_position, set_upstream, set_upstream_recursive, 
     subset_table, tree_get_all_upstream, tree_get_upstream, tree_to_matrix, upstream_stations_from_delineation)
  gc()
