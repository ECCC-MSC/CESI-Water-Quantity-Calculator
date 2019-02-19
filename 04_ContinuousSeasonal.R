##############################################################-
#              CONTINUOUS AND SEASONAL CHECK
#
# Objective: Differentiates seasonal and continuous stations 
# to to determine whether the user specified thresholds are
# met (default is 80% per year).
# 
# Date Modified: November 2018
##############################################################-

# Select sites that have station information at least until the year of interest
  operation <- dbGetQuery(con, paste("select* from STN_DATA_COLLECTION where YEAR_TO >= (", year_id, ")", sep=""))
  operation <- filter(operation, DATA_TYPE == "Q") # Keep only flow records - can combine with above

# Keep only records common to the selection and the year of interest stations
  op_select <- operation[operation$STATION_NUMBER %in% all_tally$STATION_NUMBER,] %>%
                                select(STATION_NUMBER, OPERATION_CODE) %>% 
                                distinct() # Remove duplicates

# Join the year of interest data and the operation type
  joined <- inner_join(all_tally, op_select, by = "STATION_NUMBER")  # Final object from 3a

# Separate seasonal and continuous stations
  seasonal <- subset(joined, OPERATION_CODE == 'S') %>%
                        mutate(sum = Low + Normal + High) %>% # Add days
                        subset(sum > seasonal_threshold)  # Keep records with enough
  continuous <- subset(joined, OPERATION_CODE == 'C') %>% 
                    mutate(sum = Low + Normal + High) %>%
                    subset(sum > continuous_threshold)

# Re-combine the two types
  all_data <- bind_rows(seasonal, continuous)
  
  seasonal <- nrow(seasonal)
  continuous <- nrow(continuous)
 
# Remove previous objects to free up memory  
  rm(list = c("joined", "operation", "op_select", "all_tally")) 
  gc() 
  
