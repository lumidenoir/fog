
# 📡 College Weather App

A Flutter app that displays weather data for your college using:

* **Past & Present Data** from the college's weather station
* **Forecast Data** from [Open-Meteo](https://open-meteo.com/)

## 📦 Features

* **Current Weather:** Real-time data from the campus weather balloon
* **Hourly Data:** Combined timeline from station (past) & Open-Meteo (forecast)
* **Daily Summary:**

  * Past 3 days (from station)
  * Next 3 days (from Open-Meteo)

## 🛠 Tech Stack

* **Framework:** Flutter (Dart)
* **Data Sources:**

  * Local API for college weather station
  * Open-Meteo API for forecast

## 📁 Data Format

* `present.json`: current weather data (temp, humidity, wind, etc.)
* `hourly.json`: hourly temperature & precipitation
* `daily.json`: min/max temps for past and upcoming days

## 🚀 Getting Started

```bash
flutter pub get
flutter run
```

## 🔧 Customization

* Update API endpoints in your service files
* JSON parsers are in `lib/models/`

