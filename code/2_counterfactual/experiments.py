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
model = MyModel(experiment_name="fvegg_water_buffer_2-7_gb", 
                dataset="fveg_water_buffer", 
                regressor=GradientBoostingRegressor(verbose=1, random_state=0), 
                nans_ok=False,
                month=True,
                year=True,
                features=["x", "y", "Elevation", "Slope", "Soil", "Aspect", "TWI", "PET"], 
                hparam=False)

# second, perform a cross-validation using the training set
model.crossval(train_or_test="train")

# third, generate new predictions for fallow lands
model.train_model(train_or_test="train")
model.predictions(ag_or_fallow="fallow")
model.predictions(ag_or_fallow="agriculture")
