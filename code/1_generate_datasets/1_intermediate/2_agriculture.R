# This script creates a shapefile and raster of agriculture based on DWR data

# Anna Boser November 5, 2022

library(sf)
library(raster)
library(here)
library(stringr)
library(dplyr)
library(fasterize)

source("file_paths.R")

# DWR
DWR <- read_sf(raw_dwr_loc) 
DWR <- st_zm(DWR) # DWR in 3 dims with 0 for z value

DWR$CLASS2 %>% unique()

# see the Crop_Mapping_2018_metadata to see what the CLASS2 codes mean: 
# c("P" = "Pasture", 
#   "G" = "Grain and hay crops", 
#   "V" = "Vineyards", 
#   "U" = "Urban - residential, commercial, and industrial, unsegregated", 
#   "X" = "Unclassified fallow", 
#   "T" = "Truck, nursery, and berry crops",
#   "C" = "Citrus and subtropical", 
#   "D" = "Deciduous fruits and nuts",
#   "YP" = "Young Perennial", 
#   "F" = "Field crops", 
#   "R" = "Rice", 
#   "I"= "Idle")

s <- nrow(DWR)
# remove anything that's urban
DWR <- filter(DWR, CLASS2 != "U")
print(s - nrow(DWR)) #number of polygons that were urban

# Ag polygon: will use the same for all years
DWR <- st_make_valid(DWR)
DWR_flat <- st_as_sf(st_union(DWR))
# rm(DWR)

# save ag polygon
st_write(DWR_flat, flat_ag_shp_loc)
# DWR_flat <- st_read(flat_ag_shp_loc)

# make a raster with 0 and 1 for where agriculture is present 
CA_grid <- raster(CA_grid_loc)

DWR_flat <- DWR_flat %>% st_transform(st_crs(CA_grid))

DWR_raster <- fasterize(DWR_flat, CA_grid) # all pixels even partially covered by ag should be marked

# save raster
writeRaster(DWR_raster, CA_ag_rast_loc, "GTiff", overwrite=TRUE)

# trim to study area
study_area <- st_read(study_area_loc) %>% st_transform(st_crs(grid))
DWR_raster <- mask(DWR_raster, study_area) %>% crop(study_area)

writeRaster(DWR_raster, ag_rast_loc, "GTiff", overwrite=TRUE)
