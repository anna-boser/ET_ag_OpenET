# remove fveg pixels that are wetlands
# Anna Boser 2 7 2023

library(here)
library(data.table)
library(dplyr)

source("file_paths.R")

water <- fread(wetlands_loc)
water$x <- round(water$x, 7)
water$y <- round(water$y, 7)

dataset <- "fveg"

train <- fread(here(natural_data_path, "train", paste0(dataset, ".csv")))
train$x <- round(train$x, 7)
train$y <- round(train$y, 7)

train <- filter(train, !(paste(x,y) %in% paste(water$x, water$y)))
fwrite(train, here(natural_data_path, "train", paste0(dataset, "_no_wetlands.csv")), append=FALSE)

test <- fread(here(natural_data_path, "test", paste0(dataset, ".csv")))
test$x <- round(test$x, 7)
test$y <- round(test$y, 7)

test <- filter(test, !(paste(x,y) %in% paste(water$x, water$y)))
fwrite(test, here(natural_data_path, "test", paste0(dataset, "_no_wetlands.csv")), append=FALSE)