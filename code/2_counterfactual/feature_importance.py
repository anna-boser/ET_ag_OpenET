# This script checks the feature importance of the final model used
# One can use the script to get the feature importance of any model by 
# changing the experiment name and the features used in that experiment.

# Anna Boser
# October 25, 2023


import pickle
from pyprojroot import here
import matplotlib.pyplot as plt
import numpy as np

experiment_name = "fallow0.05,2_4-18_gb" # change as needed
experiment_path = str(here("data/4_for_analysis/ML_outputs/experiments")) + "/" + experiment_name

path = experiment_path+"/trained_model_train.pkl"
with open(path, 'rb') as f:
    model = pickle.load(f)

# these are grabbed from the experiments.py file from that experiment -- change as needed
features=["x", "y", "Elevation", "Slope", "Soil", "Aspect", "TWI", "PET"]

importances = model.feature_importances_

# There are 12 month variables and 3 year variables in the importances array. 
# Only do this if month and year are set to true in the experiment
feature_importances = importances[:len(features)]
month_importance = sum(importances[len(features):len(features)+12])
year_importance = sum(importances[len(features)+12:])

feature_names = features + ["Month", "Year"]
importances = list(feature_importances) + [month_importance] + [year_importance]

for feature, importance in zip(feature_names, importances):
    print(f'{feature}: {importance}')

# Plot
plt.figure(figsize=(10, 6))
plt.title("Feature importances")
plt.bar(feature_names, importances, align="center")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(experiment_path+'/feature_importance.png')