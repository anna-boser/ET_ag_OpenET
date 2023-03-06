# This makes a dataframe with the pixels that are wetlands using the wetlands shapefile. 
# Anna Boser 2/6/2023

library(sf)
library(raster)
library(here)
library(stringr)
library(dplyr)
library(fasterize)
library(dplyr)

source("file_paths.R")

# consistent grid
grid <- raster(grid_loc)

# read in wetlands shapefile
wl <- st_read(raw_wetlands_loc)

# resmaple to grid
wl <- wl %>% st_transform(st_crs(grid))
wl_rast <- fasterize(wl, grid)

# make into data table
df <- wl_rast %>% as.data.frame(xy=TRUE) %>% filter(!(is.na(layer)))
dir.create(directory_path(wetlands_loc))
write.csv(df, wetlands_loc, append = FALSE)
