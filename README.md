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
## Running the pipeline

### Overview
The pipeline is structured around three tasks central to the analysis, located in the `code` folder: 
1. Processing already existing data into datasets usable for the study (`code/1_generate_datasets`) (R)
1. Creating the artificial counterfactual estimating natural ET (`code/2_counterfactual`) (Python)
1. Doing analysis (`code/3_analysis`) (R, Rmd)

There are additionally two helper files, `helper_functions.R`, and `file_paths.R`. `helper_functions.R` is simply a set of functions that get repeatedly called and are often sourced, especially during the analysis phase. `file_paths.R` defines the location of all data (and where it was generated or downloaded from), and is also sourced in all R code calling data. Therefore, if data storage needs to be reorganized, one must simply change this file and all R code writing or reading from this file will automatically still function. 

To run the pipeline from start to finish, run the numbered scripts in order. Each script has a header that describes its function, as well as comments to help with line-by-line interpretation of commands. 

### 1: Data processing

The first section of the pipeline, `code/1_generate_datasets`, is dedicated to amassing existing datasets into forms useful for generating the natural ET counterfactual and for doing analysis. This step generates the following datasets: 

1. A tabular dataset with the following values for each 70m pixel that is agricultural in nature (either actively in use or fallow/idle) in the California Central Valley
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
2. Train, validation, and test splits for all fallow/idle lands of the above data to be used to build the machine learning model for the natural ET counterfactual
3. Additional tabular datasets to be used in the analysis phase that have the following information for each pixel for the above data:
  - County
  - Crop type
  - Groundwater sub-basin

