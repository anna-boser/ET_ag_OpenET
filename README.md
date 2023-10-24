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
    - Yearly for 2016, 2018, and 2019, but where fallow lands are also cross-referenced with the CDL to make a more conservative training dataset (see 2.). 
    - 2014 and 2020 also processed to help gauge orchard age in the analysis. 
  - Groundwater sub-basin

#### Intermediate datasets

To build the first two datasets described above, we first gather the required existing datasets and process them to create raster versions of these data all available on the same 70m grid. This is achieved in `code/1_generate_datasets/1_intermediate`, for ET (`1_OpenET.R`), land cover (`2_agriculture.R`), PET (`4_PET.R`), soil quality (`5_soils.R and 5.5_soils.py`), topographic (`6_topography.R`), and topographic wetness index (`7_topographic_wetness_index.R) data. These last two are time varying and therefore generate multiple rasters. 

> Note to self: I think I should re-organize the data more in line with the pipeline. So e.g. all of the data that need to be gridded are in one place, then all of the gridded data, and then you can find the rest elsewhere.
> And get rid of the vegetation stuff
> Also, I can probably try renaming the code pipeline too idk?

#### Additional datasets

In `code/1_generate_datasets/2_additional_data`, we create the tabular datasets of county (`1_counties.R`), crop type (`2_crops.R`), and groundwater sub-basin (`5_basin.R`) for each pixel. 

> Note to self: 2.5_crops.R is cool in that it only keeps fallow feilds that the CDL also thinks is fallow. I'm tempted to use this to see what happens to the seasonality of natural ET if I train the model on this instead. Would need to make a split for this too. 

#### Data aggregation

Once these intermediate datasets have been generated, they can be aggregated to create datasets (`code/1_generate_datasets/3_data_aggregation`). We first create the main dataset in 1_datasets_for_ml.R by turning the gridded datasets into a singluar tabular dataset. Then, we add in county or crop type information to the dataset in `3_add_crop_county_data.R`. It is especially important to add in crop type information at this stage, since it is necessary to generate datasets for model training, validation, and testing, since these data are all exclusively over fallow/idle lands. This last step happens 

> Note to self: get rid of all the natural land cover stuff and also rename 1_datasets_for_ml
> 4_visualize.Rmd is kinda interesting -- it makes those histograms comparing what I trained on and what I applied to different. Don't need so should get rid of but good to keep in mind
> get rid of everything else
