# This script contains all of the dataset locations and a brief decription of each
# This script can be sourced in order to not put absolute paths in any other script. 

# Format: 
# Dataset description
# Location retrieved or script used to create
# Name it is stored as <- location

# Anna Boser 2022

library(here)

# function to retrieve the path of the directory the file resides in
directory_path <- function(filepath){
  return(sub('[/][^/]+$', '', filepath))
}

# OpenET 2016-2021
# From google earth engine; see https://developers.google.com/earth-engine/datasets/catalog/OpenET_ENSEMBLE_CONUS_GRIDMET_MONTHLY_v2_0 for data; see https://code.earthengine.google.com/cb078c9f8933fb4814619c7982b8e615 for download script
raw_openet_path <- here("data", "1_raw", "OpenET")

# study area
# This is a 10km buffer around agricultural lands in the Central Valley. It is available in the data folder. 
study_area_loc <- here("data", "1_raw", "study_area", "study_area.shp")

# consistent grid -- study area
# This is a 70m grid generated in 1_generate_datasets/1_intermediate/OpenET.R. It is available in the data folder. 
grid_loc <- here("data", "1_raw", "study_area", "grid.tif")

# tifs of monthly OpenET data
# generated in 1_generate_datasets/1_intermediate/OpenET.R
intermediate_openet_path <- here("data", "2_intermediate", "OpenET")

# raw landiq/dwr agriculture data
# from https://data.cnra.ca.gov/dataset/6c3d65e3-35bb-49e1-a51e-49d5a2cf09a9/resource/1da7b37a-dd97-4b69-a86a-fe824a252eaf/download/i15_crop_mapping_2019.zip. All years available at: https://data.cnra.ca.gov/dataset/statewide-crop-mapping
raw_dwr_path <- here("data", "1_raw", "DWR")

# flat ag shapefile where agriculture is in CA
# created in 1_generate_datasets/1_intermediate/agriculture.R
flat_ag_shp_loc <- here("data", "2_intermediate", "agriculture", "flag_ag", "flat_ag.shp")

# raster of where agriculture is in CA
# created in 1_generate_datasets/1_intermediate/agriculture.R
CA_ag_rast_loc <- here("data", "2_intermediate", "agriculture", "CA_ag.tif")

# raster of where agriculture is in the study area
# created in 1_generate_datasets/1_intermediate/agriculture.R
ag_rast_loc <- here("data", "2_intermediate", "agriculture", "ag.tif")

# a shapefile of California. 
# Available in the data folder. 
CA_shp_loc <- here("data", "1_raw", "study_area", "california", "california.shp")

# Cropland data layer (CDL)
# Can be downloaded at https://www.nass.usda.gov/Research_and_Science/Cropland/Release/index.php
CDL_path <- here("data", "1_raw", "CDL")
CDL2019_loc <- here("data", "1_raw", "CDL", "CDL2019", "2019_30m_cdls.img")
CDL2020_loc <- here("data", "1_raw", "CDL", "CDL2020", "2020_30m_cdls.img")
CDL2021_loc <- here("data", "1_raw", "CDL", "CDL2021", "2021_30m_cdls.img")

# CDL code dictionary
# Created using CDL metadata and available in the data folder.
cdl_code_dict_loc <- here("data", "1_raw", "CDL", "CDL_code_dictionary.csv")

# Raw PET data
# Download at https://data.bris.ac.uk/data/dataset/qb8ujazzda0s2aykkv0oq0ctp
raw_PET_path <- here("data", "1_raw", "PET")

# Intermediate PET data
# created in 1_generate_datasets/1_intermediate/PET.R
PET_means_path <- here("data", "2_intermediate", "PET", "1_means")
PET_resampled_path <- here("data", "2_intermediate", "PET", "2_resampled")
PET_study_area_path <- here("data", "2_intermediate", "PET", "3_study_area_means")

# soils -- California storie index raw data
# from gSSURGO and STATSGO2 resampled to the grid of gNATSGO. 
# Obtained through personal correspondence with the CA State Soil Scientist 
# Campbell, Steve - FPAC-NRCS, Portland, OR <steve.campbell@usda.gov>
gNATSGO_grid_loc <- here("data", "1_raw", "CA_storie", "CA_gNATSGO_MuRaster_tif", "MapunitRaster_10m.tif")
storie_index_loc <- here("data", "1_raw", "CA_storie", "CA_all_NASIS_Storie_Index_SSURGO_STATSGO2.csv") # available in the data folder

# intermediate soil data
# created in 1_generate_datasets/1_intermediate/5_soils.R 5.5_soils.py
gNATSGO_storie_loc <- here("data", "2_intermediate", "CA_storie", "gNATSGO_storie.tif")
CA_storie_resampled_loc <- here("data", "2_intermediate", "CA_storie", "CA_storie_index.tif")
storie_loc <- here("data", "2_intermediate", "CA_storie", "storie_index.tif") # available in data folder

# DEM: 90m resolution western US elevation data
# from https://www.sciencebase.gov/catalog/item/542aebf9e4b057766eed286a
dem_loc <- here("data", "1_raw", "DEM", "dem90_hf.tif")

# processed topography data: elevation, aspect, slope, and topographic 
# created in 1_generate_datasets/1_intermediate/6_topography.R
ca_elevation_loc <- here("data", "2_intermediate", "topography", "ca_elevation.tif")
ca_slope_loc <- here("data", "2_intermediate", "topography", "ca_slope.tif")
ca_aspect_loc <- here("data", "2_intermediate", "topography", "ca_aspect.tif")
elevation_loc <- here("data", "2_intermediate", "topography", "elevation.tif")
slope_loc <- here("data", "2_intermediate", "topography", "slope.tif")
aspect_loc <- here("data", "2_intermediate", "topography", "aspect.tif")

# slope in radians and dem to feed into QGIS to get the TWI
# created in 1_generate_datasets/1_intermediate/7_topographic_wetness_index.R
dem_clip_loc <- here("data", "2_intermediate", "twi", "dem_hydrologic_regions.tif")
slope_clip_loc <- here("data", "2_intermediate", "twi", "slope_hydrologic_regions.tif")

# Topographic Wetness Index (TWI) calculated in QGIS 
# following tutorial https://www.youtube.com/watch?v=aHCLCUwg3O0 
# using files created in 1_generate_datasets/1_intermediate/7_topographic_wetness_index.R
upslope_area_loc <- here("data", "2_intermediate", "twi", "upslope_area_hydrologic_regions.tif")

# TWI resampled and clipped to study area 
# created in 1_generate_datasets/1_intermediate/7_topographic_wetness_index.R
twi_resampled_loc <- here("data", "2_intermediate", "twi", "twi_hydrologic_regions_resmapled.tif")
twi_loc <- here("data", "2_intermediate", "twi", "twi.tif")

# county shapefile
# from https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_county_500k.zip
counties_loc <- here("data", "1_raw", "counties", "cb_2018_us_county_500k.shp")

# a table with the location of a pixel and the county it belongs in
# created in 1_generate_datasets/1_intermediate/additional_data/1_counties.R
county_table_loc <- here("data", "4_for_analysis", "additional_data", "counties.csv")

# subbasin shapefile
# available at https://geodata.lib.utexas.edu/catalog/stanford-kt110sd4399 and in the data folder.
basin_loc <- here("data", "1_raw", "subbasins", "basin.shp")

# a table with the location of a pixel and the basin it belongs in
# created in 1_generate_datasets/1_intermediate/additional_data/5_basin.R
basin_table_loc <- here("data", "4_for_analysis", "additional_data", "basin.csv")

# A table with the location of a pixel and its crop type, sub crop type, and if multiple crops are grown on that pixel.
# Pure pixels only. 
# created in 1_generate_datasets/1_intermediate/additional_data/2_crops.R
crops_dwr_table_path <- here("data", "4_for_analysis", "additional_data") # for the seperate years
crops_dwr_table_loc <- here("data", "4_for_analysis", "additional_data", "crops_all_dwr_fallow.csv")

# A table of fallow fields according to CDL
# created in 1_generate_datasets/1_intermediate/additional_data/2.5_crops.R
fallow_CDL_table_path <- here("data", "4_for_analysis", "additional_data") # for the seperate years
fallow_CDL_table_loc <- here("data", "4_for_analysis", "additional_data", "fallow_CDL.csv")

# datasets processed for training of the ML model (has CDL, CPAD, and FVEG natural pixels)
# created in 1_generate_datasets/3_data_aggregation/datasets_for_ml.R
natural_data_path <- here("data", "3_for_counterfactual", "training_data")

# datasets processed for getting ML model predictions (has DWR agricultural pixels)
# created in 1_generate_datasets/3_data_aggregation/datasets_for_ml.R
ag_data_loc <- here("data", "3_for_counterfactual", "agriculture", "agriculture.csv")

# same as ag_data_loc but only the fallow fields
# created in 1_generate_datasets/3_data_aggregation/3_add_crop_county_data.R
fallow_data_loc <- here("data", "3_for_counterfactual", "agriculture", "fallow.csv")

# same as fallow_data_loc but only the fallow fields that were also fallow in the cdl
# created in 1_generate_datasets/3_data_aggregation/3_add_crop_county_data.R
fallow_cdl_data_loc <- here("data", "3_for_counterfactual", "agriculture", "fallow_cdl.csv")

# path to the distributions of distances between 500 random ag pixels to natural land for the different natural test sets
# created in 3_analysis/1_additional_data_manipulation/2_ag_natural_distance.R
distance_distribution_path <- here("data", "4_for_analysis", "distances")

# USGS irrigation data
# 2015: https://waterdata.usgs.gov/ca/nwis/water_use?wu_year=2015&wu_area=County&wu_county=ALL&wu_category=IC&submitted_form=introduction&wu_county_nms=--ALL+Counties--&wu_category_nms=Irrigation%2C+Crop
# 2010: https://waterdata.usgs.gov/ca/nwis/water_use?wu_year=2010&wu_area=County&wu_county=ALL&wu_category=IC&submitted_form=introduction&wu_county_nms=--ALL+Counties--&wu_category_nms=Irrigation%2C+Crop
usgs_irr_path <- here("data", "1_raw", "USGS_waterdata")

# CalSIMETAW water use comparisons
# https://data.ca.gov/dataset/cal-simetaw-unit-values
calsimetaw_loc <- here("data", "1_raw", "CalSIMETAW", "calsimetaw.csv")

# fallow train, validation, and test locations
# splits created in 5_clean_and_split_fallow.R
training_data_path <- here("data", "3_for_counterfactual", "training_data", "train")
val_data_path <- here("data", "3_for_counterfactual", "agriculture")
test_data_path <- here("data", "3_for_counterfactual", "agriculture")

# the agriculture dataset but only 2016, 2018, and 2019
# created in 5_clean_and_split_fallow.R
ag_dwr_years_loc <- here("data", "3_for_counterfactual", "agriculture", "agriculture_dwr_years.csv")
