# Loading packages
library(shiny)
library(leaflet)
library(dplyr)
library(shinyWidgets)
library(ggplot2)
library(tidyverse)
library(hrbrthemes)
library(scales)
library(bslib)
library(owmr)
library("readxl")
library(DT)

# UI

city = read_excel("city.xlsx")
city_info = read.csv("weather.csv")

ui <- navbarPage("Weather Forecast App",
   theme = bs_theme(bg = "#e3eef8", fg = "#13314c",primary = "#f8e3e4",base_font = font_google("Nunito")),
   
   tabPanel("About",
            
            # Input values
            
            fluidRow(
              column(3),
              column(6,
                     shiny::HTML("<br><br><center> <h1>Weather Forecast App</h1> </center><br>"),
                     shiny::HTML("<h5>This is a real-time weather forecast app that outputs the current weather, temperature and wind speed of the district selected. It also displays the weekly temperature, pressure and humidity of the district selected in the next few tabs. The data in this app will be updated hourly in accordance with the current weather. </h5>")
              ),
              column(3)
            ),
            
            fluidRow(
              column(3),
              column(6,
                     shiny::HTML("<br><br><center> <h1>How to use our app?</h1> </center><br>"),
                     shiny::HTML("<h5>1.	Click the select panel and select your desired district.<br> 
2.	A weather icon of the district selected will appear.<br> 
3.	Move your mouse cursor to the weather icon and click on it.<br>
4.	The details of the current weather, temperature and wind speed of the district selected will be displayed.
</h5>")
              ),
              column(3)
            ),
            
            
            fluidRow(
              column(3),
              column(6,
                     shiny::HTML("<br><br><center> <h1>The Tabs </h1> </center><br>"),
                     shiny::HTML("<h5><strong>Interactive Map:</strong> This tab displays a world map along with the current weather, temperature, and wind speed of the districts in Malaysia.<br> 
<strong>Weather Data:</strong> This tab displays the table of the weekly weather of the district selected.<br>
<strong>Weekly Temperature:</strong> This tab displays the graph of the weekly temperature of the district selected.<br>
<strong>Weekly Pressure:</strong> This tab displays the graph of the weekly pressure of the district selected.<br>
<strong>Weekly Humidity:</strong> This tab displays the graph of the weekly humidity of the district selected.<br>
 </h5>")
              ),
              column(3)
            ),
            
            
            fluidRow(
              
              style = "height:50px;")
            
   ), 

   tabPanel("Interactive Map", leafletOutput(outputId = "map", width = 850, height = 500),
      absolutePanel(top=80, right= 20, width = 300,
          pickerInput(
            inputId = "cities",
            label = "Select a city",
            choices = c("All Cities", city$City)),
            shiny::HTML("<right><h5>Click the select panel and select your desired district.  
            A weather icon of the district selected will appear. Move your mouse cursor to the 
            weather icon and click on it to display the details of the current weather, temperature 
            and wind speed of the district selected. 
            </h5></right>") 
      )
   ),
   
   tabPanel("Weather Data", dataTableOutput(outputId = "table", width = 850, height = 500),
            absolutePanel(top=80, right= 20, width = 300,
              pickerInput(
                inputId = "citiesTable",
                label = "Select a city",
                choices = c(city$City)),
                shiny::HTML("<right><h5>Click the select panel and select your desired district.  
                weekly weather data of the district selected will be displayed upon 
                clicking the desired district.</h5></right>") 
            )
   ),
   
   tabPanel("Weekly Temperature",
      plotOutput("graph1", width = 850, height = 500),
      absolutePanel(top=80, right= 20, width = 300,
            pickerInput(
              inputId = "citiesTemperature",
              label = "Select a city",
              choices = c(city$City)),
              shiny::HTML("<right><h5>Click the select panel and select your desired district. 
              A graph on the weekly temperature of the district selected will be displayed upon 
              clicking the desired district.  
              </h5></right>")   
      )
   ),
   
   tabPanel("Weekly Pressure",
      plotOutput("graph2", width = 850, height = 500),
      absolutePanel(top=80, right= 20, width = 300,
            pickerInput(
              inputId = "citiesPressure",
              label = "Select a city",
              choices = c(city$City)),
              shiny::HTML("<right><h5>Click the select panel and select your desired district. 
              A graph on the weekly temperature of the district selected will be displayed upon 
              clicking the desired district.  
              </h5></right>")   
      )
        
   ),
   
   tabPanel("Weekly Humidity",
      plotOutput("graph3", width = 850, height = 500),
      absolutePanel(top=80, right= 20, width = 300,
            pickerInput(
              inputId = "citiesHumidity",
              label = "Select a city",
              choices = c(city$City)),
              shiny::HTML("<right><h5>Click the select panel and select your desired district. 
              A graph on the weekly humidity of the district selected will be displayed upon 
              clicking the desired district.   
              </h5></right>")
      )
   )
)

#server
server <- function(input, output, session) {
  owmr_settings("32ca7af3c42c866e1e969582df5dca5e")
  
  weatherIcons <- iconList(
    Clear= makeIcon(iconUrl="sun.png",iconWidth=20,iconHeight=20),
    Clouds= makeIcon(iconUrl="cloudy.png",iconWidth=20,iconHeight=20),
    Thunderstorm = makeIcon(iconUrl="lightningRain.png", iconWidth=20, iconHeight = 20),
    Rain= makeIcon(iconUrl="rainy.png", iconWidth=20,iconHeight=20)
  )
  
  #filter data for map
  filteredData <- reactive({
    if (input$cities == "All Cities") {
      for (i in 1:27) {
        info = get_current(city$City[i], units = "metric")
        city_info$Condition[i] = info$weather$main
        city_info$Weather[i] = info$weather$description
        city_info$Temperature[i] = info$main$temp
        city_info$Wind[i] = info$wind$speed
      }
      city_info
    } else {
      info <- filter(city_info, city_info$City == input$cities)
      new_info = get_current(input$cities, units = "metric")
      info$Condition = new_info$weather$main
      info$Weather = new_info$weather$description
      info$Temperature = new_info$main$temp
      info$Wind = new_info$wind$speed
      info
    }
  })
  
  #draw map for selected district
  output$map <- renderLeaflet({
    leaflet(filteredData()) %>%
      addProviderTiles(providers$Esri.WorldTerrain, group = "World Imagery") %>%
      addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
      addLayersControl(baseGroups = c("Toner Lite", "World Imagery")) %>%
      setView(lat = 3.2, lng = 102, zoom = 8) %>%
      setMaxBounds(lng1 = 92, lat1 = -15, lng2 = 122, lat2 = 15) %>%
      addMarkers(lng = ~Longitude, 
                 lat = ~Latitude,
                 icon = ~weatherIcons[Condition],
                 popup = paste(
                   "<b>",filteredData()$City,", ", filteredData()$Country,"</b>","<br>",
                   "<b>Weather: </b>",filteredData()$Weather ,"<br>",
                   "<b>Temperature: </b>",filteredData()$Temperature, " C","<br>",
                   "<b>Wind Speed: </b>",filteredData()$Wind, " km/h",
                   sep=""))
  })
  
  #update map when district selected
  observe({
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
      setView(lat = filteredData()$Latitude, lng = filteredData()$Longitude, zoom = 8) %>%
      addMarkers(lng = ~Longitude, 
                 lat = ~Latitude,
                 icon = ~weatherIcons[Condition],
                 popup = paste(
                   "<b>",filteredData()$City,", ", filteredData()$Country,"</b>","<br>",
                   "<b>Weather: </b>",filteredData()$Weather ,"<br>",
                   "<b>Temperature: </b>",filteredData()$Temperature, " C","<br>",
                   "<b>Wind Speed: </b>",filteredData()$Wind, " km/h",
                   sep=""))
  })
  
  #filter weekly weather data
  filteredTableData <- reactive({
    forecast <- get_forecast(input$citiesTable, units = "metric") %>% owmr_as_tibble()
    forecast <- data.frame("Date" = forecast['dt_txt'], "Condition" = forecast['weather_main'],
                           "Weather" = forecast['weather_description'], "Wind Speed" = forecast['wind_speed'])
    forecast
  })
  
  output$table <- renderDataTable({
    DT::datatable(filteredTableData())
  })
  
  #filter temperature
  filteredTemperatureData <- reactive({
    forecast <- get_forecast(input$citiesTemperature, units = "metric") %>%
      owmr_as_tibble()
  })
  
  #Temperature
  output$graph1 <-renderPlot({
    ggplot(data = filteredTemperatureData(), aes(x=dt_txt,y=temp,group=1))+ 
      theme(axis.text.x = element_text(angle = 90,size=10))+labs(x="Date",y="Temperature")+
      geom_line(color="blue",size =2)+scale_y_continuous(limits = c(20,45))+
      ggtitle("Weekly Temperature in",paste(input$citiesTemperature))
  })
  
  #filter Pressure
  filteredPressureData <- reactive({
    forecast <- get_forecast(input$citiesPressure, units = "metric") %>%
      owmr_as_tibble()
  })
  
  #Pressure
  output$graph2 <-renderPlot({
    ggplot(data = filteredPressureData(), aes(x=dt_txt,y=pressure,group=1,fill=weather_description))+ 
      theme(axis.text.x = element_text(angle = 90,size=10))+labs(x="Date",y="Pressure")+
      geom_line(color="red",size=2)+scale_y_continuous(limits = c(1000,1015))+
      ggtitle("Weekly Pressure in",paste(input$citiesPressure))
  })
  
  #filter humidity
  filteredHuminityData <- reactive({
    forecast <- get_forecast(input$citiesHumidity, units = "metric") %>%
      owmr_as_tibble()
  })
  
  #Humidity
  output$graph3 <-renderPlot({
    ggplot(data = filteredHuminityData(), aes(x=dt_txt,y=humidity,group=1))+ 
      theme(axis.text.x = element_text(angle = 90,size=10))+labs(x="Date",y="Humidity")+
      geom_line(color="purple",size =2)+scale_y_continuous(limits = c(20,120))+ggtitle("Weekly Humidity in",paste(input$citiesHumidity))
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server= server)