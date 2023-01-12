# This script takes the output of 5_soils.R and resamples it to the consistent California grid

from pyprojroot import here
import rasterio
import datetime
import numpy as np
import pandas as pd
from osgeo import gdal, gdalconst
import matplotlib.pyplot as plt

# Source
src_filename = str(here("./data/2_intermediate/CA_storie/gNATSGO_storie.tif"))
src = gdal.Open(src_filename, gdalconst.GA_ReadOnly)
src_proj = src.GetProjection()
src_geotrans = src.GetGeoTransform()

# We want a section of source that matches this:
match_filename = str(here("./data/1_raw/study_area/CA_grid.tif"))
match_ds = gdal.Open(match_filename, gdalconst.GA_ReadOnly)
match_proj = match_ds.GetProjection()
match_geotrans = match_ds.GetGeoTransform()
wide = match_ds.RasterXSize
high = match_ds.RasterYSize

# Output / destination
dst_filename = str(here("./data/2_intermediate/CA_storie/CA_storie_index.tif"))
dst = gdal.GetDriverByName('GTiff').Create(dst_filename, wide, high, 1, gdalconst.GDT_Float32)
dst.SetGeoTransform(match_geotrans)
dst.SetProjection(match_proj)

# Do the work
gdal.ReprojectImage(src, dst, src_proj, match_proj, gdalconst.GRA_Bilinear)

del dst # Flush
