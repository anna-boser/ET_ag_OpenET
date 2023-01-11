# This takes the final deicisions made using the experiments and uses the test set
# to perform a final round of testing and estimate natural ET over agriculture 

# It outputs predictions for spatial crossvalidation and for fallow fields using the test set
# which can then be plotted and analysed in 3_analysis/1_plot_experiments
# It also outputs predictions over agricultural lands

from model_class import MyModel
from sklearn.ensemble import RandomForestRegressor
from sklearn.ensemble import HistGradientBoostingRegressor

# first, define your model 
model = MyModel(experiment_name="fveg_2-5_gb_test_set_no_water", 
                dataset="fveg", 
                regressor=HistGradientBoostingRegressor(verbose=1, random_state=0), 
                nans_ok=False,
                month=True,
                features=["x", "y", "Elevation", "Slope", "Soil", "Aspect", "PET"], #"x", "y", "Elevation", "Slope", "Soil", "Aspect", "TWI", "PET" 
                hparam=False)

# second, perform a cross-validation using the test set
model.crossval(train_or_test="test")

# third, generate new predictions for fallow lands and agricultural lands
model.train_model(train_or_test="test")
model.predictions(ag_or_fallow="agriculture")
model.predictions(ag_or_fallow="fallow")