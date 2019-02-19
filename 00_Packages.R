###########################################################-
#                     LOAD R PACKAGES 
#
# Objective: Installs and/or loads all packages required for
# functions in the R project. The ipak function was authored
# by Steven Worthington. 
# 
# Date Modified: November 2018
###########################################################-

### Installing and loading from CRAN ###

  ipak <- function(pkg){
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
      sapply(pkg, require, character.only = TRUE)
  }

# Devel: Replace packages with tidyverse
  packages <- c("RSQLite", "lubridate", "data.table", "tidyr", "plyr", "dplyr", "stringr", "pbapply", "rmarkdown", 
              "knitr", "tinytex", "RCurl", "XML")

# Reference - Versions used: 
# RSQLite:  1.0.0, lubridate: 1.6.0, data.table: 1.9.6, tidyr: 0.5.1, plyr: 1.8.4, 
# dplyr: 0.5.0, stringr: 1.1.0, pbapply: 1.3-2, knitr: 1.14, RCurl: 1.95-4.11

  ipak(packages)

### Local package install and loading ###
  
  ipak_local <- function(pkg){
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg)) 
    install.packages("./Dependencies/HYDAT_1.0.tar.gz", repos=NULL, type="source")
      sapply(pkg, require, character.only = TRUE)
  }

  local_packages <- c("HYDAT")

# Reference - Version used: 
# HYDAT: 1.0

  ipak_local(local_packages)

  rm("ipak", "ipak_local", "local_packages", "packages")
