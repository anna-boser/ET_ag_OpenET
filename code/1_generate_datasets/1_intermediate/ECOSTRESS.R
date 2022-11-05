# This file takes the ECOSTRESS data, resamples it to the consistent CA grid, 
# and makes averages for each month. 

# Anna Boser November 5, 2022

library(here)
library(raster)
library(dplyr)
library(rgdal)
library(data.table)
library(stringr)
library(lubridate)
library(sf)
library(parallel)

source(here("code", "file_paths.R"))

###############################################################################
# consistent grid all will be resampled to

# (only run once)
# grid <- raster(CA_grid_loc)
# study_area <- st_read(study_area_loc) %>% st_transform(st_crs(grid))
# grid <- mask(grid, study_area) %>% crop(study_area)
# writeRaster(grid, grid_loc)

grid <- raster(grid_loc)

###############################################################################

# define read and resample function
read_resample <- function(file){
  raster <- raster(file)
  print("raster read")
  raster <- raster(file) %>% resample(grid, method = "bilinear")
  print("raster resampled")
  return(raster)
}


# year is a numeric arguments
# months is a list of numbers (e.g. c(1,2))
# options for var: 'ETdaily', 'ETdailyUncertainty', 'QualityFlag'
process <- function(year, months, var="ETdaily", alg="ALEXI"){
  print(paste("Processing year", year, "and month(s)", paste(months, collapse="+")))
  # list the files for this year
  files <- list.files(here(raw_ecostress_path, year), 
                      full.names = TRUE) %>% unique() #get rid of any duplicates
  
  # subset for this variable
  files <- str_subset(files, regex(paste0('(?<=', alg, '_)', var, '(?=_doy)')))

  # subset for this month
  timestamps <- str_extract(files, regex('(?<=_doy)[0-9]*(?=_aid0001.tif)'))
  date <- as.Date(timestamps, "%Y%j%H%M%S")
  files <- files[month(dates) %in% months]
  
  # read and resample 
  print(paste("reading in", length(files), "rasters"))
  rasters <- lapply(files, read_resample)
  
  # make a brick
  print("making a brick")
  brick <- brick(rasters)
  rm(rasters)
  
  # save the brick
  print("saving the brick")
  filename <- paste0(paste(months, collapse="+"), "-", year, ".tif")
  writeRaster(brick, here(ECOSTRESS_bricks_path, filename), "GTiff", overwrite=TRUE)
  
  # take the mean
  print("taking the mean of the brick")
  mean <- mean(brick, na.rm = TRUE)
  rm(brick)
  
  # save the mean
  print("saving the mean")
  writeRaster(mean, here(intermediate_ecostress_path, filename), "GTiff", overwrite=TRUE)
}

years <- 2019:2021
months <- list(c(1,2), c(3,4), c(5,6), c(7,8), c(9,10), c(11,12))
for (year in years){
  no_cores <- detectCores() - 1# Calculate the number of cores
  print(no_cores)
  cl <- makeCluster(no_cores, type="FORK") # Initiate cluster
  parLapply(cl, months, process)
  stopCluster(cl)
}

