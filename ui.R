
library("aws.s3")
###
###
###
cas <-s3readRDS("trav/casparticuliers.rds", bucket = "kregtt",region="")

library(leaflet)
library(plyr)



library(sf)
depm <- read_sf("dep_France_DOM.shp")
depm<-subset(depm,reg=="53")
comm <- read_sf("com_France_DOM.shp")
depm<-subset(depm,reg=="53")
getwd()
comm <-s3readRDS("trav/comm.rds", bucket = "kregtt",region="")


#pal <- colorNumeric("Greens", domain = comm$type) ## create a color palette
bins <- c(0, 1, 2, 3, Inf)
pal <- colorBin("YlOrRd", domain = comm$type, bins = bins)
# library(rmapshaper)
# commb <- comm %>% 
#   # Simplifier la géométrie pour une carte plus légère
#   rmapshaper::ms_simplify(keep = 0.01)  

commb <- comm %>%
  sf::st_transform('+proj=longlat +datum=WGS84')


map_regions <- leaflet() %>%
  addTiles() %>% 
  addPolygons(
    data = commb,
    label = ~libelle,
    popup = ~paste0(" ", libelle," ",lib," ",nom," "),
    color = "#444444", weight = 1, smoothFactor = 0.5,
     opacity = 1.0, fillOpacity = 0.5,
     fillColor = ~pal(type),
     highlightOptions = highlightOptions(color = "white", weight = 2,
                                         bringToFront = TRUE))  %>% 
  addLegend(
  title = "type",
  pal = pal, values = commb$type)

map_regions

