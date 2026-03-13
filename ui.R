
library("aws.s3")
###
###
###
cas <-s3readRDS("trav/casparticuliers.rds", bucket = "kregtt",region="")

library(leaflet)
library(plyr)



library(sf)


test_result_path <- "dep_France_DOM.shp"

get_object("kregtt/trav/dep_France_DOM.shp"
           , bucket = Sys.getenv("S3_BUCKET"),region="") %>%
  writeBin(test_result_path)



test_result_path <- "dep_France_DOM.shx"

get_object("kregtt/trav/dep_France_DOM.shx"
           , bucket = Sys.getenv("S3_BUCKET"),region="") %>%
  writeBin(test_result_path)




test_result_path <- "www/dep_France_DOM.prj"

get_object("kregtt/trav/dep_France_DOM.prj"
           , bucket = Sys.getenv("S3_BUCKET"),region="") %>%
  writeBin(test_result_path)


test_result_path <- "www/dep_France_DOM.cpg"

get_object("kregtt/trav/dep_France_DOM.cpg"
           , bucket = Sys.getenv("S3_BUCKET"),region="") %>%
  writeBin(test_result_path)


test_result_path <- "www/dep_France_DOM.dbf"

get_object("kregtt/trav/dep_France_DOM.dbf"
           , bucket = Sys.getenv("S3_BUCKET"),region="") %>%
  writeBin(test_result_path)



depm <- read_sf("www/dep_France_DOM.shp")
depm<-subset(depm,reg=="53")
# comm <- read_sf("com_France_DOM.shp")
# comm<-subset(comm,reg=="53")
getwd()
comm <-s3readRDS("trav/comm.rds", bucket = "kregtt",region="")
comm[is.na(comm)] <- ""

#pal <- colorNumeric("Greens", domain = comm$type) ## create a color palette
# bins <- c(0, 1, 2, 3, Inf)
# pal <- colorBin("YlOrRd", domain = comm$type, bins = bins)

pal <- colorNumeric(c("white","red", "green", "blue"), comm$type)

# library(rmapshaper)
# commb <- comm %>% 
#   # Simplifier la géométrie pour une carte plus légère
#   rmapshaper::ms_simplify(keep = 0.01)  

commb <- comm %>%
  sf::st_transform('+proj=longlat +datum=WGS84')

depm <- depm %>%
  sf::st_transform('+proj=longlat +datum=WGS84')

 

map_regions <- leaflet() %>%
  addTiles() %>% 
  addPolygons(data=depm, weight= 3,col= "black",opacity = 0.7) %>% 
  addPolygons(
    data = commb,
    label = ~paste0(" ", libelle," ",lib," ",nom," "),
    popup = ~paste0(" ", libelle," ",lib," ",nom," "),
    color = "#444444", weight = 1, smoothFactor = 0.5,
     opacity = 1.0, fillOpacity = 0.5,
     fillColor = ~pal(type),
     highlightOptions = highlightOptions(color = "white", weight = 2,
                                         bringToFront = TRUE))  %>% 
  addLegend(
  title = "type",
  values = commb$type,
  colors = c("white","red", "green", "blue"),
  labels = c("", "dem", "prix", "bi-réseau"),
  
  ) 





map_regions

