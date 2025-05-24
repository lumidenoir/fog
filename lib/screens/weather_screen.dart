import 'package:flutter/material.dart';
import 'current_weather_card.dart';
import 'hourly_forecast_list.dart';
import 'daily_forecast_list.dart';
import 'current_conditions_grid.dart';

class WeatherScreen extends StatelessWidget {
  final Map<String, dynamic> currentData;
  final List<dynamic> hourlyData;
  final List<dynamic> dailyData;
  final Map<String, dynamic> additionalData;

  const WeatherScreen({
    super.key,
    required this.currentData,
    required this.hourlyData,
    required this.dailyData,
    required this.additionalData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Weather
              CurrentWeatherCard(currentData: currentData),
              const SizedBox(height: 20),

              // Hourly Forecast
              const Text(
                'Hourly Forecast',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              HourlyForecastList(hourlyData: hourlyData),
              const SizedBox(height: 20),

              // Daily Forecast
              const Text(
                'Daily Forecast',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DailyForecastList(dailyData: dailyData),
              const SizedBox(height: 20),

              // Current Conditions
              const Text(
                'Current Conditions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              CurrentConditionsGrid(additionalData: additionalData),
            ],
          ),
        ),
      ),
    );
  }
}
