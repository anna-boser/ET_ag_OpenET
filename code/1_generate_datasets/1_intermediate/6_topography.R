# This script uses the DEM elevations data to create rasters for elevation, aspect and slope

# Anna Boser Nov 7 2022

library(here)
library(raster)
library(dplyr)
library(sf)

source("file_paths.R")

# my grid and study area
CA_grid <- raster(CA_grid_loc)
study_area <- st_read(study_area_loc) %>% st_transform(st_crs(CA_grid))

# elevation from dem
elevation <- raster(dem_loc) %>% projectRaster(CA_grid) %>% resample(CA_grid, method = "bilinear")
print(elevation)

writeRaster(elevation, ca_elevation_loc, overwrite = TRUE)
# elevation <- raster(ca_elevation_loc)

elevation <- mask(elevation, study_area) %>% crop(study_area) # clip
writeRaster(elevation, elevation_loc, "GTiff", overwrite=TRUE)

# make slope and aspect layers
slope <- raster::terrain(elevation, opt = "slope")
writeRaster(slope, ca_slope_loc, overwrite = TRUE)
# slope <- raster(ca_slope_loc)
slope <- mask(slope, study_area) %>% crop(study_area) # clip
writeRaster(slope, slope_loc, "GTiff", overwrite=TRUE)

aspect <- raster::terrain(elevation, opt = "aspect")
writeRaster(aspect, ca_aspect_loc, overwrite = TRUE)
# aspect <- raster(ca_aspect_loc)
aspect <- mask(aspect, study_area) %>% crop(study_area) # clip
writeRaster(aspect, aspect_loc, "GTiff", overwrite=TRUE)

# calculate the topographic wetness index