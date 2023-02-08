# This script generates a dataframe identifiying pixels fully covered by a single crop according to DWR 2019

# Anna Boser, Nov 8, 2022

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

years = c(2016, 2018, 2019) # years of available DWR data

# full name of the crop type
cropnames <- c("P" = "Pasture",
               "G" = "Grain and hay crops",
               "V" = "Vineyards",
               "U" = "Urban - residential, commercial, and industrial, unsegregated",
               "X" = "Unclassified fallow",
               "T" = "Truck, nursery, and berry crops",
               "C" = "Citrus and subtropical",
               "D" = "Deciduous fruits and nuts",
               "YP" = "Young Perennial",
               "F" = "Field crops",
               "R" = "Rice",
               "I"= "Idle")

subcropnames <- c("D6"="Pears", 
                  "D13"="Walnuts", 
                  "P3"="Mixed pasture", # drop
                  "P6"="Miscellaneous grasses", # drop
                  "G6"="Miscellaneous grain and hay", # drop
                  "D10"="Miscellaneous deciduous", # drop
                  "C6"="Olives", 
                  "T18"="Miscellaneous truck", # drop
                  "D12"="Almonds", 
                  "R2"="Wild Rice", 
                  "T16"="Flowers, nursery & Christmas tree farms", # drop
                  "T19"="Bush berries", 
                  "F16"="Corn,Sorghum or Sudan", 
                  "F11"="Miscellaneous field", # drop
                  "C8"="Kiwis", 
                  "T9"="Melons", 
                  "D8"="Prunes", 
                  "F2"="Safflower", 
                  "T15"="Tomatoes (processing)", 
                  "F12"="Sunflowers", 
                  "F10"="Beans (dry)", 
                  "G2"="Wheat", 
                  "F1"="Cotton", 
                  "C10"="Eucalyptus", 
                  "D5"="Peaches and nectarines", 
                  "R1"="Rice", 
                  "D14"="Pistachios", 
                  "D15"="Pomegranates", 
                  "P1"="Alfalfa & alfalfa mixtures", 
                  "D3"="Cherries", 
                  "T10"="Onions & garlic", 
                  "D1"="Apples", 
                  "T4"="Cole crops", 
                  "T20"="Strawberries", 
                  "C7"="Miscellaneous subtropical fruit", 
                  "T27"="Greenhouse", # should be tossed
                  "T21"="Peppers", 
                  "P4"="Native pasture", 
                  "C3"="Oranges", 
                  "T12"="Potatoes", 
                  "T30"="Lettuce or Leafy Greens", 
                  "D16"="Plums, Prunes or Apricots", 
                  "T6"="Carrots", 
                  "T17"="Mixed (four or more)", 
                  "C4"="Dates", 
                  "T31"="Potato or Sweet potato", 
                  "P7"="Turf farms", 
                  "C5"="Avocados", 
                  "C2"="Lemons")

get_croptypes <- function(year){
  DWR <- read_sf(here(raw_dwr_path, paste0("i15_Crop_Mapping_", year,".shp")))
  
  DWR <- st_zm(DWR) # DWR has in 3 dimentsions with 0 for z value
  polygons <- st_make_valid(DWR)
  
  DWR <- filter(DWR, CLASS2 != "U") # remove urban land
  
  # Match raster and polygon crs 
  polygons_reproj <- polygons %>% 
    st_transform(st_crs(grid))
  
  # large general class
  geoweights <- rbindlist(exactextractr::exact_extract(grid, polygons_reproj, progress = T, include_cell = T, include_cols = c("CLASS2", "MULTIUSE"), include_xy = T))
  
  # crop subclasses
  subpolygons_reproj <- polygons_reproj %>% filter(SUBCLASS2 != "**")
  subgeoweights <- rbindlist(exactextractr::exact_extract(grid, subpolygons_reproj, progress = T, include_cell = T, include_cols = c("CLASS2", "SUBCLASS2"), include_xy = T))
  subgeoweights$subclass <- paste0(subgeoweights$CLASS2, subgeoweights$SUBCLASS2)
  
  # only keep pixels that are 100% a certain crop
  crop_pixels <- geoweights[coverage_fraction==1]
  crop_pixels$coverage_fraction <- NULL
  
  subcrop_pixels <- subgeoweights[coverage_fraction==1]
  subcrop_pixels$coverage_fraction <- NULL
  
  # check that this removed duplicate pixels
  length(unique(crop_pixels$cell)) == length(crop_pixels$cell)
  length(unique(subcrop_pixels$cell)) == length(subcrop_pixels$cell)
  
  # remove NA value column
  crop_pixels$value = NULL
  subcrop_pixels$value = NULL
  
  # add in the full name of the crop type
  crop_pixels$cropnames <- cropnames[crop_pixels$CLASS2]
  subcrop_pixels$subcropnames <- subcropnames[subcrop_pixels$subclass]
  
  # integrate crop_pixels and subcrop_pixels
  subcrop_pixels$CLASS2=NULL
  cropdf <- merge(crop_pixels, subcrop_pixels, by = c("x", "y", "cell"), all=TRUE)
  
  ## Save outputs 
  ## -----------------------------------------------
  
  # Save 
  fwrite(cropdf, file = here(crops_dwr_table_path, paste0("crops_all_dwr_fallow", year, ".csv")), append = FALSE)
  cropdf$year <- year
  return(cropdf)
}

all_years <- rbindlist(lapply(years, get_croptypes))
fwrite(all_years, file = here(crops_dwr_table_path, paste0("crops_all_dwr_fallow.csv")), append = FALSE)