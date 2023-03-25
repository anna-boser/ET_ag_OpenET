# This script takes the gsa shapefile and the central valley raster
# and outputs a data table with the gsa for each pixel

# Anna Boser, Mar 19, 2023

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
polygons <- st_read(gsa_loc)

# Match raster and polygon crs 
polygons_reproj <- polygons %>% 
  st_transform(st_crs(grid))

geoweights <- rbindlist(exactextractr::exact_extract(grid, polygons_reproj, progress = T, include_cell = T, include_cols = c("GSA_Name"), include_xy = T))

# only keep pixels that are 50% or more a certain gsa 
gsa_pixels <- geoweights[coverage_fraction>.5]

# check that this removed duplicate pixels
length(unique(gsa_pixels$cell)) == length(gsa_pixels$cell)

# remove NA value column
gsa_pixels$value = NULL

## Save outputs 
## -----------------------------------------------

# Save geoweights 
fwrite(gsa_pixels, file = file.path(gsa_table_loc))

