# ET_ag_disALEXI
 
## Installation instructions

This pipeline has parts written in both R and Python. To reproduce the Python environment we use, follow the steps bellow: 

1. Install [Conda](http://conda.io/)

2. Create environment and install requirements

```bash
conda create -n et_ag python=3.9 -y
conda activate et_ag
pip install -r requirements.txt
pip install -U sklearn
```
## Aquiring the data

...

## Running the pipeline

### Overview
The pipeline is structured around three tasks central to the analysis, located in the `code` folder: 
1. Processing already existing data into datasets usable for the study (`code/1_generate_datasets`) (R, Python)
1. Creating the artificial counterfactual estimating natural ET (`code/2_counterfactual`) (Python)
1. Doing analysis (`code/3_analysis`) (R, Rmd)

There are additionally two helper files, `helper_functions.R`, and `file_paths.R`. `helper_functions.R` is simply a set of functions that get repeatedly called and are often sourced, especially during the analysis phase. `file_paths.R` defines the location of all data (and where it was generated or downloaded from), and is also sourced in all R code calling data. Therefore, if data storage needs to be reorganized, one must simply change this file and all R code writing or reading from this file will automatically still function. 

To run the pipeline from start to finish, run the numbered scripts in order. Each script has a header that describes its function, as well as comments to help with line-by-line interpretation of commands. 

### Preliminary data processing

The first section of the pipeline, `code/1_generate_datasets`, is dedicated to amassing existing datasets into forms useful for generating the natural ET counterfactual and for doing analysis. This step generates the following datasets: 

1. The main dataset: A tabular dataset with the following values for each 70m pixel used for agriculture (either actively in use or fallow/idle) in the California Central Valley
  - latitude and longitude
  - year (2016, 2018, 2019)
  - month
  - Elevation
  - Aspect
  - Slope
  - Topographic Wetness Index (TWI)
  - Soil quality
  - PET
  - ET (from OpenET)
2. Train, validation, and test splits for all fallow/idle lands of the main dataset to be used to build the machine learning model for the natural ET counterfactual
3. Additional tabular datasets to be used in the analysis phase that have the following information for each pixel for the main dataset:
  - County
  - Crop type
    - Yearly for 2016, 2018, and 2019 for the main dataset. Used to determine if land was fallow (see 2.) as well as in analysis. 
    - Fallow lands for 2016, 2018, and 2019.
    - Fallow lands for 2016, 2018, and 2019, but where fallow lands are also cross-reference with the CDL to make a more conservative training dataset (see 2.). 
    - 2014 and 2020 also processed to help gauge orchard age in the analysis. 
  - Groundwater sub-basin

#### Intermediate datasets

To build the first two datasets described above, we first gather the required existing datasets and process them to create raster versions of these data all available on the same 70m grid. This is achieved in `code/1_generate_datasets/1_intermediate`, for ET (`1_OpenET.R`), land cover (`2_agriculture.R`), PET (`4_PET.R`), soil quality (`5_soils.R and 5.5_soils.py`), topographic (`6_topography.R`), and topographic wetness index (`7_topographic_wetness_index.R) data. These last two are time varying and therefore generate multiple rasters. 

> Note to self: I think I should re-organize the data more in line with the pipeline. So e.g. all of the data that need to be gridded are in one place, then all of the gridded data, and then you can find the rest elsewhere.
> And get rid of the vegetation stuff
> Also, I can probably try renaming the code pipeline too idk?

#### Additional datasets

In `code/1_generate_datasets/2_additional_data`, we create the tabular datasets of county (`1_counties.R`), crop type (`2_crops.R`, `2.5_crops.R`), and groundwater sub-basin (`5_basin.R`) for each pixel. 

#### Data aggregation

Once these intermediate datasets have been generated, they can be aggregated to create datasets (`code/1_generate_datasets/3_data_aggregation`). We first create the main dataset in `1_datasets_for_ml.R` by turning the gridded datasets into a singluar tabular dataset. Then, we add in county or crop type information to the dataset in `3_add_crop_county_data.R`. It is especially important to add in crop type information at this stage, since it is necessary to generate datasets for model training, validation, and testing, since these data are all exclusively over fallow/idle lands. 

Finally, in `5_clean_and_split_fallow.R`, we retrieve all the fallow observations from the main dataset and split them into training, validation, and test groups. The function to create a split takes three arguments: (1) the percent of the dataset you want to discard based on the highest growing season ET values (to avoid contamination from lands that are irrigated instead of fallow, (2) the size of areas to group for the spatial split, and (3) the dataset you want to use -- that is, if you want the dataset that has all fallow lands or the one that is cross-referenced with the CDL. 

> Note to self: get rid of all the natural land cover stuff and also rename 1_datasets_for_ml
> 4_visualize.Rmd is kinda interesting -- it makes those histograms comparing what I trained on and what I applied to different. Don't need so should get rid of but good to keep in mind
> get rid of everything else

### The artificial counterfactual

In the second part of the pipeline, `code/2_counterfactual`, we use the training and test data to train machine learning models that predict the ET that would happen over a field if that land were fallow. To do so, we first create a model class in `model_class.py` that allows you to define a model using a variety of regressors, tune hyperparameters, train the model, and generate predictions for the train, val, and test splits for whichever split you would like. This class is then called in `experiments.py` where you can edit this file as needed to train a variety of models and generate predictions as needed over the validation and test sets, as well as the full dataset of agricultural lands. 

> note to self -- the model class has a "train_or_test" thing that is outdated -- was used when I was doing veg stuff. Remove for clarity...? 

Every time an experiment is run in `experiments.py`, this creates a new folder with the name of the experiment which contains the following: 
- the `model_class.py` and `experiments.py` files as they were when the experiment was run, for reference of what parameters were used
- the trained model
- any predictions that the experiment produced

Notable experiments include: 
- `fallow0.05,2_4-18_gb`:
  - Here we use the split trained on the fallow lands as determined by the DWR LandIQ dataset (`fallow`), but with the fallow lands that have the 5% highest ET in the growing season removed (`0.05`). The spatial hold out sets used to make the split are 2km wide in either direction (`2`). This experiment was run on April 4, 2023 (`4-18`) and a gradient boosting regressor was used (`gb`).
  - This is the final model we elect for our work and analysis. 
- `fallow0,2_4-18_gb`:
  - Here we use the split trained on the fallow lands as determined by the DWR LandIQ dataset (`fallow`). The spatial hold out sets used to make the split are 2km wide in either direction (`2`). This experiment was run on April 4, 2023 (`4-18`) and a gradient boosting regressor was used (`gb`).
  - This model is used to check whether removing the fallow lands that have the 5% highest ET in the growing season has a significant impact on the results. 
- `fallow_cdl0,2_10-25_gb`:
  - Here we use the split trained on the fallow lands as determined by the DWR LandIQ dataset (`fallow`) *and* the cropland data layer (`cdl`). The spatial hold out sets used to make the split are 2km wide in either direction (`2`). This experiment was run on October 25, 2023 (`10-25`) and a gradient boosting regressor was used (`gb`).
  - This experiment is used to ensure that incorrect classification of fallow lands is not causing inflated natural ET estimates, especially during the growing season. 

At this stage, we additionally check the importance of different variables used in the model and plot this (`feature_importance.py`). We only run this for the experiment we elect for our analysis, `fallow0.05,2_4-18_gb`.

> Note to self: get rid of apply_model.py

### Analysis

In the last part of the pipeline, `code/3_analysis`, we use the counterfactual predictions from our chosen model to conduct our analysis. The code can also be modified to be run on other experiments in order to compare results across models (e.g. the effect of removing fallow fields with high growing season ET). The .Rmd files in this section are written in such a way that when they are run, you are left with not only an html output but a report and important figures will be written to the folder of the experiment whose data you are working from. 

> note to self: get rid of the whole additional manipualtion folder and move everything from plots and analysis to the main folder.  

We begin by doing some dataset pre-processing to make analysing the entire agricultural dataset including the counterfactual predictions easier (`0_tidy.R`). In this file, we do things like turn the month and year dummy variables back into single columns and save a subset of the data that is only fallow lands. Because the dataset is so large, we also save some aggregated versions of the data (e.g. averaged over time or space in different ways)

To validate the model(s), we use (`1_fallow_model_validation.R`). This script can either take the validation or test predictions from an experiment, tidy it in the same way that (`0_tidy.R`) tidies the full dataset, and returns some validation plots and metrics. 

> note to self: get rid of 1_validation.R

With the tidy dataset with the predctions of a validated model, we begin our analyis. First, we calcualte some summary statistics, including the overall variance in agricultral ET of the dataset in comparison to what would be expected from model error, and plot out the variation in space of the data (`2_ag_vs_counter_ET.R`). Second, we analyze and plot out seasonal variations (`2.5_temporal_variation.R`). Third, we quantify and plot variation within and between crop types (`3_crops_comparison`), and determine the amount of variation that is explained by crop type, and the proportion explained by climate. Fourth, we run some management scenarios to see how different approaches would affect agricultural ET (`4_scenarios.R`). Fifth, we compare agricultural ET to irrigation, calculate irrigation efficiency, and and compare these estimates to ones we would get from heuristics based on irrigation technology (`5_irrigation_comparison.R`). Sixth, we compare our approach of estimating agricultural ET to a crop-coefficient based approach (`6_CalSIMETAW_comparison.R`). Last, we analyze how orchard age affects agricultural ET (`8_orchard_age.Rmd`). 

> Note to self: 3_ is the one that needs to be edited to include the variance breakdown
> 4_ needs to be edited too
> 5_ needs new data on irrigation...
> 6_ eventually needs to be edited for the discussion but that's a future problem
> Get rid of 7_comparing_results???
