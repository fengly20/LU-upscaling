library(sp)
library(raster)

cdl <- read.csv(cdl_csv_fn, stringsAsFactors = F) # cdl_fnget from launchpad 

cdl$frac[is.na(cdl$frac)] <- 0

lat_min <- min(c(cdl$lat_start, cdl$lat_end))
lat_max <- max(c(cdl$lat_start, cdl$lat_end))
nrow <- (lat_max - lat_min)/RES # RES get from launchpad

xmn <- LON_START # LON_START get from the launchpad
xmx <- LON_END   # ..
ymn <- LAT_START # ..
ymx <- LAT_END   # .. 
proj = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

midwest_names <- c('US.MN', 'US.IL', 'US.IN', 'US.IA', 'US.MO', 'US.OH', 'US.ND', 'US.SD', 'US.NE', 'US.WI')

cdl_corn <- cdl[cdl$type == 'corn', ]
cdl_corn <- cdl_corn[order(cdl_corn$id), ]
cdl_sb <- cdl[cdl$type == 'soybean', ]
cdl_sb <- cdl_sb[order(cdl_sb$id), ]

ras_corn <- raster(matrix(cdl_corn$frac, nrow = nrow), xmn = xmn, xmx = xmx, ymn = ymn, ymx = ymx, crs = proj)
ras_sb <- raster(matrix(cdl_sb$frac, nrow = nrow), xmn = xmn, xmx = xmx, ymn = ymn, ymx = ymx, crs = proj)

# cropping 
us <-getData('GADM', country='USA', level=1)
midwest <- us[us@data$HASC_1 %in% midwest_names, ]

ras_corn_mw <- mask(ras_corn, midwest)
ras_sb_mw <- mask(ras_sb, midwest)

cdl_corn$frac_mw <- c(as.matrix(ras_corn_mw))
cdl_corn$frac_mw[is.na(cdl_corn$frac_mw)] <- 0
cdl_sb$frac_mw <- c(as.matrix(ras_sb_mw))
cdl_sb$frac_mw[is.na(cdl_sb$frac_mw)] <- 0

cdl_mw <-rbind(cdl_corn, cdl_sb)
cdl_mw$year <- year

write.csv(cdl_mw, out_fn, row.names = F)

# write the matrix into csv  
write.table(as.matrix(ras_corn_mw), out_fn_corn, sep = ',', row.names = F, col.names = F) # fn get from launchpad 
write.table(as.matrix(ras_sb_mw), out_fn_sb, sep = ',', row.names = F, col.names = F) # ..
write.table(matrix(cdl_corn$area, nrow = nrow), out_fn_area, sep = ',', row.names = F, col.names = F) # ..

