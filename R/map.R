library(dplyr)
library(leaflet)

leaflet() %>%
  addProviderTiles(providers$Esri.WorldTerrain)

city_info <- read.csv("weather.csv")

weatherIcons <- iconList(
  Clear= makeIcon(iconUrl="ImageWeather.png",iconWidth=20,iconHeight=20),
  Clear= makeIcon(iconUrl="ImageWeather.png",iconWidth=20,iconHeight=20),
  Rainy= makeIcon(iconUrl="ImageWeather.png", iconWidth=20,iconHeight=20)
)

weatherIcons

leaflet() %>%
  addProviderTiles(providers$Esri.WorldTerrain, group = "World Imagery") %>%
  addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
  addLayersControl(baseGroups = c("Toner Lite", "World Imagery")) %>%
  setView(lat = 3.2, lng = 102, zoom = 8) %>%
  setMaxBounds(lng1 = 92, lat1 = -15, lng2 = 122, lat2 = 15) %>%
  addMarkers(data = city_info,
             lng = ~Longitude, 
             lat = ~Latitude)

