# This scripts generates a distribution of the distance of a subsample of 
# agricultural picels to the nearest natural pixel for a variety of natural
# datasets 

# Anna Boser Nov 17, 2022

library(parallel)
library(tictoc)
library(here)
library(data.table)
library(dplyr)

datasets <- c("fveg", "cpad", "cdl")

distance_distribution_path <- here("data", "4_for_analysis", "distances")
dir.create(distance_distribution_path)

get_distance <- function(dataset){
  
  # name of file I need to create
  dist_filename <- here(distance_distribution_path, paste0(dataset, ".csv")) 
  
  # read in the agriculture data 
  ag <- fread(here("data", "3_for_counterfactual", "agriculture", "agriculture.csv")) %>% distinct(x, y, .keep_all=TRUE)
  
  # randomly pick some ag pixels
  ag_sample <- ag[sample(1:nrow(ag),500), ]
  agpoints <- ag_sample %>% dplyr::select(x,y) %>% as.matrix()
  
  # read in counterf pixels
  counterf <- fread(here("data", "3_for_counterfactual", "training_data", "test", paste0(dataset, ".csv")))
  
  # get all counterf pixels
  counterpoints <- counterf %>% dplyr::select(x,y) %>% distinct() %>% as.matrix()
  
  # get the minimum 
  getmindist <- function(i){
    return(min(raster::pointDistance(agpoints[i,], p2 = counterpoints, lonlat = TRUE)))
  }
  
  # calculate in parallel
  no_cores <- detectCores() - 1 # keep one so computer doesn't freeze up
  cl <- makeCluster(no_cores, type="FORK")
  
  tic()
  dist <- parSapply(cl, 1:nrow(agpoints), getmindist)
  toc()
  
  parallel::stopCluster(cl)
  
  ag_sample$mindist <- dist
  dist <- ag_sample
  
  fwrite(dist, dist_filename)
}

lapply(datasets, get_distance)

