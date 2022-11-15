###########################################
# cross-check the fallow fields with the CDL
# Fallow fields are cross-checked with CDL 2018, 2019, and 2020. 
###########################################

# Anna Boser, Nov 8, 2022

crop_pixels <- fread(file = file.path(here("data", "intermediate", "crops", "crops_dwr2019.csv")))

# get CDL for years of interest
years <- c(2019, 2020, 2021)
readCDL <- function(year){
  file <- here("data",
               "raw",
               "CDL",
               paste0("CDL", year),
               paste0(year, "_30m_cdls."))
  if (year >= 2021){ # extension changes by year
    file <- paste0(file, "tif")
  } else {
    file <- paste0(file, "img")
  }
  return(raster(file))
}
CDLs = lapply(years, readCDL)

# crop CDL layers to the central valley
CV <- st_read(here("data/raw/shapefiles/cimis_CV/cimis_CV.shp")) %>% st_transform(st_crs(CDLs[[1]]))
CDLs <- lapply(CDLs, crop, CV)

# according to the metadata, 61 is Fallow/Idle
fallow_mask <- function(CDL){
  values(CDL) <- ifelse(values(CDL) == 61, 1, 0)
  return(CDL)
}
fallow_list <- lapply(CDLs, fallow_mask)
fallow_brick <- brick(fallow_list)
fallow_mean <- mean(fallow_brick)

# keep only if all three years are fallow
values(fallow_mean) <- ifelse(values(fallow_mean) == 1, 1, 0) 

# resample to the CA_grid
fallow_resampled <- fallow_mean %>% projectRaster(grid) %>% raster::resample(grid, method = "bilinear")

# keep if fallow lands are persistently in a pixel
values(fallow_resampled) <- ifelse(values(fallow_resampled) == 1, 1, 0) # change threshold here

# turn raster of fallow lands into a dataframe
fallow_CDL <- as.data.frame(fallow_resampled, xy = TRUE) %>% filter(layer == 1)

# compare fallow lands in the crop_pixels to those of the CDL layer. 
fallow_DWR <- filter(crop_pixels, CLASS2 %in% c("I", "X")) # idle or fallow OK
both <- filter(fallow_DWR, paste(x, y) %in% paste(fallow_CDL$x, fallow_CDL$y))
print(paste("Fraction of DWR fallow lands conserved:", nrow(both)/nrow(fallow_DWR)))

# remove fallow lands in the crop_pixels that are not also in the CDL layer. 
filtered_crop_pixels <- filter(crop_pixels, !(CLASS2 %in% c("X", "I") & !(paste(x, y) %in% paste(both$x, both$y))))

# Save filtered_crop_pixels
fwrite(filtered_crop_pixels, file = file.path(here("data", "intermediate", "crops", "crops_cdl&dwr2019.csv")))