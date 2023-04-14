# This script contains functions I use again and again across analysis
# Anna Boser
# 4/11/23

library(here)
library(dplyr)

source(here("file_paths.R"))

# for plotting, what bounds to use
minlong <- -122.92
maxlong <- -117.8
minlat <- 34.8
maxlat <- 40.4


# add gsa info (this function may not be used -- if so I should delete.)
add_gsa <- function(data){
  # read in GSA info
  gsa <- fread(gsa_table_loc)
  
  # merge
  data$x <- round(data$x, 7)
  data$y <- round(data$y, 7)
  
  gsa$cell <- NULL
  gsa$coverage <- NULL
  gsa$x <- round(gsa$x, 7)
  gsa$y <- round(gsa$y, 7)
  
  data <- merge(data, gsa, by = c("x", "y"), all.x=TRUE)
  
  return(data)
}

# add basin info
add_basin <- function(data){
  # read in basin info
  basin <- fread(basin_table_loc)
  
  # merge
  data$x <- round(data$x, 7)
  data$y <- round(data$y, 7)
  
  basin$cell <- NULL
  basin$x <- round(basin$x, 7)
  basin$y <- round(basin$y, 7)
  
  data <- merge(data, basin, by = c("x", "y"), all.x=TRUE)
  
  return(data)
}

# create clusters based on location and year. Function creates clusters of size dist km. 
assign_cluster <- function(x, y, dist){
  
  x_size = dist/89 # 1 degree lon (x) = 89km = 89000m
  y_size = dist/111 # 1 degree lat (y) = 111km = 111000m
  
  x_fold = floor(x/x_size)*x_size
  y_fold = floor(y/y_size)*y_size
  
  cv_fold = paste(x_fold, y_fold, sep = ",")
  
  return(cv_fold)
}


# change units of ET data
scale <- function(data, scalar=1.2){
  data$ET <- data$ET*scalar
  data$ET_pred <- data$ET_pred*scalar
  data$ag_ET <- data$ag_ET*scalar
  return(data)
}


# print the confidence interval
print_CI <- function(varname, mean, se){
  upper <- (mean + 1.96*se) %>% round(1)
  mean <- mean %>% round(1)
  lower <- (mean - 1.96*se) %>% round(1)
  paste0(varname, ": ", mean, " (", lower, ", ", upper, " 95% CI)")
}

# control for year
year_control <- function(data){
  data$year <- as.factor(data$year)
  data$ag_ET <- data$ag_ET - (lm(ag_ET~year, data)$fitted.values - mean(data$ag_ET))
  data$ET <- data$ET - (lm(ET~year, data)$fitted.values - mean(data$ET))
  data$ET_pred <- data$ET_pred - (lm(ET_pred~year, data)$fitted.values - mean(data$ET_pred))
  return(data)
}

# function to extract the mean and ci values from felm regression
df_from_felm <- function(input_lm, name_length = 10, var="cropnames"){
  ET_df <- as.data.frame(cbind(input_lm$coefficients, input_lm$cse))
  colnames(ET_df) <- c("ET", "se")
  ET_df$min <- ET_df$ET-(1.96*ET_df$se)
  ET_df$max <- ET_df$ET+(1.96*ET_df$se)
  ET_df[,var] <- substring(rownames(ET_df), name_length)
  return(ET_df)
}

