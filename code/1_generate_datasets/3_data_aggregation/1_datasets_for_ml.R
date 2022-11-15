# This script creates datasets ready for use in ML for counterfactual creation

# Anna Boser 11/14/2021

library(here)
library(raster)
library(dplyr)
library(sf)
library(fasterize)
library(data.table)

source("file_paths.R")

# generate a study area raster 

# my grid and study area
grid <- raster(grid_loc)
study_area <- st_read(study_area_loc) %>% st_transform(st_crs(grid))

# turn into raster then dataset
study_area_raster <- fasterize(study_area, grid) 
study_area_df <- as.data.frame(study_area_raster, xy=TRUE)

# get a list of indicators whether a pixel is in the study area
study_area_pixels <- study_area_df$layer

# make the study_area_df ready to tack on new columns
study_area_df <- filter(study_area_df, !is.na(layer))
study_area_df$layer <- NULL

# time invariant columns to tack on
layer_locations <- c("Agriculture"=ag_rast_loc, 
                     "FVEG"=fveg_loc, 
                     "CPAD" =cpad_loc, 
                     "CDL"=cdl_loc, 
                     "Elevation"=elevation_loc, 
                     "Slope"=slope_loc, 
                     "Aspect"=aspect_loc,
                     "Soil"=storie_loc, 
                     "TWI"=twi_loc)

# tack on time invarying columns
for (i in 1:length(layer_locations)){
  layer <- (raster(layer_locations[i]) %>% as.data.frame(xy=TRUE))[!is.na(study_area_pixels),][,3]
  study_area_df[,names(layer_locations)[i]] <- layer
}

# now for time varying columns
layer_paths <- c("ET"=intermediate_ecostress_path, 
                 "PET"=PET_study_area_path)

# for each monthgroup, generate a dataset with ET and PET and smush them together
months <- c("1+2", "3+4", "5+6", "7+8", "9+10", "11+12")
add_monthgroup <- function(monthgroup, dataset, year){
  
  #specify which monthgroup you're adding
  dataset$month <- monthgroup
  dataset$year <- year
  
  # add all of the time varying variables for that monthgroup
  for (i in 1:length(layer_paths)){
    layer_loc = here(layer_paths[i], paste0(monthgroup, "-", year, ".tif"))
    layer <- (raster(layer_loc) %>% as.data.frame(xy=TRUE))[!is.na(study_area_pixels),][,3]
    dataset[,names(layer_paths)[i]] <- layer
  }
  
  return(dataset)
}

time_varrying_df <- rbindlist(lapply(months, add_monthgroup, dataset=study_area_df, year="all"))

# save only the agricultural dataset
ag = time_varrying_df[!is.na(Agriculture)]
dir.create(directory_path(ag_data_loc))
fwrite(ag, here(ag_data_loc), append=FALSE)

# save the natural dataset (FVEG, CPAD, and CDL)
fveg = time_varrying_df[!is.na(FVEG)]
dir.create(natural_data_path)
fwrite(fveg, here(natural_data_path, "fveg.csv"), append=FALSE)

cpad = time_varrying_df[!is.na(CPAD)]
fwrite(cpad, here(natural_data_path, "cpad.csv"), append=FALSE)

cdl = time_varrying_df[!is.na(CDL)]
fwrite(cdl, here(natural_data_path, "cdl.csv"), append=FALSE)


