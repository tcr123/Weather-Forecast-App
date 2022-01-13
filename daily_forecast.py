import requests
import pandas as pd

weather = 'http://api.openweathermap.org/data/2.5/forecast'
params = {'q': 'Kuala Lumpur',
          'APPID': '32ca7af3c42c866e1e969582df5dca5e',
          'cnt': '40',
          'units': 'metric'}

# Sending the request to OWM using our function
response = requests.get(weather, params)

print(response.status_code)

city_info = response.json()

print(city_info)

# Extracting information from response

kl_weather = []

for i in range(40):
    date = city_info['list'][i]['dt_txt']
    weather_condition = city_info['list'][i]['weather'][0]['description']
    temperature = city_info['list'][i]['main']['feels_like']
    pressure = city_info['list'][i]['main']['pressure']
    humidity = city_info['list'][i]['main']['humidity']
    max_temp = city_info['list'][i]['main']['temp_max']
    min_temp = city_info['list'][i]['main']['temp_min']

    # For each city, compile data in a dictionary
    weather_data = {'City': 'Kuala Lumpur',
                    'Date': date,
                    'Weather': weather_condition,
                    'Temperature': temperature,
                    'Pressure': pressure,
                    'Huminity': humidity,
                    'Temperature Max (C)': max_temp,
                    'Temperature Min (C)': min_temp}

    kl_weather.append(weather_data)

df = pd.DataFrame(data=kl_weather, columns=weather_data.keys())

df.to_csv('C:/Users/chunrong/Documents/weather_kl.csv')
