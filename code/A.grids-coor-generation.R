# The script generates the corner coordinates for each 
# grid box in the given domain and resolution. The output is a dataframe.   
# The script takes a lot parameters from launchpad
# TODO: make it a function 

library(sp)
library(geosphere)

### parameters get from launchpad
#LON_START <- -130  # -129.2 for 0.1 resolution  
#LON_END <- -65     # -65.5 for 0.1 resolution  
#LAT_START <- 23    # 23.8 for 0.1 resolution 
#LAT_END <- 50      # 49.9 for 0.1 resolution
#RES <- 1 
#FN_RES <- ifelse(length(grep('.', as.character(RES), fixed=T)) == 0, 
#                 as.character(RES),
#                 gsub('.', '', as.character(RES), fixed=T))
###


                 
lon_list <- seq(LON_START, LON_END, RES)
lat_list <- rev(seq(LAT_START, LAT_END, RES))
nlon <- length(lon_list)
nlat <- length(lat_list)

df <- data.frame()
for (i in 1:(length(lon_list)-1)){
  for (j in 1:(length(lat_list)-1)){
    df_slice <- data.frame(id = (i-1)*nlat + j, 
                           lat_start = lat_list[j],
                           lat_end = lat_list[j+1],
                           lon_start = lon_list[i],
                           lon_end = lon_list[i+1],
                           lat = (lat_list[j]+lat_list[j+1])/2,
                           lon = (lon_list[i]+lon_list[i+1])/2)
    df <- rbind(df, df_slice)
  }
}

# calculate the grid area 

# generate a GridTopology object contains a column of grids for -90 to 90 in latitude
offset <- c(LAT_END, LAT_START+RES/2 )
gridres <- c(RES, RES)
crnum <- c(1, nlat-1)
grid_topo <- GridTopology(offset, gridres, crnum )
polygon_topo <- as( grid_topo, 'SpatialPolygons' )
grid_cell_area <- areaPolygon( polygon_topo )  # in square meters 

all_cell_area <- rep(grid_cell_area, nlon-1)

df$area <- all_cell_area
df$area_unit <- 'm2'

write.csv(df, out_fn, row.names = F) # out_fn get from launchpad
