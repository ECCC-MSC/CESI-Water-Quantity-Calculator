#######################################################-
#              R MARKDOWN REPORT ITEMS
#
# Objective: Several values that provide object
# information from the code session are kept and 
# combined in a table for the internal report document. 
# 
# Date Modified: November 2018
#######################################################-

## Please see the CESI_Internal_Report.Rmd for producing this report following database entry and map creation ##

  if(qcyoi_counter == 0) { # If there are no Quebec stations, create norm_overall with the remainder of stations
  
    norm_overall <- round((as.numeric(norm_counter2)/as.numeric(norm_counter1))*100, digits= 2)
  
      } else {
  
    norm_overall <- round(((as.numeric(norm_counter2) + as.numeric(qc_counter2))/(as.numeric(norm_counter1) + as.numeric(qc_counter1)))*100, digits = 2) 
  
      }
  
## Percent of Quebec stations with normal period information ##
  
  if(qcyoi_counter > 0) { # If there is QC data, create qc_overall percentage of records with normal period
    
    qc_overall <- round((as.numeric(qc_counter2)/as.numeric(qc_counter1))*100, digits= 2)
    
  } else { # Otherwise set the other two values as 0 as well
    
    qc_counter1 <- 0
    qc_counter2 <- 0
    qc_counter3 <- 0
    qc_overall <- 0
  }
  


## Create matrix of summary values ##

  extra_var <- matrix(c(as.integer(continuous), continuous_threshold, flow_records, as.integer(norm_counter3), norm_overall, normal_end,
                        normal_start, normal_threshold, qcyoi_counter, as.integer(qc_counter3), qc_overall, qc_nrm_end, qc_nrm_start, 
                        as.integer(seasonal), seasonal_threshold, nrow(all_data), as.character(version), year_id), ncol=18, byrow=TRUE)
  
  colnames(extra_var) <-  c("continuous",  # number of continuous stations overall
                            "continuous_threshold", # minimum number of days per year
                            "flow_stations",  # number of stations with flow data in the main year
                            "stations_w_np", # number of stations with enough normal period years
                            "norm_enough",  # percentage of stations' dates with at least enough data in normal period 
                            "normal_end", # normal period final year
                            "normal_start", # normal period first year
                            "normal_threshold", # minimum number years in the normal period
                            "qc_flow_stations", # number of stations with flow data in the main year for QC stations
                            "qc_stations_w_np", # number of stations with enough normal period years for QC stations
                            "qc_enough", # Percentage of QC stations' dates with at enough data in the normal period
                            "qc_nrm_end", # normal period final year for QC stations
                            "qc_nrm_start", # normal period first year for QC stations
                            "seasonal",  # of seasonal stations overall
                            "seasonal_threshold", # minimum number of days per year for seasonal stations
                            "final_stations", # of stations used for the indicators 
                            "version", # HYDAT database version
                            "year_id") # Year
  
  extra_var <- as.table(extra_var)
  write.csv(extra_var, file = paste("Output/", year_id, "/", year_id, "_report_variables_HYDAT_", version, ".csv", sep = ""), row.names = FALSE)

# Remove all objects from memory
  rm(all_data, continuous, continuous_threshold, extra_var, flow_records, norm_counter1, norm_counter2, norm_counter3, norm_overall, 
     normal_end, normal_start, normal_threshold, qc_counter1, qc_counter2, qc_counter3, qc_nrm_end, qc_nrm_start, qc_overall,
     qcyoi_counter, seasonal, seasonal_threshold, version, year_id) 
  gc()

print("SUCCESS: All output items created. Navigate to the Map Creation folder and create images before running the CESI_Internal_Report.Rmd")  
  
  