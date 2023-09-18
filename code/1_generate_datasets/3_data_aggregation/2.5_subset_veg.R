# this script takes fveg, takes a random 10% subset, and removes years where there is no crop info

library(data.table)
library(here)
library(dplyr)

source("file_paths.R")

# dataname <- "fveg"
dataname <- "fveg_no_wetlands"
# dataname <- "cpad"
# dataname <- "cdl"

fveg <- fread(here(natural_data_path, paste0(dataname, ".csv")))
fveg <- filter(fveg, year %in% c(2016, 2018, 2019)) # keep years with crop info
fveg <- fveg[sample(1:nrow(fveg), floor(nrow(fveg)/10), replace = FALSE),] # random 10%
fwrite(fveg, here(natural_data_path, "test", paste0(dataname, "_subset.csv")), append = FALSE)