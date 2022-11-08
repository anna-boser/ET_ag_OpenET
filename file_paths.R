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

# ECOSTRESS DisALEXI ET 2019-2021
# https://appeears.earthdatacloud.nasa.gov/
raw_ecostress_path <- here("data", "1_raw", "ECOSTRESS")

# study area
# generated in ET_agriculture repository. Basically just a 10km buffer around ag lands in the central valley. 
study_area_loc <- here("data", "1_raw", "study_area", "study_area.shp")

# consistent grid -- all of CA
# generated in ET_agriculture repository. Basically just one of the grids from the ET data extended to the enturety of California using extend(grid, CA). 
CA_grid_loc <- here("data", "1_raw", "study_area", "CA_grid.tif")

# consistent grid -- study area
# generated in 1_generate_datasets/1_intermediate/ECOSTRESS.R
grid_loc <- here("data", "1_raw", "study_area", "grid.tif")

# monthly bricks of resampled ECOSTRESS data
# generated in 1_generate_datasets/1_intermediate/ECOSTRESS.R
ECOSTRESS_bricks_path <- here("data", "2_intermediate", "ECOSTRESS", "bricks")

# tifs of temporally aggregated ECOSTRESS data
# generated in 1_generate_datasets/1_intermediate/ECOSTRESS.R
intermediate_ecostress_path <- here("data", "2_intermediate", "ECOSTRESS", "means")

# raw landiq/dwr agriculture data
# from https://data.cnra.ca.gov/dataset/6c3d65e3-35bb-49e1-a51e-49d5a2cf09a9/resource/1da7b37a-dd97-4b69-a86a-fe824a252eaf/download/i15_crop_mapping_2019.zip
raw_dwr_loc <- here("data", "1_raw", "DWR", "i15_Crop_Mapping_2019.shp")

# flat ag shapefile where agriculture is in CA
# created in 1_generate_datasets/1_intermediate/agriculture.R
flat_ag_shp_loc <- here("data", "2_intermediate", "agriculture", "flag_ag", "flat_ag.shp")

# raster of where agriculture is in CA
# created in 1_generate_datasets/1_intermediate/agriculture.R
CA_ag_rast_loc <- here("data", "2_intermediate", "agriculture", "CA_ag.tif")

# raster of where agriculture is in the study area
# created in 1_generate_datasets/1_intermediate/agriculture.R
ag_rast_loc <- here("data", "2_intermediate", "agriculture", "ag.tif")

# a shapefile of California
CA_shp_loc <- here("data", "1_raw", "study_area", "california", "california.shp")

#Cropland data layer (CDL)
CDL2019_loc <- here("data", "1_raw", "CDL", "CDL2019", "2019_30m_cdls.img")
CDL2020_loc <- here("data", "1_raw", "CDL", "CDL2020", "2020_30m_cdls.img")
CDL2021_loc <- here("data", "1_raw", "CDL", "CDL2021", "2021_30m_cdls.img")

# CDL code dictionary
cdl_code_dict_loc <- here("data", "1_raw", "CDL", "CDL_code_dictionary.csv")

# processed cdl stuff -- only vegetation that is barren, shrub, or grassland
# created in 1_generate_datasets/1_intermediate/vegetation.R
ca_cdl_ag_not_removed_loc <- here("data", "2_intermediate", "vegetation", "ca_cdl_ag_not_removed.tif")
ca_cdl_loc <- here("data", "2_intermediate", "vegetation", "ca_cdl.tif")
cdl_loc <- here("data", "2_intermediate", "vegetation", "cdl.tif") # study area only

# California protected areas database (CPAD)
cpad_holdings_loc <- here("data/1_raw/CPAD/CPAD_2022a/CPAD_2022a_Holdings.shp")

# CPAD for protected categories 1, 2, and 3
# created in 1_generate_datasets/1_intermediate/vegetation.R
ca_cpad_shp_loc <- here("data", "2_intermediate", "vegetation", "CPAD123_shapefile", "CPAD123.shp")
ca_cpad_loc <- here("data", "2_intermediate", "vegetation", "ca_CPAD123.tif")
cpad_loc <- here("data", "2_intermediate", "vegetation", "CPAD123.tif")

# fveg 2014 tif that Nakoa made for me in ArcGIS
raw_fveg_loc <- here("data", "1_raw", "FVEG", "fveg_lifeform.tif")

# fveg tifs where fveg is only barren, shrub, or herbaceous
# created in 1_generate_datasets/1_intermediate/vegetation.R
ca_fveg_loc <- here("data", "2_intermediate", "vegetation", "ca_fveg.tif")
fveg_loc <- here("data", "2_intermediate", "vegetation", "fveg.tif")

# Raw PET data
# https://data.bris.ac.uk/data/dataset/qb8ujazzda0s2aykkv0oq0ctp
raw_PET_path <- here("data", "1_raw", "PET")

# Intermediate PET data
# created in 1_generate_datasets/1_intermediate/PET.R
PET_means_path <- here("data", "2_intermediate", "PET", "means")
PET_resampled_path <- here("data", "2_intermediate", "PET", "resampled")
PET_study_area_path <- here("data", "2_intermediate", "PET", "study_area")


