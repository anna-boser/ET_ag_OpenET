# remove fveg pixels within 500m of water
# Anna Boser 2 7 2023

library(here)
library(data.table)
library(dplyr)

source("file_paths.R")

water <- fread(water_buffer_loc)
water$x <- round(water$x, 7)
water$y <- round(water$y, 7)

dataset <- "fveg"

train <- fread(here(natural_data_path, "train", paste0(dataset, ".csv")))
train$x <- round(train$x, 7)
train$y <- round(train$y, 7)

train2 <- filter(train, !(paste(x,y) %in% paste(water$x, water$y)))
fwrite(train, here(natural_data_path, "train", paste0(dataset, "_water_buffer.csv")), append=FALSE)
