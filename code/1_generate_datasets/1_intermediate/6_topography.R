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

###############################################################################
###############################################################################
# calculate the topographic wetness index
dem <- raster(dem_loc)

# get the area that is in the 3 hydrological regions plus a little outside that is still in our study area
hydro <- st_read("/Users/annaboser/Documents/GitHub/ET_ag_disALEXI/data/1_raw/Hydrologic_Regions/Hydrologic_Regions.shp") %>% 
  st_transform(st_crs(dem)) %>% filter(HR_NAME %in% c("San Joaquin River", "Tulare Lake", "Sacramento River"))
study_area <- st_read(study_area_loc) %>% st_transform(st_crs(dem))
inc <- st_as_sf(st_union(study_area, hydro))
dem <- mask(dem, inc) %>% crop(inc)

# save the elevation over this area
writeRaster(dem, dem_clip_loc, "GTiff", overwrite=TRUE)

# also calculate the slope in radians for the original resolution over these hydrological regions
slope <- raster::terrain(dem, opt = "slope")
writeRaster(slope, slope_clip_loc, "GTiff", overwrite=TRUE)

###############################################################################
# from here, go to QGIS and calculate the TWI using the slope and dem rasters. 
# see https://www.youtube.com/watch?v=aHCLCUwg3O0 for more info
###############################################################################

# my grid and study area
CA_grid <- raster(CA_grid_loc)
study_area <- st_read(study_area_loc) %>% st_transform(st_crs(CA_grid))

# read in TWI, resample, and clip
twi <- raster(twi_raw_loc) %>% projectRaster(CA_grid) %>% resample(CA_grid, method = "bilinear")
writeRaster(twi, twi_resampled_loc, overwrite = TRUE)

twi <- mask(twi, study_area) %>% crop(study_area) # clip
writeRaster(twi, twi_loc, overwrite = TRUE)

