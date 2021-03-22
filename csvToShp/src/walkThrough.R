###
# convert data from a csv to a spatial feature 
# carverd@colostate.edu
# 20210224
###

## if needs install "sp", "sf","tmap"
# install.packages("sp")
# libraries 
library(sp)
library(sf)
library(tmap)
baseDir<- "F:/geoSpatialCentroid/videoProduction/csvToShp"

# data set with lat long  already - squash data 
## squash wild relatives
# https://github.com/dcarver1/R_SC_Spatial
d1 <- read.csv(paste0(baseDir, "/data/cucurbitadata.csv"))
View(d1)

## SP 
names(d1)
coords <- d1[,c("longitude", "latitude")]
# wgs1984 at https://spatialreference.org/ref/epsg/wgs-84/proj4/
wgs1984 <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
pointsSP <- sp::SpatialPointsDataFrame(coords =coords ,
                                       data = d1 ,
                                       proj4string = wgs1984 )
class(pointsSP)
tmap::qtm(pointsSP)

## SF 
pointsSF <- sf::st_as_sf(d1, coords = c("longitude", "latitude"), crs = 4326)
class(pointsSF)
tmap::qtm(pointsSF)

## difference between SP and SF 
class(pointsSP)
View(pointsSP)
View(pointsSP@data)

class(pointsSF)
View(pointsSF)

# write out the file 
sf::st_write(pointsSF, paste0(baseDir,"/outputs/file1.shp"))

sf::st_write(sf::st_as_sf(pointsSP), paste0(baseDir,"/outputs/file2.shp"))

## covid small business 
# https://opendata.fcgov.com/browse?sortBy=most_accessed&
# read in the data 
d2 <- read.csv(paste0(baseDir, 
                      "/data/Support_Fort_Collins_Business_during_COVID-19.csv"))
View(d2)
### prep data : split into lat long
library(tidyr)

# drop all na values 
d2$GPS.Location[31]

d2 <- d2[d2$GPS.Location != "", ]

# drop text, 
d2$GPS.Location <- sub(pattern = "POINT ",
                       x = d2$GPS.Location,
                       replacement = "" )
# add brackets for forcing with potential species characters 
d2$GPS.Location <- sub(pattern = '[(]',
                       x = d2$GPS.Location,
                       replacement = "" )

d2$GPS.Location <- sub(pattern = "[)]",
                       x = d2$GPS.Location,
                       replacement = "" )
View(d2)

d3 <- tidyr::separate(data = d2,
                col ="GPS.Location",
                into = c("longitude", "latitide"), 
                sep = " ")
View(d3)

tmap::tmap_mode("view")
# SP 
class(d3$longitude)
### build coordinates and set as numeric 
d3$longitude2 <- as.numeric(d3$longitude)
d3$latitide2 <- as.numeric(d3$latitide)

pSP <- sp::SpatialPointsDataFrame(coords = d3[c("longitude2", "latitide2")],
                                       data = d3 ,
                                       proj4string = wgs1984 )
qtm(pSP)

# SF
pSF <- sf::st_as_sf(x = d3, coords =  c("longitude", "latitide"), crs = 4326)
qtm(pSF)



