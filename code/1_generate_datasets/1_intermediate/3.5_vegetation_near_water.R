# This makes a mask for any vegetation within 500m of water according to FVEG. 
# It then makes a dataframe with the pixels that are within 500m of water. 
# Anna Boser 2/6/2023

library(sf)
library(raster)
library(here)
library(stringr)
library(dplyr)
library(fasterize)

source("file_paths.R")

# consistent grid
CA_grid <- raster(CA_grid_loc)

fveg <- raster(raw_fveg_loc)

# clip to study area
study_area <- st_read(study_area_loc) %>% st_transform(st_crs(fveg)) # study area 
fveg <- mask(fveg, study_area) %>% crop(study_area)

# key = c(1 = "CONIFER", 
#         2 = "SHRUB", 
#         3 = "HERBACEOUS", 
#         4 = "BARREN/OTHER", 
#         5 = "URBAN", 
#         6 = "HARDWOOD", 
#         7 = "WATER", 
#         8 = "AGRICULTURE")

# keep 7
values(fveg) <- ifelse(values(fveg) == 7, 1, 0)

# make into a shapefile

contour <- rasterToContour(fveg) %>% st_as_sf()
contour <- filter(contour, level == 1)
contour <- st_polygonize(contour)

# add a buffer around water
fveg_buff <- st_buffer(contour, 500) # 500m

# resmaple to grid
fveg_buff <- fveg_buff %>% st_transform(st_crs(CA_grid))
water_buff <- fasterize(fveg_buff, CA_grid)

# make into data table
df <- water_buff %>% as.data.frame(xy=TRUE) %>% filter(!(is.na(layer)))
write.csv(df, water_buffer_loc)
