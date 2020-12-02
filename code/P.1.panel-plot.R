# the script makes plots as disscussed with Zichong

library('sp')
library('raster')
library('rasterVis')
library('tidyr')

#cdl_frac_list # get from launchpad 
#year_list # get from launchpad

lat_list <- rev(seq(LAT_START, LAT_END, RES))
nlat <- length(lat_list)
PROJ_STRING <- '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'

file_list <- unlist(lapply(year_list, function(year){
  grep(cdl_frac_list, pattern = year, value = T)
}))

frac_ls <- lapply(paste0(out_dir, '/', file_list), function(x) { # out_dir get from launchpad 
  read.csv(x, stringsAsFactors = F)
  })
frac_df <- do.call('rbind', frac_ls)

stats_df <- data.frame()
for (type in unique(frac_df$type)) { 
  type_df <- frac_df[frac_df$type == type, c('id', 'frac_mw', 'year')]
  
  ave_list <- c()
  std_list <- c()
  for (id in sort(unique(type_df$id))) {
    year_df <- type_df[type_df$id == id, ]
    ave <- mean(year_df$frac_mw)
    std <- sd(year_df$frac_mw)
    ave_list <- c(ave_list, ave)
    std_list <- c(std_list, std)
  }
  out_df <- data.frame(id = sort(unique(type_df$id)), 
                       type = type, 
                       mean = ave_list,
                       sd = std_list,
                       stringsAsFactors = F)
  stats_df <- rbind(stats_df, out_df)
  }

corn_mat_mean <- stats_df[stats_df$type == 'corn', 'mean']
corn_mat_mean <- matrix(corn_mat_mean, nrow = nlat-1)
corn_ras_mean <- raster(corn_mat_mean, 
                        crs = PROJ_STRING,
                        xmn = LON_START,
                        xmx = LON_END,
                        ymn = LAT_START,
                        ymx = LAT_END)

corn_mat_sd <- stats_df[stats_df$type == 'corn', 'sd']
corn_mat_sd <- matrix(corn_mat_sd, nrow = nlat-1)
corn_ras_sd <- raster(corn_mat_sd, 
                      crs = PROJ_STRING,
                      xmn = LON_START,
                      xmx = LON_END,
                      ymn = LAT_START,
                      ymx = LAT_END)

sb_mat_mean <- stats_df[stats_df$type == 'soybean', 'mean']
sb_mat_mean <- matrix(sb_mat_mean, nrow = nlat-1)
sb_ras_mean <- raster(sb_mat_mean, 
                      crs = PROJ_STRING,
                      xmn = LON_START,
                      xmx = LON_END,
                      ymn = LAT_START,
                      ymx = LAT_END)

sb_mat_sd <- stats_df[stats_df$type == 'soybean', 'sd']
sb_mat_sd <- matrix(sb_mat_sd, nrow = nlat-1)
sb_ras_sd <- raster(sb_mat_sd, 
                    crs = PROJ_STRING,
                    xmn = LON_START,
                    xmx = LON_END,
                    ymn = LAT_START,
                    ymx = LAT_END)

us <-getData('GADM', country='USA', level=1)



mapTheme <- rasterTheme(region=brewer.pal(8,"Greens"))

png(paste0(out_dir, '/P.', 'test', ".png"), width = 1200, height = 800)
p <- levelplot(sb_ras_mean, 
               margin = FALSE, 
               main = paste0('corn', ' mean'),
               par.settings = mapTheme) + 
  layer(sp.polygons(us, lwd = 0.3))
print(p)
dev.off()


plot(sb_ras_mean)
plot(us, add = T)
