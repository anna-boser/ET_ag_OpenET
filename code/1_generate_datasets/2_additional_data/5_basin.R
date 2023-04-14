# This script takes the subbasins shapefile
# and outputs a data table with the basin for each pixel

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
polygons <- st_read(basin_loc)

# Match raster and polygon crs 
polygons_reproj <- polygons %>% 
  st_transform(st_crs(grid))

# filter to only keep CV basins
polygons_reproj <- polygons_reproj %>% filter(basin_name %in% c("SACRAMENTO VALLEY", "SAN JOAQUIN VALLEY"))

geoweights <- rbindlist(exactextractr::exact_extract(grid, polygons_reproj, progress = T, include_cell = T, include_cols = c("subbasin_n"), include_xy = T))

# only keep pixels that are 50% or more a certain gsa 
pixels <- geoweights[coverage_fraction>.5]

# check that this removed duplicate pixels
length(unique(pixels$cell)) == length(pixels$cell)

# remove NA value column
pixels$value = NULL
pixels$coverage_fraction = NULL

## Save outputs 
## -----------------------------------------------

# Save geoweights 
fwrite(pixels, file = file.path(basin_table_loc))

