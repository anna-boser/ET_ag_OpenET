# This script takes daily PET information, aggregates it to the time steps used in 
# this study, and resamples it to the consistent 70m grid. 

# Anna Boser November 7, 2022

library(here)
library(raster)
library(dplyr)
library(sf)
library(lubridate)
library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
library(parallel)

source("file_paths.R")

CA_grid <- raster(CA_grid_loc)
CA <- st_read(CA_shp_loc) %>% st_transform(st_crs(CA_grid))
study_area <- st_read(study_area_loc) %>% st_transform(st_crs(CA_grid))

process_pet <- function(months, year){
  
  
  PET <- nc_open(here(raw_PET_path, paste0(year, "_daily_pet.nc")))
  
  lon <- ncvar_get(PET, "longitude")
  lat <- ncvar_get(PET, "latitude")
  time <- ncvar_get(PET, "time") + 1 # the dates start at 0
  
  #############################################################################
  # keep only California
  
  # the smallest lon in the PET dataset's lon values that would encompass CA
  minlon <- unique(lon)[lon < st_bbox(CA)$xmin]
  lonstart <- length(minlon)
  minlon <- minlon[length(minlon)]
  
  # the largest lon in the PET dataset's lon values that would encompass CA
  maxlon <- unique(lon)[lon > st_bbox(CA)$xmax]
  maxlon <- maxlon[1]
  
  # the smallest lat in the PET dataset's lat values that would encompass CA
  minlat <- unique(lat)[lat < st_bbox(CA)$ymin]
  minlat <- minlat[1]
  
  # the largest lon in the PET dataset's lon values that would encompass CA
  maxlat <- unique(lat)[lat > st_bbox(CA)$ymax]
  latstart <- length(maxlat)
  maxlat <- maxlat[length(maxlat)]
  
  #how many to include
  lonlen <- length(lon[lon > st_bbox(CA)$xmin & lon < st_bbox(CA)$xmax])
  latlen <- length(lat[lat > st_bbox(CA)$ymin & lat < st_bbox(CA)$ymax])
  
  #############################################################################
  # keep only the months of interest
  dates <- strptime(paste(year, time), format="%Y %j")
  days <- time[month(dates) %in% months]
  
  #############################################################################
  # load subset
  PET.array <- ncvar_get(PET, "pet", start = c(lonstart,latstart,min(days)), count = c(lonlen,latlen,length(days)))
  dim(PET.array)
  
  # turn into a rasterbrick
  brick <- brick(PET.array, crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
  brick <- t(brick) # for some reason x in lat and y is lon -- switch
  extent(brick)<-extent(c(minlon, maxlon, minlat, maxlat)) # the extents are somehow between 0 and 1 boo
  values(brick)[values(brick) > 600000000000000000000000000000000000] <- NA # get rid of the ocean with super high PET
  
  #############################################################################
  # mean
  mean <- mean(brick, na.rm = TRUE)
  
  # save
  filename <- paste0(paste(months, collapse="+"), "-", year, ".tif")
  dir.create(PET_means_path)
  writeRaster(mean, here(PET_means_path, filename), "GTiff", overwrite=TRUE)
  
  #############################################################################
  # resample
  resampled <- mean %>% projectRaster(CA_grid) %>% resample(CA_grid, method = "bilinear")
  rm(mean)
  
  # save
  dir.create(PET_resampled_path)
  writeRaster(resampled, here(PET_resampled_path, filename), "GTiff", overwrite=TRUE)
  
  #############################################################################
  # clip to study area
  sa <- mask(resampled, study_area) %>% crop(study_area)
  rm(resampled)
  
  # save
  dir.create(PET_study_area_path)
  writeRaster(sa, here(PET_study_area_path, filename), "GTiff", overwrite=TRUE)
}

years <- 2016:2021
months <- 1:12 # list(c(1,2), c(3,4), c(5,6), c(7,8), c(9,10), c(11,12)) 
for (year in years){
  no_cores <- detectCores() - 1 # Calculate the number of cores
  print(no_cores)
  cl <- makeCluster(no_cores, type="FORK") # Initiate cluster
  parLapply(cl, months, process_pet, year)
  stopCluster(cl)
}

# # then average over all years for each monthgroup (only for ECOSTRESS due to lack of data)
# years <- 2019:2021
# months <- c("1+2", "3+4", "5+6", "7+8", "9+10", "11+12")
# for (month in months){
#   # get all tifs for that monthgroup
#   tifs <- here(PET_study_area_path, paste0(month, "-", years, ".tif"))
#   
#   # take the mean across monthgroup
#   raster <- mean(brick(lapply(tifs, raster)))
#   
#   # save
#   writeRaster(raster, here(PET_study_area_path, paste0(month, "-all.tif")), "GTiff", overwrite=TRUE)
# }


