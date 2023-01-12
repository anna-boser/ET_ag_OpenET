###############################################################################
###############################################################################
# calculate the topographic wetness index

# Anna Boser Nov 7 2022

library(here)
library(raster)
library(dplyr)
library(sf)

source("file_paths.R")

# my grid and study area
CA_grid <- raster(CA_grid_loc)
study_area <- st_read(study_area_loc) %>% st_transform(st_crs(CA_grid))

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
# from here, go to QGIS and calculate the upslope area using the slope and dem rasters. 
# see https://www.youtube.com/watch?v=aHCLCUwg3O0 for more info

# because this takes a very long time, I resampled the DEM to 1km before doing it. 
###############################################################################

# my grid and study area
CA_grid <- raster(CA_grid_loc)
study_area <- st_read(study_area_loc) %>% st_transform(st_crs(CA_grid))

# read in the ingredients to calculating TWI and reproject them to the grid
upslope_area <- raster(upslope_area_loc) %>% projectRaster(CA_grid) %>% resample(CA_grid, method = "bilinear")
slope <- raster(slope_clip_loc) %>% projectRaster(CA_grid) %>% resample(CA_grid, method = "bilinear")

# calculate TWI
twi = log((upslope_area + 1 *1000) / tan(slope+.0000001)) # times 1000 because the size of the pixels for the upslope area was 1000m. Also add a small decimal to the slope since some are 0. 
writeRaster(twi, twi_resampled_loc, overwrite = TRUE)

twi <- mask(twi, study_area) %>% crop(study_area) # clip
writeRaster(twi, twi_loc, overwrite = TRUE)
