library(here)
library(tidyr)
library(dplyr)
library(ggplot2)
library(rgdal)
library(maptools)
library(data.table)
library(sf)
library(stringr)

source(here("file_paths.R"))

experiment_name <- "fallow0.05,2_4-18_gb"
experiment_path <- here("data", "4_for_analysis", "ML_outputs",  "experiments", experiment_name)

months_ts <- TRUE
years_ts <- TRUE

data <- fread(file = here(experiment_path, "agriculture_dwr_years.csv"))

data[data == -9999] <- NA # this is the na value

if (months_ts){
  # get a nice column of numeric months
  months <- select(data, names(data)[grepl("month", names(data))])
  data$month <- names(months)[max.col(months)]
  data$month <- str_extract(data$month, '(?<=_)\\d+') %>% as.numeric()
  data <- select(data, !names(data)[grepl("month_", names(data))])
}

if (years_ts){
  # get a nice column of numeric years
  years <- select(data, names(data)[grepl("year", names(data))])
  data$year <- names(years)[max.col(years)]
  data$year <- str_extract(data$year, '(?<=_)\\d+') %>% as.numeric()
  data <- select(data, !names(data)[grepl("year_", names(data))])
}

# save this
fwrite(data, here(experiment_path, "agriculture_tidy.csv"), append = FALSE)
# data <- fread(here(experiment_path, "agriculture_tidy.csv"))

# save a version with only fallow lands
fallow <- filter(data, cropnames %in% c("Unclassified fallow", "Idle"))
fwrite(fallow, here(experiment_path, "fallow.csv"))

if (months_ts == TRUE | years_ts == TRUE){
  # Average over months/years
  data <- data %>% group_by(x, y, Elevation,Slope,Aspect,Soil,TWI,NAME,coverage_fraction) %>% summarize(ET = mean(ET, na.rm=TRUE),
                                                  ET_pred = mean(ET_pred, na.rm=TRUE),
                                                  PET = mean(PET, na.rm=TRUE),
                                                  ag_ET = ET-ET_pred)
}

# save this
fwrite(data, here(experiment_path, "agriculture_time_constant.csv"))

# averaged over months only
data <- fread(here(experiment_path, "agriculture_tidy.csv"))
if (months_ts == TRUE){
  # Average over months to get yearly numbers
  data <- data %>% group_by(x, y, year, cropnames, subcropnames, Elevation,Slope,Aspect,Soil,TWI,NAME,coverage_fraction) %>% summarize(ET = mean(ET, na.rm=TRUE), 
                                                  ET_pred = mean(ET_pred, na.rm=TRUE), 
                                                  PET = mean(PET, na.rm=TRUE),
                                                  ag_ET = ET-ET_pred)
}
fwrite(data, here(experiment_path, "agriculture_yearly.csv"), append=FALSE)

# averaged over years only
data <- fread(here(experiment_path, "agriculture_tidy.csv"))
if (years_ts == TRUE){
  # Average over years to get monthly numbers
  data <- data %>% group_by(x, y, month, cropnames, subcropnames, Elevation,Slope,Aspect,Soil,TWI,NAME,coverage_fraction) %>% summarize(ET = mean(ET, na.rm=TRUE), 
                                                  ET_pred = mean(ET_pred, na.rm=TRUE), 
                                                  PET = mean(PET, na.rm=TRUE),
                                                  ag_ET = ET-ET_pred)
}
fwrite(data, here(experiment_path, "agriculture_monthly.csv"), append=FALSE)

########################################################################
# average by croptype and subcroptype
data <- fread(here(experiment_path, "agriculture_tidy.csv"))

######## clean data #######

data <- data[cropnames != "",] # only keep data that has crop info (get rid of years without dwr data)
data <- data[cropnames != "Urban - residential, commercial, and industrial, unsegregated",] # remove urban
data$cropnames <- ifelse(data$cropnames %in% c("Unclassified fallow", "Idle"), "Fallow", data$cropnames) # rename unclassified fallow to just fallow

data <- filter(data, coverage_fraction>.5)

# only keep fallow pixels that are in the test set
# do this even when using fveg just to have a good comparison
test <- fread(here(test_data_path, paste0("fallow0.05,2_test.csv")))
list <- unique(paste(test$x, test$y, test$year))
data <- data %>% filter(!(paste(data$x, data$y, data$year) %in% list))
rm(test)  


data$subcropnames <- ifelse(data$subcropnames == "", data$cropnames, data$subcropnames)

# get rid of classes I'm not that interested in 
data <- filter(data,  !(subcropnames %in% c("Greenhouse")))

######### crop and subcrop averages by month ########
c_df <- data %>% 
  group_by(cropnames, month) %>%
  summarize(ag_ET = mean(ag_ET), 
            ET = mean(ET), 
            ET_pred = mean(ET_pred))
fwrite(c_df, here(experiment_path, "time_series_by_crop.csv"))

sc_df <- data %>% 
  group_by(subcropnames, month) %>%
  summarize(ag_ET = mean(ag_ET), 
            ET = mean(ET), 
            ET_pred = mean(ET_pred)) 
fwrite(sc_df, here(experiment_path, "time_series_by_subcrop.csv"))

########################################################################
# average by croptype&county and subcroptype&county for CalSIMETAW comparison

# to combine with CalSIMETAW, combine pistachios and almonds together
data$subcropnames <- ifelse(data$subcropnames %in% c("Pistachios", "Almonds"), "Almond & Pistacios", data$subcropnames)

c_df <- data %>% 
  group_by(cropnames, COUNTY_NAME = NAME, month) %>%
  summarize(ag_ET = mean(ag_ET), 
            ET = mean(ET), 
            ET_pred = mean(ET_pred), 
            latitude = mean(y))

sc_df <- data %>% 
  group_by(cropnames = subcropnames, COUNTY_NAME = NAME, month) %>%
  summarize(ag_ET = mean(ag_ET), 
            ET = mean(ET), 
            ET_pred = mean(ET_pred), 
            latitude = mean(y)) %>% 
  filter(!(cropnames %in% c_df$cropnames))

fwrite(rbind(c_df, sc_df), here(experiment_path, "agriculture_monthly_county_crop.csv"))
