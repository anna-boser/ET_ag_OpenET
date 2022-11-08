# This script takes the counties shapefile and the central valley raster
# and outputs a data table with the county for each pixel

# Anna Boser, Mar 4, 2021

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
polygons <- st_read(counties_loc)
polygons <- dplyr::filter(polygons, STATEFP == "06")

# Match raster and polygon crs 
polygons_reproj <- polygons %>% 
  st_transform(st_crs(grid))

geoweights <- rbindlist(exactextractr::exact_extract(grid, polygons_reproj, progress = T, include_cell = T, include_cols = c("NAME"), include_xy = T))

# only keep pixels that are 50% or more a certain county 
county_pixels <- geoweights[coverage_fraction>=.5]

# check that this removed duplicate pixels
length(unique(county_pixels$cell)) == length(county_pixels$cell)

# remove NA value column
county_pixels$value = NULL

## Save outputs 
## -----------------------------------------------

# Save geoweights 
fwrite(county_pixels, file = file.path(county_table_loc))

  