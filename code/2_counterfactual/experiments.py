# This script runs experiments on the test data using 
# 1: different models 
# 2: different hyperparameter tuning
# 3: different datasets 

# It outputs predictions for spatial crossvalidation and for fallow fields 
# which can then be plotted and analysed in 3_analysis/1_plot_experiments

from model_class import MyModel
from sklearn.ensemble import RandomForestRegressor
from sklearn.ensemble import HistGradientBoostingRegressor
from sklearn.ensemble import GradientBoostingRegressor

# first, define your model 
model = MyModel(experiment_name="fallow0.05,2_4-18_gb", # change for every experiment. Suggested naming convention: dataset/split name _ date _ model type
                dataset="fallow0.05,2", # What dataset? Options: fallow_0.05,2. fallow_0,2, fallow_cdl0,2. See split file. 
                regressor=GradientBoostingRegressor(verbose=1, random_state=0), # What kind of refressor? Can use RandomForestRegressor, GradientBoostingRegressor, etc. 
                nans_ok=False, # Can this model handle NaN values? 
                month=True, # Does this dataset have values for different months? If so, will turn into dummies
                year=True, # Does this dataset have values for different years? If so, will turn into dummies
                features=["x", "y", "Elevation", "Slope", "Soil", "Aspect", "TWI", "PET"]) # What predictors do you want to use? 

# second, (optionally) tune hyperparameters 
hyperparameters = model.tune_hyperparameters(train_or_test="train")
print(hyperparameters, flush=True) # check what hyperparameters you ended up with

# Optionally, perform a cross-validation using the training set -- only if there's large spatial gaps in available data. 
# This option was created when we were using natural lands and not fallow lands, and has since become obsolete. 
# model.crossval(train_or_test="train")

# third, generate new predictions for fallow lands
model.train_model(train_or_test="train")
model.predictions(ag_or_fallow="fallow_val")
model.predictions(ag_or_fallow="fallow_test")
model.predictions(ag_or_fallow="agriculture_dwr_years")