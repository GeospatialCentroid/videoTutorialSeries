###
# read in rasters and prep for a project of interest 
# carverd@colostate.edu
# 20210217 
### 

#load libraries 
library(raster)
library(sf)
library(tmap)
library(dplyr)
tmap::tmap_mode("plot")

# set baseDir
baseDir <- "D:/geoSpatialCentroid/videoProduction/vid1"


# read in a raster raster::raster()
r1 <- raster::raster(paste0(baseDir, "/data/wc2.1_10m_bio_1.tif"))

# discuss elements of the feature tmap::qtm()
r1
# read in a shape file sf::st_read
# select country of interest dplyr::filter()
sp1 <- sf::st_read(paste0(baseDir, 
                          "/data/countries/ne_10m_admin_0_countries.shp"))
View(sp1)
india <- sp1 %>%
  dplyr::filter(ADMIN == "India")
qtm(india)

# create an extent object 
ex1 <- raster::extent(india)
ex1
# use that to crop the feature raster::crop 
r2 <- raster::crop(x = r1, y = ex1)
qtm(r2)

# mask the feature to the exact extent of the area raster::mask()
r3 <- raster::mask(x = r2, mask = india)
qtm(r3)

# reproject the raster raster::projectRaster()
# define CRS 
proj <- raster::crs("+proj=aea +lat_1=28 +lat_2=12 +lat_0=20 +lon_0=78 +x_0=2000000 +y_0=2000000 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
proj
# run projection 
r4 <- raster::projectRaster(r3, crs = proj)
r4


### create function  
clipMaskProj <- function(raster, polygon, projection){
  r1 <- raster %>%
    raster::crop(y = polygon)%>%
    raster::mask(mask = polygon)%>%
    raster::projectRaster(crs = projection)
  return(r1)
}


# run function 
feature <- clipMaskProj(raster = r1,
                        polygon = india,
                        projection = proj)

qtm(feature)



#iterate the process 
rasters <- list.files(path = baseDir,
                      pattern = ".tif", 
                      full.names = TRUE,
                      recursive = TRUE)

results <- list()
for(i in seq_along(rasters)){
  print(i)
  rast <- raster::raster(rasters[i])
  t1 <- clipMaskProj(raster = rast,polygon = india, projection = proj )
  raster::writeRaster(x = t1, filename = paste0(baseDir, ""))
  results[i] <- t1
}





