# clean and split the fallow dataset into train, val, and test

library(here)
library(raster)
library(dplyr)
library(sf)
library(data.table)

source("file_paths.R")
set.seed(0) # get same split every time

# get a version of the ag data that's only 2016, 2018, and 2019. 
if (!file.exists(ag_dwr_years_loc)){
  ag <- fread(ag_data_loc)
  ag <- filter(ag, year %in% c(2016,2018,2019))
  fwrite(ag, ag_dwr_years_loc, append=FALSE)
}

clean_and_split <- function(remove_percent, cluster_size, fallow_data_loc=fallow_data_loc){

  fallow <- fread(fallow_data_loc)

  # clean -- some "fallow" pixels are obviously not actually fallow based on unreasonably high ET values

  # filter out the fallow pixels with 95% highest ET in the growing season
  if (remove_percent>0){
    gs <- filter(fallow, month %in% c(7,8,9)) %>%
      group_by(x,y,year) %>% summarise(ET = mean(ET)) 
    cutoff <- quantile(gs$ET, probs = c(1-remove_percent))
    low_gs <- gs[gs$ET < cutoff,]
    high_gs <- gs[gs$ET > cutoff,]
    fwrite(high_gs, here("data", "3_for_counterfactual", "agriculture", paste0("fallow_high_gs_ET", remove_percent, ",", cluster_size, ".csv")), append=FALSE) # save so that you can also filter out these in analysis

    filtered_fallow <- fallow %>% filter(paste(fallow$x, fallow$y, fallow$year) %in% paste(low_gs$x, low_gs$y, low_gs$year))
  } else {
    filtered_fallow <- fallow
  }

  # split the data based on proximity (don't want the same field in both splits)
  # fields are about a km across tops (google satellite view)

  # create clusters based on location. Function creates clusters of size dist km. 
  assign_cluster <- function(x, y, dist){
    
    x_size = dist/89 # 1 degree lon (x) = 89km = 89000m
    y_size = dist/111 # 1 degree lat (y) = 111km = 111000m
    
    x_fold = floor(x/x_size)*x_size
    y_fold = floor(y/y_size)*y_size
    
    cv_fold = paste(x_fold, y_fold, sep = ",")
    
    return(cv_fold)
  }

  filtered_fallow$cluster <- mapply(assign_cluster, filtered_fallow$x, filtered_fallow$y, cluster_size) #1km clusters

  # 60-10-30 train-val-test split 
  clusters <- unique(filtered_fallow$cluster)

  # training
  training_cs <- sample(clusters, size = length(clusters)*.6, replace = FALSE)
  clusters <- clusters[!(clusters %in% training_cs)]

  # val
  val_cs <- sample(clusters, size = length(clusters)*.25, replace = FALSE) # 25% of the remaining 40% is 10%

  # test
  test_cs <- clusters[!(clusters %in% val_cs)]

  # now split the actual data 
  train <- filtered_fallow %>% filter(cluster %in% training_cs)
  val <- filtered_fallow %>% filter(cluster %in% val_cs)
  test <- filtered_fallow %>% filter(cluster %in% test_cs)

  # save
  fwrite(train, here(training_data_path, paste0("fallow", remove_percent, ",", cluster_size, ".csv")), append=FALSE)
  fwrite(val, here(val_data_path, paste0("fallow", remove_percent, ",", cluster_size, "_val.csv")), append=FALSE)
  fwrite(test, here(test_data_path, paste0("fallow", remove_percent, ",", cluster_size, "_test.csv")), append=FALSE)
}

clean_and_split(.05, 2) # DWR fallow lands, remove 5%
clean_and_split(0, 2) # DWR fallow lands
clean_and_split(0.05, 2, fallow_cdl_data_loc) # DWR and CDL fallow lands, remove 5%
clean_and_split(0, 2, fallow_cdl_data_loc) # DWR and CDL fallow lands