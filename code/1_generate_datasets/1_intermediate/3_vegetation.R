# This script creates shapefiles and tifs of 3 different vegetation datasets
# that I'm interested in exploring. 

# Anna Boser Nov 5, 2022

library(sf)
library(raster)
library(here)
library(stringr)
library(dplyr)

source("file_paths.R")

# consistent grid
CA_grid <- raster(CA_grid_loc)

# the DWR ag indicator raster
DWR <- raster(CA_ag_rast_loc)

# study area 
study_area <- st_read(study_area_loc) %>% st_transform(st_crs(CA_grid))

###############################################################################
# cropland data layer

# The CDL. I don't need to bother with different years because they don't change
# since the non ag land cover data is actually from the NLCD. 

CDL <- raster(CDL2020_loc)
CA <- st_read(CA_shp_loc) %>% st_transform(st_crs(CDL))
CDL <- crop(CDL, CA) %>% mask(CA)

code_dictionary <- read.csv(file = cdl_code_dict_loc)

# make a dictionary for converting CDL numbers to counterfactual and not
counterfactual_dic <- code_dictionary$counterfactual
names(counterfactual_dic) <- code_dictionary$code

# converting CDL numbers to counterfactual (1) and not (0)
CDL_counterfactual <- CDL
values(CDL_counterfactual) <- counterfactual_dic[as.character(values(CDL_counterfactual))]

# resample to the CA_grid
CDL_counterfactual <- CDL_counterfactual %>% projectRaster(CA_grid) %>% resample(CA_grid, method = "bilinear")

# get rid of non-pure counterfactual pixels
values(CDL_counterfactual) <- ifelse(values(CDL_counterfactual) == 1, 1, NA)

writeRaster(CDL_counterfactual, ca_cdl_ag_not_removed_loc, "GTiff", overwrite=TRUE)
CDL_counterfactual <- readRaster(ca_cdl_ag_not_removed_loc)

# get rid of ag pixels
values(CDL_counterfactual) <- ifelse(!is.na(values(DWR)), NA, values(CDL_counterfactual))

# save the raster 
writeRaster(CDL_counterfactual, ca_cdl_loc, "GTiff", overwrite=TRUE)
# CDL_counterfactual <- raster(ca_cdl_loc)

# trim to study area
CDL_counterfactual <- mask(CDL_counterfactual, study_area) %>% crop(study_area)

writeRaster(CDL_counterfactual, cdl_loc, "GTiff", overwrite=TRUE)

###############################################################################
# CPAD

# read in the shapefile of the holdings, or the smallest unit
CPAD <- st_read(here(cpad_holdings_loc))

# remove any holdings in GAP 4, since these are the areas that are not protected from changes. 
# see https://www.usgs.gov/core-science-systems/science-analytics-and-synthesis/gap/science/pad-us-data-overview?qt-science_center_objects=0#qt-science_center_objects for more info. 
CPAD123 <- filter(CPAD, (CPAD$GAP4_acres/CPAD$ACRES)<=0)
print(nrow(CPAD123)/nrow(CPAD))

# flatten the shapefile
CPAD123 <- st_as_sf(st_union(CPAD123))

# save cpad polygon
st_write(CPAD123, ca_cpad_shp_loc)

CPAD123 <- CPAD123 %>% st_transform(st_crs(CA_grid)) # change projection to the grid projection

# turn the shapefile into a binary mask
CPAD123_raster <- fasterize(CPAD123, CA_grid) # all pixels even partially covered are marked

# Remove ag pixels
values(CPAD123_raster) <- ifelse(!is.na(values(DWR)), NA, values(CPAD123_raster))

# save raster
writeRaster(CPAD123_raster, ca_cpad_loc, "GTiff", overwrite=TRUE)
# CPAD123_raster <- raster(ca_cpad_loc)

# trim to study area
CPAD123_raster <- mask(CPAD123_raster, study_area) %>% crop(study_area)

writeRaster(CPAD123_raster, cpad_loc, "GTiff", overwrite=TRUE)

###############################################################################
# FVEG

fveg <- raster(raw_fveg_loc)

# key = c(1 = "CONIFER", 
#         2 = "SHRUB", 
#         3 = "HERBACEOUS", 
#         4 = "BARREN/OTHER", 
#         5 = "URBAN", 
#         6 = "HARDWOOD", 
#         7 = "WATER", 
#         8 = "AGRICULTURE")

# I'm interested in 2, 3, and 4

values(fveg) <- ifelse(values(fveg) %in% c(2,3,4), 1, 0)

# resample to the 70m grid
fveg <- fveg %>% projectRaster(CA_grid) %>% resample(CA_grid, method = "bilinear")

# remove unpure pixels
values(fveg) <- ifelse(values(fveg) ==1, 1, NA)

# get rid of ag pixels
values(fveg) <- ifelse(!is.na(values(DWR)), NA, values(fveg))

# save it 
writeRaster(fveg, ca_fveg_loc, "GTiff", overwrite=TRUE)
# fveg <- raster(ca_fveg_loc)

# trim to study area
fveg <- mask(fveg, study_area) %>% crop(study_area)

writeRaster(fveg, fveg_loc, "GTiff", overwrite=TRUE)

