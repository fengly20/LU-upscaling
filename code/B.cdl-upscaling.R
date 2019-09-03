#TODO: check NAs

library(sp)
library(raster)

grid_coor <- read.csv(grids_coor_fn, stringsAsFactors = F) # grids_coor_fn get from launchpad

PROJ_STRING <- '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'

# 1 for corn, 5 for soybean
cdl_raw <- raster(cdl_fn) # cdl_fn gets from launchpad
proj_cdl <- projection(cdl_raw)

print(Sys.time())

res_ls <- lapply(1:nrow(grid_coor), function(i) {
  coor_slice <- grid_coor[i, ]
  e <- extent(c(coor_slice$lon_start, coor_slice$lon_end, coor_slice$lat_end, coor_slice$lat_start))
  p <- as(e, 'SpatialPolygons')
  projection(p) <- PROJ_STRING
  p <- spTransform(p, proj_cdl)
  
  cdl_crop_mat <- tryCatch({
    cdl_crop <- crop(cdl_raw, p)
    cdl_crop_mat <- as.matrix(cdl_crop)
    }, error = function(e) {
      cdl_crop_mat <- matrix(0)
      return(cdl_crop_mat)
  })
  
  ncell <- dim(cdl_crop_mat)[1] * dim(cdl_crop_mat)[2]
  corn <- cdl_crop_mat
  corn[corn != 1] <- 0 
  corn[corn != 0] <- 1
  soybean <- cdl_crop_mat
  soybean[soybean != 5] <- 0 
  soybean[soybean != 0] <- 1
  
  corn_per <- sum(corn) / ncell 
  soybean_per <- sum(soybean) / ncell
  
  out_df_corn <- coor_slice  
  out_df_corn$type <- 'corn'
  out_df_corn$frac <- corn_per
  out_df_soybean <- coor_slice  
  out_df_soybean$type <- 'soybean'
  out_df_soybean$frac <- soybean_per 
  
  out_df <- rbind(out_df_corn, out_df_soybean)
  
  if (i %% 100 == 0) { 
  print(paste0('done with cell: ', i))
  }

  return(out_df)
})

res <- do.call('rbind', res_ls)

write.csv(res, out_fn, row.names = F)

print(Sys.time())
