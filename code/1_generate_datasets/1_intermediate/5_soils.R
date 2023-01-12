# This script uses the CA storie index data obtained from 
# Campbell, Steve - FPAC-NRCS, Portland, OR <steve.campbell@usda.gov>
# and processes it to get a consistent 70m storie index raster over CA

# Anna Boser October 22 2021

library(here)
library(raster)
library(sf)
library(dplyr)

source("file_paths.R")

# my grid and map of california
CA_grid <- raster(CA_grid_loc)
CA <- st_read(CA_shp_loc) %>% st_transform(st_crs(CA_grid))
study_area <- st_read(study_area_loc) %>% st_transform(st_crs(CA_grid))

# the grid that the values in the CSV correspond to
gNATSGO_grid <- raster(gNATSGO_grid_loc)
gNATSGO_grid_crop <- crop(gNATSGO_grid,  st_transform(CA, st_crs(gNATSGO_grid)))

# the storie index
storie <- read.csv(storie_index_loc)

# soil data are organized in a strange way where there are unique map units
# that are associated with a location (and thus can be mapped using the gNATSGO grid).
# However, there are often multiple components within one map unit but their location
# is unknown. Therefore, to get an average value of soil quality for each map key, 
# I need to average the storie index accross components, weighting each one by prevalence. 

storie <- storie %>% 
  group_by(mukey) %>%
  summarise(storie = stats::weighted.mean(Storie_Index_rev, comppct_r, na.rm = TRUE))

# create a storie index raster by joining through the mukey
gNATSGO_storie <- raster::subs(gNATSGO_grid_crop, storie, by = "mukey")

#save 
writeRaster(gNATSGO_storie, gridded_storie_loc, overwrite = TRUE)
gNATSGO_storie <- raster(gNATSGO_storie_loc)

###############################################################################
# at this point move to python for the resmapling -- see 5.5_soils.py
###############################################################################

###############################################################################
# clip to study area
storie <- raster(CA_storie_resampled_loc)
storie <- mask(storie, study_area) %>% crop(study_area)
writeRaster(storie, storie_loc, "GTiff", overwrite=TRUE)
