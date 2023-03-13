# This script runs experiments on the test data using 
# 1: different models 
# 2: different hyperparameter tuning
# 3: different datasets (CPAD, CDL, FVEG, as well as different subsets of those datasets)

# It outputs predictions for spatial crossvalidation and for fallow fields 
# which can then be plotted and analysed in 3_analysis/1_plot_experiments

from model_class import MyModel
from sklearn.ensemble import RandomForestRegressor
from sklearn.ensemble import HistGradientBoostingRegressor
from sklearn.ensemble import GradientBoostingRegressor

# first, define your model 
model = MyModel(experiment_name="fallow_3-9_gb", 
                dataset="fallow", 
                regressor=GradientBoostingRegressor(verbose=1, random_state=0), 
                nans_ok=False,
                month=True,
                year=True,
                features=["x", "y", "Elevation", "Slope", "Soil", "Aspect", "TWI", "PET"], 
                hparam=False)

# second, perform a cross-validation using the training set
# model.crossval(train_or_test="train")

# third, generate new predictions for fallow lands
model.train_model(train_or_test="train")
model.predictions(ag_or_fallow="fallow_val")
model.predictions(ag_or_fallow="fallow_test")
model.predictions(ag_or_fallow="agriculture_dwr_years")
# model.predictions(ag_or_fallow="fallow") # this no longer works ever since I don't have every year in as fallow since it creates a dummy for the year and then is missing columns. 

# first, define your model 
model = MyModel(experiment_name="fallow_no_controls_3-9_gb", 
                dataset="fallow", 
                regressor=GradientBoostingRegressor(verbose=1, random_state=0), 
                nans_ok=False,
                month=True,
                year=True,
                features=["x", "y"], #, "Elevation", "Slope", "Soil", "Aspect", "TWI", "PET"], 
                hparam=False)

# second, perform a cross-validation using the training set
# model.crossval(train_or_test="train")

# third, generate new predictions for fallow lands
model.train_model(train_or_test="train")
model.predictions(ag_or_fallow="fallow_val")
model.predictions(ag_or_fallow="fallow_test")
model.predictions(ag_or_fallow="fallow_test")
model.predictions(ag_or_fallow="agriculture_dwr_years")
# model.predictions(ag_or_fallow="fallow") # this no longer works ever since I don't have every year in as fallow since it creates a dummy for the year and then is missing columns. 

