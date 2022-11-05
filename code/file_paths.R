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


