setwd("/home/onyxia/work/trav")
library("aws.s3")
###
###
###
cas <-s3readRDS("trav/casparticuliers.rds", bucket = "kregtt",region="")

library(leaflet)
library(plyr)



library(sf)


test_result_path <- "www/dep_France_DOM.shp"

get_object("kregtt/trav/dep_France_DOM.shp"
           , bucket = Sys.getenv("S3_BUCKET"),region="") %>%
  writeBin(test_result_path)



test_result_path <- "www/dep_France_DOM.shx"

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


test2<-read.csv("www/test2.csv")
comm<-select(comm,-lib,-nom)
test2<-mutate(test2,code=as.character(code))

library(dplyr)
comm<-left_join(comm,test2,by=c("code"="code"))
comm<-mutate(
  comm,
  type=case_when(lib=="MENAGE"~1,
                 lib=="PRIX"~2,
                 lib=="BI RESEAU"~3,
                 T~0)
)

comm[is.na(comm)] <- ""

#pal <- colorNumeric("Greens", domain = comm$type) ## create a color palette
# bins <- c(0, 1, 2, 3, Inf)
# pal <- colorBin("YlOrRd", domain = comm$type, bins = bins)

pal <- colorNumeric(c("#ffffff","red", "green", "blue"), comm$type)

# library(rmapshaper)
# commb <- comm %>% 
#   # Simplifier la géométrie pour une carte plus légère
#   rmapshaper::ms_simplify(keep = 0.01)  

commb <- comm %>%
  sf::st_transform('+proj=longlat +datum=WGS84')

depm <- depm %>%
  sf::st_transform('+proj=longlat +datum=WGS84')

 commune<-read.csv("www/communes-france-2025.csv")

 commune<-filter(commune,reg_code==53)
commune<-select(commune,code_insee,latitude_mairie,longitude_mairie)

commb<-left_join(commb,commune,by=c("code"="code_insee"))
commc<-filter(commb,type!=0)

library(htmltools)

map_regions <- leaflet() %>%
  addTiles() %>% 
  addPolygons(data=depm, weight= 3,col= "black",opacity = 1) %>% 
  addPolygons(
    data = commb,
    label = ~paste0(" ", libelle," ",nom," "),
    popup = ~paste0(" ", libelle," ",nom," "),
    color = "#444444", weight = 0, smoothFactor = 0,
     opacity = 0.7, fillOpacity = 0.3,
     fillColor = ~pal(type),
     highlightOptions = highlightOptions(color = "white", weight = 0,
                                         bringToFront = TRUE))  %>% 
  addLegend(
  title = "type",
  values = commb$type,
  colors = c("#ffffff","red", "green", "blue"),
  labels = c("", "dem", "prix", "bi-réseau"),
  
  ) %>% 
  addMarkers(data=commc,lng=~longitude_mairie, lat=~latitude_mairie, label = ~htmlEscape(nom))
  
  # 
  # addCircleMarkers(data = commc,
  #                lat = ~latitude_mairie, lng = ~longitude_mairie,
  #                popup = ~nom,  # and here's where I replaced 'label' with 'popup'
  #                radius = 10, fillOpacity = 3/4, stroke = FALSE, color = 'steelblue')
  # 





map_regions


library(htmlwidgets)
saveWidget(map_regions, file = "nyc_map11.html")

