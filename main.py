import requests
import pandas as pd

from bs4 import BeautifulSoup
world_cities = requests.get('https://worldpopulationreview.com/world-cities/')
cities = BeautifulSoup(world_cities.text,'lxml')

city_list = pd.read_excel('C:/Users/chunrong/Documents/city.xlsx')
city_names = city_list['City']

world_temperatures = []
for i in range(49):
    # Extracting the city name and assigning it to 'q'

    weather = 'http://api.openweathermap.org/data/2.5/weather'
    params = {'q': city_names[i]+', my',
              'APPID': '32ca7af3c42c866e1e969582df5dca5e',
              'units': 'metric'}
    # Sending the request to OWM using our function
    response = requests.get(weather, params)

    print(response.status_code)

    if response.status_code != 200:
        continue

    city_info = response.json()

    # Extracting information from response
    country = city_info['sys']['country']
    latitude = city_info['coord']['lat']
    longitude = city_info['coord']['lon']
    weather_condition = city_info['weather'][0]['description']
    temperature = city_info['main']['feels_like']
    max_temp = city_info['main']['temp_max']
    min_temp = city_info['main']['temp_min']

    # For each city, compile data in a dictionary
    city_data = {'City': city_names[i],
                 'Country': country,
                 'Latitude': latitude,
                 'Longitude': longitude,
                 'Weather': weather_condition,
                 'Temperature': temperature,
                 'Temperature Max (C)': max_temp,
                 'Temperature Min (C)': min_temp}

    # Append each city's info to the list
    world_temperatures.append(city_data)

df = pd.DataFrame(data=world_temperatures, columns=city_data.keys())

df.to_csv('C:/Users/chunrong/Documents/weather.csv')
