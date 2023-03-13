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


experiment_name <- "fallow_3-9_gb"
experiment_path <- here("data", "4_for_analysis", "ML_outputs",  "experiments", experiment_name)
months_ts <- TRUE
years_ts <- TRUE

# data <- fread(file = here(experiment_path, "agriculture_dwr_years.csv"))

# data[data == -9999] <- NA # this is the na value

# if (months_ts){
#   # get a nice column of numeric months
#   months <- select(data, names(data)[grepl("month", names(data))])
#   data$month <- names(months)[max.col(months)] 
#   data$month <- str_extract(data$month, '(?<=_)\\d+') %>% as.numeric()
#   data <- select(data, !names(data)[grepl("month_", names(data))])
# }

# if (years_ts){
#   # get a nice column of numeric years
#   years <- select(data, names(data)[grepl("year", names(data))])
#   data$year <- names(years)[max.col(years)] 
#   data$year <- str_extract(data$year, '(?<=_)\\d+') %>% as.numeric()
#   data <- select(data, !names(data)[grepl("year_", names(data))])
# }

# # save this
# fwrite(data, here(experiment_path, "agriculture_tidy.csv"))

# # save a version with only fallow lands
# fallow <- filter(data, cropnames %in% c("Unclassified fallow", "Idle"))
# fwrite(fallow, here(experiment_path, "fallow.csv"))

# if (months_ts == TRUE | years_ts == TRUE){
#   # Average over months/years
#   data <- data %>% group_by(x, y, Elevation,Slope,Aspect,Soil,TWI,NAME,coverage_fraction) %>% summarize(ET = mean(ET, na.rm=TRUE), 
#                                                   ET_pred = mean(ET_pred, na.rm=TRUE), 
#                                                   PET = mean(PET, na.rm=TRUE),
#                                                   ag_ET = ET-ET_pred)
# }

# # save this
# fwrite(data, here(experiment_path, "agriculture_time_constant.csv"))

# averaged over months only
data <- fread(here(experiment_path, "agriculture_tidy.csv"))
if (months_ts == TRUE){
  # Average over months/years
  data <- data %>% group_by(x, y, year, Elevation,Slope,Aspect,Soil,TWI,NAME,coverage_fraction) %>% summarize(ET = mean(ET, na.rm=TRUE), 
                                                  ET_pred = mean(ET_pred, na.rm=TRUE), 
                                                  PET = mean(PET, na.rm=TRUE),
                                                  ag_ET = ET-ET_pred)
}
fwrite(data, here(experiment_path, "agriculture_yearly.csv"), append=FALSE)

# # get the tidy dataset to make a dataset with crop water use by year
# data <- fread(here(experiment_path, "agriculture_tidy.csv"))

# # remove the observations that don't have crop type info
# data <- data[!(cropnames == ""),]

# if (months_ts == TRUE){
#   # Average over monthgroups
#   data <- data %>% group_by(x, y, year, cropnames) %>% summarize(ET = mean(ET, na.rm=TRUE), 
#                                                   ET_pred = mean(ET_pred, na.rm=TRUE), 
#                                                   ag_ET = ET-ET_pred, 
#                                                   PET = mean(PET, na.rm=TRUE))
# }

# bardata = data %>% 
#   pivot_longer(cols=c(ET, ET_pred, ag_ET), names_to="type", values_to="ET") %>%
#   group_by(cropnames, type) %>%
#   summarize(sd = sd(ET, na.rm = TRUE), 
#             ET = mean(ET, na.rm = TRUE)) 

# bardata$type <- factor(bardata$type, levels=c("ET", "ET_pred", "ag_ET"))

# # create clusters based on location and year. Function creates clusters of size dist km. 
# assign_cluster <- function(x, y, year, dist){
  
#   x_size = dist/89 # 1 degree lon (x) = 89km = 89000m
#   y_size = dist/111 # 1 degree lat (y) = 111km = 111000m
  
#   x_fold = floor(x/x_size)*x_size
#   y_fold = floor(y/y_size)*y_size
  
#   cv_fold = paste(x_fold, y_fold, year, sep = ",")
  
#   return(cv_fold)
# }

# data$cluster <- mapply(assign_cluster, data$x, data$y, data$year, 35)


# # get the tidy dataset to make a dataset with county irrigation efficiency
# data <- fread(here(experiment_path, "agriculture_tidy.csv"))