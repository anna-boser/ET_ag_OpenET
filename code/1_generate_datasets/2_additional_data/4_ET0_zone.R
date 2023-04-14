# This script takes the  shapefile and the ET0 zones defined by CIMIS
# and outputs a data table with the ET0 zone for each pixel

# Anna Boser, Mar 25, 2023

library(raster)
library(data.table)
library(dplyr)
library(exactextractr)
library(tidyverse)
library(sf)
library(here)
library(sf)
library(Rcpp)

source("file_paths.R")

# Create raster
grid <- raster(grid_loc)

# polygon: counties
polygons <- st_read(et0_zone_loc)

# Match raster and polygon crs 
polygons_reproj <- polygons %>% 
  st_transform(st_crs(grid))

geoweights <- rbindlist(exactextractr::exact_extract(grid, polygons_reproj, progress = T, include_cell = T, include_cols = c("ZONE"), include_xy = T))

# only keep pixels that are 50% or more a certain gsa 
pixels <- geoweights[coverage_fraction>.5]

# check that this removed duplicate pixels
length(unique(pixels$cell)) == length(pixels$cell)

# remove NA value column
pixels$value = NULL

## Save outputs 
## -----------------------------------------------

# Save geoweights 
fwrite(pixels, file = file.path(et0_zone_table_loc))

