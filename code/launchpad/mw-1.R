# launchpad script for a single run. 

# Set the parameters in the launchpad. The script then creates 
# a subfolder named after the runname in the output folder. 

# The path has to be set to the project root folder 

### 


###
root_dir <- '/Users/leyang/Documents/JHU-projects/LU-upscaling'
setwd(root_dir)

### PARAMS 
# parameters for launchpad
RUNNAME <- 'mw-cdl-1' # 1 degree solution upscale for Midwest using CDL

# parameters for grid generation 
LON_START <- -130  # -129.2 for 0.1 resolution  
LON_END <- -65     # -65.5 for 0.1 resolution  
LAT_START <- 23    # 23.8 for 0.1 resolution 
LAT_END <- 50      # 49.9 for 0.1 resolution
RES <- 1 
FN_RES <- ifelse(length(grep('.', as.character(RES), fixed=T)) == 0, 
                 as.character(RES),
                 gsub('.', '', as.character(RES), fixed=T))

### RUN COMPONENSTS
# create the output folder 
out_dir_name <- RUNNAME 
out_dir <- paste0(root_dir, '/output/', out_dir_name)
ifelse(!dir.exists(out_dir), dir.create(out_dir), FALSE)

# run A script (A.grids-coor-generation.R)
out_fn <- paste0(out_dir, '/', 'A.grids-coor-', FN_RES, '.csv')
source('./code/A.grids-coor-generation.R')
grids_coor_fn <- out_fn

# run B script 
cdl_fn <- paste0(root_dir, '/input/downloads/', '2018_30m_cdls/2018_30m_cdls.img')
out_fn <- paste0(out_dir, '/B.grid-cdl-stats-2018-', FN_RES, '.csv') 
source('./code/B.cdl-upscaling.R')

cdl_fn <- paste0(root_dir, '/input/downloads/', '2017_30m_cdls/2017_30m_cdls.img')
out_fn <- paste0(out_dir, '/B.grid-cdl-stats-2017-', FN_RES, '.csv') 
source('./code/B.cdl-upscaling.R')

cdl_fn <- paste0(root_dir, '/input/downloads/', '2016_30m_cdls/2016_30m_cdls.img')
out_fn <- paste0(out_dir, '/B.grid-cdl-stats-2016-', FN_RES, '.csv') 
source('./code/B.cdl-upscaling.R')

cdl_fn <- paste0(root_dir, '/input/downloads/', '2015_30m_cdls/2015_30m_cdls.img')
out_fn <- paste0(out_dir, '/B.grid-cdl-stats-2015-', FN_RES, '.csv') 
source('./code/B.cdl-upscaling.R')

cdl_fn <- paste0(root_dir, '/input/downloads/', '2014_30m_cdls/2014_30m_cdls.img')
out_fn <- paste0(out_dir, '/B.grid-cdl-stats-2014-', FN_RES, '.csv') 
source('./code/B.cdl-upscaling.R')

cdl_fn <- paste0(root_dir, '/input/downloads/', '2013_30m_cdls/2013_30m_cdls.img')
out_fn <- paste0(out_dir, '/B.grid-cdl-stats-2013-', FN_RES, '.csv') 
source('./code/B.cdl-upscaling.R')

cdl_fn <- paste0(root_dir, '/input/downloads/', '2012_30m_cdls/2012_30m_cdls.img')
out_fn <- paste0(out_dir, '/B.grid-cdl-stats-2012-', FN_RES, '.csv') 
source('./code/B.cdl-upscaling.R')

cdl_fn <- paste0(root_dir, '/input/downloads/', '2011_30m_cdls/2011_30m_cdls.img')
out_fn <- paste0(out_dir, '/B.grid-cdl-stats-2011-', FN_RES, '.csv') 
source('./code/B.cdl-upscaling.R')

cdl_fn <- paste0(root_dir, '/input/downloads/', '2010_30m_cdls/2010_30m_cdls.img')
out_fn <- paste0(out_dir, '/B.grid-cdl-stats-2010-', FN_RES, '.csv') 
source('./code/B.cdl-upscaling.R')

cdl_fn <- paste0(root_dir, '/input/downloads/', '2009_30m_cdls/2009_30m_cdls.img')
out_fn <- paste0(out_dir, '/B.grid-cdl-stats-2009-', FN_RES, '.csv') 
source('./code/B.cdl-upscaling.R')

cdl_fn <- paste0(root_dir, '/input/downloads/', '2008_30m_cdls/2008_30m_cdls.img')
out_fn <- paste0(out_dir, '/B.grid-cdl-stats-2008-', FN_RES, '.csv') 
source('./code/B.cdl-upscaling.R')

# run C script 
B_outs <- list.files(out_dir, pattern = 'B.grid-cdl-stats-')
B_outs <- paste0(out_dir, '/', B_outs)

for (cdl_csv_fn in B_outs) { 
  year <- unlist(strsplit(cdl_csv_fn, '-'))[8]
  out_fn <- paste0(out_dir, '/C.cdl-mw-frac-', year, '-', FN_RES, '.csv')
  out_fn_corn <- paste0(out_dir, '/C.cdl-mw-frac-', year, '-', FN_RES, '-corn-mat', '.csv')
  out_fn_sb <- paste0(out_dir, '/C.cdl-mw-frac-', year, '-', FN_RES, '-soybean-mat', '.csv')
  out_fn_area <- paste0(out_dir, '/C.grid-area.csv')
  source('./code/C.cdl-cropping-midwest.R')
}

# run P script plots
cdl_frac_list <- list.files(out_dir, pattern = 'C.cdl-mw-frac-') 
cdl_frac_list <- grep(cdl_frac_list, pattern = 'mat', invert = T, value = T)
year_list <- seq(2008, 2018)


rm(list = ls())
gc()
