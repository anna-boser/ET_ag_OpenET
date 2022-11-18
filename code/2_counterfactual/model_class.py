import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn import metrics
from sklearn.model_selection import GroupKFold
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import RandomizedSearchCV
from sklearn.model_selection import cross_val_predict
from pyprojroot import here
import math
import pickle
import os
import shutil
import time

class MyModel():

    def __init__(self, experiment_name, dataset, regressor, nans_ok=False, month=True, features=["x", "y", "Elevation", "Slope", "Soil", "Aspect", "TWI", "PET"], hparam=False):

        # locate the natural and agricultural datasets you may want to use
        self.train_data_loc = str(here("data/3_for_counterfactual/training_data/train")) + "/" + dataset + ".csv"
        self.test_data_loc = str(here("data/3_for_counterfactual/training_data/test")) + "/" + dataset + ".csv"
        self.fallow_data_loc = str(here("data/3_for_counterfactual/agriculture/fallow.csv"))
        self.ag_data_loc = str(here("data/3_for_counterfactual/agriculture/agriculture.csv"))

        self.regressor = regressor
        self.nans_ok = nans_ok
        self.hparam = hparam
        self.features = features
        self.experiment_name = experiment_name
        self.experiment_path = str(here("data/4_for_analysis/ML_outputs/experiments")) + "/" + experiment_name
        self.month = month

        if not os.path.exists(self.experiment_path):
            os.makedirs(self.experiment_path)

        # save the scripts that generated and called this object to the experiments folder
        shutil.copy(here("code/2_counterfactual/experiments.py"), self.experiment_path + "/experiments.py")
        shutil.copy(here("code/2_counterfactual/model_class.py"), self.experiment_path + "/model_class.py")

    def crossval(self, train_or_test="train", distances=[30000, 20000, 10000, 5000, 2000, 1000, 1]):

        # retrieve the dataset to crossvalidate over
        if train_or_test=="train":
            df = pd.read_csv(self.train_data_loc)
        else:
            df = pd.read_csv(self.test_data_loc)
        
        if self.nans_ok == False:
            df = df.fillna(-9999)
    
        # retrive the features (columns) of interest 
        X = df[self.features]
        y = df['ET']
    
        if self.month:
            df = pd.get_dummies(df, columns=["month"])
            X_months = df[df.columns[df.columns.str.startswith("month")]]
            X = pd.concat([X, X_months], join = 'outer', axis = 1)

        # retrieve the parameters..?
        if self.hparam==True:
            hyperparameters = pickle.load(open(self.experiment_path+"/model_parameters.pkl", 'rb')) #rb is read mode. 
            print(hyperparameters, flush=True)
        
        cols = list(df) + ['fold_size', 'cv_fold', "ET_pred"]
        cv_df = pd.DataFrame(columns=cols)

        for dist in distances: 

            df = df.assign(fold_size=dist)

            # I first generate an extra column for my dataset called cv_fold which corresponds to its location

            # 1. Convert to miles to degrees. See: https://www.nhc.noaa.gov/gccalc.shtml
            # 2. Divide by number of degrees
            # 3. Floor operation
            # 4. turn back into coordinates
            # 5. String together

            x_size = dist/89000 # 1 degree lon (x) = 89km = 89000m
            y_size = dist/111000 # 1 degree lat (y) = 111km = 111000m
            
            # add a column to the df that indicates which crossvalidation group it falls into
            df = df.assign(cv_fold = lambda x: x.x.apply(lambda val: str(math.floor(val/x_size)*x_size)) +","+ x.y.apply(lambda val: str(math.floor(val/y_size)*y_size)))
            print(df.head(), flush=True)

            # How many folds = number of cells or cv_folds
            # n_fold = df.cv_fold.nunique() # set is same as unique function in R
            # print(n_fold, flush=True)
            kf = GroupKFold(5) #leave out 20% of the data at a time
            split = kf.split(df, groups = df['cv_fold'])

            if self.hparam==True:
                self.regressor.set_params(**hyperparameters) # use the parameters from the randomized search
            
            print("predictions beginning", flush=True)
            start = time.time()
            y_pred = cross_val_predict(self.regressor, X, y, cv=split, verbose=1, n_jobs = -1)
            end = time.time()
            print("predictions completed; time elapsed: "+str(end-start), flush=True)

            df = df.assign(ET_pred=y_pred)
            cv_df = pd.concat([cv_df, df], axis = 0)

        
        # save the full predictions using the spatial CV
        cv_df.to_csv(self.experiment_path+"/crossval_predictions_" + train_or_test + ".csv", index=False)
        print("crossval predictions saved", flush=True)

        return

    def train_model(self, train_or_test="train"):

        # train the model on the whole set that was 
        print("Training model from scratch; loading dataset", flush=True)  

        # load full dataset
        if train_or_test=="train":
            df = pd.read_csv(self.train_data_loc)
        else:
            df = pd.read_csv(self.test_data_loc)

        if self.nans_ok == False:
            df = df.fillna(-9999)

        # split between predictors and predicted
        X = df[self.features]
        y = df['ET']

        if self.month:
            df = pd.get_dummies(df, columns=["month"])
            X_months = df[df.columns[df.columns.str.startswith("month")]]
            X = pd.concat([X, X_months], join = 'outer', axis = 1)


        if self.hparam==True:
            # retrieve the parameters that were generated in 3_hyperparameter_tuning
            hyperparameters = pickle.load(open(str(here("./data/for_analysis/hyperparameter_tune/"))+"/model_parameters.pkl", 'rb')) #rb is read mode. 
            self.regressor.set_params(**hyperparameters) # use the parameters from the randomized search
            
        print("regressor defined, training beginning", flush=True)
        self.regressor.fit(X, y)
        print("training completed; pickle beginning", flush=True)

        # pickle the trained model
        with open(self.experiment_path+"/trained_model_"+train_or_test+".pkl", 'wb') as f:
            pickle.dump(self.regressor, f)
        print("pickle completed", flush=True)

        return

    def predictions(self, ag_or_fallow="agriculture"):
        
        # are you predicting over all agriculture or only fallow lands? 
        if ag_or_fallow=="agriculture":
            df = pd.read_csv(self.ag_data_loc)
        else:
            df = pd.read_csv(self.fallow_data_loc)

        if self.nans_ok == False:
            df = df.fillna(-9999)

        # split between predictors and predicted
        X = df[self.features]
        y = df['ET']

        if self.month:
            df = pd.get_dummies(df, columns=["month"])
            X_months = df[df.columns[df.columns.str.startswith("month")]]
            X = pd.concat([X, X_months], join = 'outer', axis = 1)

        y_pred = self.regressor.predict(X)
        df = df.assign(ET_pred=y_pred)

        # calculate the difference between the actual and counterfactual ET
        df['ag_ET'] = df.ET- df.ET_pred
        print("prediction completed; saving beginning", flush=True)

        # save the new dataset
        df.to_csv(self.experiment_path+"/"+ag_or_fallow+".csv", index=False)

        return

# test code for debugging 
if __name__ == '__main__':

    from sklearn.ensemble import RandomForestRegressor

    # first, define your model 
    model = MyModel(experiment_name="exp_cpad_trial", 
                    dataset="cpad", 
                    regressor=RandomForestRegressor(n_estimators=100, verbose=1, random_state=0, n_jobs = -1), 
                    nans_ok=False, 
                    month=True,
                    features=["x", "y", "Elevation", "Slope", "Soil", "Aspect", "TWI", "PET"], 
                    hparam=False)

    # second, perform a cross-validation using the test set
    model.crossval(train_or_test="train")

    # third, generate new predictions for fallow lands
    model.train_model(train_or_test="train")
    model.predictions(ag_or_fallow="fallow")



