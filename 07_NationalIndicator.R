#######################################################-
#                  NATIONAL INDICATOR
#
# Objective: Counts the number of high low and normal
# station to compute the national indicator values. 
# 
# 
# Date Modified: November 2018
#######################################################-

# Find the proportions of High, Normal, and Low
  high <- filter(all_data, Label == "High") %>% nrow %>% print
  normal <- filter(all_data, Label == "Normal") %>% nrow %>% print
  low <- filter(all_data, Label == "Low") %>% nrow %>% print

  all <- nrow(all_data) %>% print

# Create the values for a pie chart
  prophigh <- high/all
  propnorm <- normal/all
  proplow <- low/all

# Create simple pie chart
  slices <- c(prophigh, propnorm, proplow)
  lbls <- c("High", "Normal", "Low")
  pct <- round(slices/sum(slices)*100)
  lbls <- paste(lbls, pct) # add percents to labels
  lbls <- paste(lbls,"%",sep="") # add % to labels

  jpeg(file = paste("Output/", year_id, "/", year_id, "_national_indicator_HYDAT_", version, ".jpg", sep = ""))
  pie(slices,labels = lbls, col= c("dodgerblue4", "darkolivegreen4", "orangered") ,main= paste(year_id, " Station Classifications", sep = ""))
    dev.off()

# Remove intermediate objects
    rm(all, high, low, normal, pct, prophigh, proplow, propnorm, slices, lbls)
    gc()
    