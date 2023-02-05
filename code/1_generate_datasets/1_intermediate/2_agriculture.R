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
years = c(2016, 2018, 2019) # years of available DWR data

process_dwr <- function(year){
  read_sf(here(raw_dwr_path, paste0("i15_Crop_Mapping_", year,".shp")))
  
  DWR <- st_zm(DWR) # DWR in 3 dims with 0 for z value
  
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
  dir.create(flat_ag_shp_path, recursive = TRUE)
  st_write(DWR_flat, here(flat_ag_shp_path, paste0("flat_ag", year, ".shp")))
  
  return(DWR_flat)
}

dwr_shps = lapply(years, process_dwr)

# flatten all of the shapefiles
DWR_flat = st_union(dwr_shps)

# make a raster with 0 and 1 for where agriculture is present 
CA_grid <- raster(CA_grid_loc)

DWR_flat <- DWR_flat %>% st_transform(st_crs(CA_grid))

DWR_raster <- fasterize(DWR_flat, CA_grid) # all pixels even partially covered by ag should be marked

# save raster
dir.create(directory_path(CA_ag_rast_loc), recursive = TRUE)
writeRaster(DWR_raster, CA_ag_rast_loc, "GTiff", overwrite=TRUE)

if (study_area){
  # trim to study area
  study_area <- st_read(study_area_loc) %>% st_transform(st_crs(grid))
  DWR_raster <- mask(DWR_raster, study_area) %>% crop(study_area)
  
  dir.create(directory_path(ag_rast_loc), recursive = TRUE)
  writeRaster(DWR_raster, ag_rast_loc, "GTiff", overwrite=TRUE)
}
