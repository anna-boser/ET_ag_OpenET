# clean and split the fallow dataset into train, val, and test

library(here)
library(raster)
library(dplyr)
library(sf)
library(data.table)

source("file_paths.R")
set.seed(0) # get same split every time

# fallow <- fread(fallow_data_loc)

# # clean -- some "fallow" pixels are obviously not actually fallow based on unreasonably high ET values

# # filter out the fallow pixels with 95% highest ET in the growing season
# gs <- filter(fallow, month %in% c(7,8,9)) %>%
#   group_by(x,y,year) %>% summarise(ET = mean(ET)) 
# cutoff <- quantile(gs$ET, probs = seq(0,1,.95))[2]
# low_gs <- gs[gs$ET < cutoff,]


# filtered_fallow <- fallow %>% filter(paste(fallow$x, fallow$y, fallow$year) %in% paste(low_gs$x, low_gs$y, low_gs$year))

# # split the data based on proximity (don't want the same field in both splits)
# # fields are about a km across tops (google satellite view)

# # create clusters based on location. Function creates clusters of size dist km. 
# assign_cluster <- function(x, y, dist){
  
#   x_size = dist/89 # 1 degree lon (x) = 89km = 89000m
#   y_size = dist/111 # 1 degree lat (y) = 111km = 111000m
  
#   x_fold = floor(x/x_size)*x_size
#   y_fold = floor(y/y_size)*y_size
  
#   cv_fold = paste(x_fold, y_fold, sep = ",")
  
#   return(cv_fold)
# }

# filtered_fallow$cluster <- mapply(assign_cluster, filtered_fallow$x, filtered_fallow$y, 1) #1km clusters

# # 60-10-30 train-val-test split 
# clusters <- unique(filtered_fallow$cluster)

# # training
# training_cs <- sample(clusters, size = length(clusters)*.6, replace = FALSE)
# clusters <- clusters[!(clusters %in% training_cs)]

# # val
# val_cs <- sample(clusters, size = length(clusters)*.25, replace = FALSE) # 25% of the remaining 40% is 10%

# # test
# test_cs <- clusters[!(clusters %in% val_cs)]

# # now split the actual data 
# train <- filtered_fallow %>% filter(cluster %in% training_cs)
# val <- filtered_fallow %>% filter(cluster %in% val_cs)
# test <- filtered_fallow %>% filter(cluster %in% test_cs)

# # save
# fwrite(train, training_data_loc, append=FALSE)
# fwrite(val, val_data_loc, append=FALSE)
# fwrite(test, test_data_loc, append=FALSE)

# also get a version of the ag data that's only 2016, 2018, and 2019. 
ag <- fread(ag_data_loc)
ag <- filter(ag, year %in% c(2016,2018,2019))
fwrite(ag, ag_dwr_years_loc, append=FALSE)