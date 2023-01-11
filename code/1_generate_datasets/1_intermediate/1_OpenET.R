# This script processes the OpenET data that was retrieved from google earth engine using script 0
# by making clipped dfs by month and year. 

library(raster)
library(data.table)
library(here)
library(dplyr)
library(ggplot2)
library(tidyr)
library(stringr)
library(sf)
library(parallel)

source(here("file_paths.R"))

###############################################################################
# consistent grid all will be resampled to

# (only run once)
# grid <- raster(CA_grid_loc)
# study_area <- st_read(study_area_loc) %>% st_transform(st_crs(grid))
# grid <- mask(grid, study_area) %>% crop(study_area)
# writeRaster(grid, grid_loc)

grid <- raster(grid_loc)
study_area <- st_read(study_area_loc) %>% st_transform(st_crs(grid))

###############################################################################


# define read and resample function
clip_resample_save <- function(month, year){
  r <- raster(here(raw_openet_path, paste0("OpenET_", year, "_", month-1, ".tif"))) # the month is zero indexed
  print("raster read")
  
  # clip
  r <- mask(r, study_area) %>% crop(study_area)
  print("raster clipped")
  
  # resample
  raster_r <- r %>% resample(grid, method = "bilinear")
  print("raster resampled")
  
  # save
  writeRaster(x = raster_r, filename = here(intermediate_openet_path, paste0(month, "-", year, ".tif")))
  return(raster)
}

# clip_resample_save(1, 2016)

years <- 2016:2021
months <- list(1:12)

for (year in years){
  no_cores <- detectCores() - 1 # Calculate the number of cores
  print(no_cores)
  cl <- makeCluster(no_cores, type="FORK") # Initiate cluster
  parLapply(cl, months, clip_resample_save, year=year)
  stopCluster(cl)
}