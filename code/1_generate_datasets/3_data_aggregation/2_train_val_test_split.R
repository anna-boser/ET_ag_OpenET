# create training, and test splits for use in ML. 

# Training is used to check if we've got a good CV score and 
# are relatively close to the fallow numbers when we predict over fallow fields

# Test splits will only be used once at the end to generate numbers over the
# whole ag areas and get a cross-val score. 

# The pseudo-random split will preserve which pixels are considered train or test
# across natural datasets. 
# The way it works is all datasets with both an x and a y coordinate with an
# even decimal in the last place will be included in the training set. 
# This is about 10% of the data
# The rest is reserved for test. 

# Anna Boser 11/14/2021

library(here)
library(raster)
library(dplyr)
library(sf)
library(fasterize)
library(data.table)
library(stringr)

source("file_paths.R")

datasets <- c("fveg.csv", 
              "cpad.csv", 
              "cdl.csv")

# condition for inclusion
check_inc <- function(dim){
  dim <- as.character(dim)
  second_last_dec <- substr(dim, nchar(dim)-1, nchar(dim)-1) %>% as.numeric() # the last decimal in the latitude direction is not super random
  (second_last_dec%%2) == 0
}

# split and save function
split <- function(dataset){
  df <- fread(here(natural_data_path, dataset))
  
  train <- filter(df, check_inc(x) & check_inc(y))
  dir.create(here(natural_data_path, "train"))
  fwrite(train, here(natural_data_path, "train", dataset), append=FALSE)
  rm(train)
  
  test <- filter(df, !(check_inc(x) & check_inc(y)))
  dir.create(here(natural_data_path, "test"))
  fwrite(test, here(natural_data_path, "test", dataset), append=FALSE)
}

# apply function to all datasets
for (dataset in datasets){
  split(dataset)
}
