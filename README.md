
# 📡 College Weather App

A Flutter app that displays weather data for IITK using a local weather station:

* **Past & Present Data** from the campus weather station [fog-iitk](https://fog.iitk.ac.in/fog-prediction/sensordata.php)
* **Forecast Data** from [Open-Meteo](https://open-meteo.com/)

## 📦 Features

* **Current Weather:** Real-time data from the campus weather balloon (replaced some deprecated sensor data with open-meteo)
* **Hourly Data:** Combined timeline from station (past) & Open-Meteo (forecast)
* **Daily Summary:**

  * Past 2 days (from station)
  * Next 7 days (from Open-Meteo)

## 🛠 Tech Stack

* **Framework:** Flutter (Dart)
* **Data Sources:**

  * Local API for college weather station
  * Open-Meteo API for forecast

## 📁 Data Format

* `hourly.json`: hourly temperature & precipitation
* `daily.json`: min/max temps for past and upcoming days

## 🚀 Getting Started

```bash
flutter pub get
flutter run
```

## Video
<video width="500" controls>
  <source src="https://raw.githubusercontent.com/lumidenoir/fog/main/fog.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>
