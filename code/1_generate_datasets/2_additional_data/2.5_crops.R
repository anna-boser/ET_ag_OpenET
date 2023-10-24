###########################################
# cross-check the fallow fields with the CDL
# Fallow fields are cross-checked with CDL 2016, 2018, and 2019. 
###########################################

# Anna Boser, Nov 8, 2022

library(here)
library(raster)
library(dplyr)
library(sf)
library(data.table)

source("file_paths.R")

# function to get the CDL
readCDL <- function(year){
  file <- here(CDL_path, 
               paste0("CDL", year),
               paste0(year, "_30m_cdls."))
  if (year >= 2021){ # extension changes by year
    file <- paste0(file, "tif")
  } else {
    file <- paste0(file, "img")
  }
  print(file)
  return(raster(file))
}

years <- c(2019, 2020, 2021)
grid <- raster(grid_loc)

# write a function that modifies the yearly tables made in 2_crops.R 
# to only include fallow lands that are also fallow according to the CDL
# for the same year
CDL_crossref <- function(year){
  
  # get the DWR table for this year
  crop_pixels <- fread(here(crops_dwr_table_path, paste0("crops_all_dwr_fallow", year, ".csv")))
  
  # get the CDL for this year
  CDL <- readCDL(year)
  
  # crop CDL layer to the central valley
  study_area <- st_read(study_area_loc) %>% st_transform(st_crs(CDL))
  CDL <- crop(CDL, study_area)
  
  # get a bionary of fallow lands -- 61 is fallow (see metadata)
  values(CDL) <- ifelse(values(CDL) == 61, 1, 0)
  
  # resample to the CA_grid
  fallow_resampled <- CDL %>% projectRaster(grid) %>% raster::resample(grid, method = "bilinear")
  
  # keep if fallow lands are persistently in a pixel
  values(fallow_resampled) <- ifelse(values(fallow_resampled) == 1, 1, 0) 
  
  # turn raster of fallow lands into a dataframe
  fallow_CDL <- as.data.frame(fallow_resampled, xy = TRUE) %>% filter(layer == 1)
  
  # compare fallow lands in the crop_pixels to those of the CDL layer. 
  fallow_DWR <- filter(crop_pixels, CLASS2 %in% c("I", "X")) # idle or fallow OK
  both <- filter(fallow_DWR, paste(x, y) %in% paste(fallow_CDL$x, fallow_CDL$y))
  print(paste("Fraction of DWR fallow lands conserved:", nrow(both)/nrow(fallow_DWR)))
  
  # remove fallow lands in the crop_pixels that are not also in the CDL layer. 
  filtered_crop_pixels <- filter(crop_pixels, !(CLASS2 %in% c("X", "I") & !(paste(x, y) %in% paste(both$x, both$y))))
  
  ## Save outputs 
  ## -----------------------------------------------
  
  # Save 
  fwrite(cropdf, file = here(crops_table_path, paste0("crops", year, ".csv")), append = FALSE)
  cropdf$year <- year
  return(cropdf)
  
}

# run through all years and combine all into one table
all_years <- rbindlist(lapply(years, CDL_crossref))
fwrite(all_years, file = here(crops_table_loc), append = FALSE)