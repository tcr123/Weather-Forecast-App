library(dplyr)
library(leaflet)

leaflet() %>%
  addProviderTiles(providers$Esri.WorldTerrain)

city_info <- read.csv("weather.csv")

weatherIcons <- iconList(
  Clear= makeIcon(iconUrl="sun.png",iconWidth=20,iconHeight=20),
  Clouds= makeIcon(iconUrl="cloudy.png",iconWidth=20,iconHeight=20),
  Thunderstorm = makeIcon(iconUrl="lightningRain", iconWidth=20, iconHeight = 20),
  Rain= makeIcon(iconUrl="rainy.png", iconWidth=20,iconHeight=20)
)


leaflet() %>%
  addProviderTiles(providers$Esri.WorldTerrain, group = "World Imagery") %>%
  addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
  addLayersControl(baseGroups = c("Toner Lite", "World Imagery")) %>%
  setView(lat = 3.2, lng = 102, zoom = 8) %>%
  setMaxBounds(lng1 = 92, lat1 = -15, lng2 = 122, lat2 = 15) %>%
  addMarkers(data = city_info,
             lng = ~Longitude, 
             lat = ~Latitude,
             icon = ~weatherIcons[city_info$Condition],
             popup = paste(
               "<b>",city_info$City,", ", city_info$Country,"</b>","<br>",
               "<b>Updated: </b>",city_info$DateTime,"<br>",
               "<b>Weather: </b>",city_info$Weather,"<br>",
               "<b>Temperature: </b>",city_info$Temperature, " C","<br>",
               "<b>Wind Speed: </b>",city_info$Wind, " km/h",
               sep=""))

