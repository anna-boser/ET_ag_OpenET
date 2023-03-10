# Add crop and county data to the ag predictions

# Anna Boser Nov 15, 2021

library(here)
library(raster)
library(dplyr)
library(sf)
library(data.table)

source("file_paths.R")

data <- fread(here(ag_data_loc))
data$x <- round(data$x, 7)
data$y <- round(data$y, 7)

# add_crops
crops <- fread(crops_table_loc)
crops$cell <- NULL
crops$x <- round(crops$x, 7)
crops$y <- round(crops$y, 7)

data <- merge(data, crops, by = c("x", "y"), all.x=TRUE)

# add counties
counties <- fread(county_table_loc)
counties$cell <- NULL
counties$x <- round(counties$x, 7)
counties$y <- round(counties$y, 7)
data <- merge(data, couties, by = c("x", "y"), all.x=TRUE)

