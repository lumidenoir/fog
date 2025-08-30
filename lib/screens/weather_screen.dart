import 'package:flutter/material.dart';
import '../services/weather_api.dart';
import '../models/json_helper.dart';
import 'current_weather_card.dart';
import 'hourly_forecast_list.dart';
import 'daily_forecast_list.dart';
import 'current_conditions_grid.dart';
import 'sun_card.dart';
import 'aqi_card.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, dynamic>? currentData;
  List<dynamic>? hourlyData;
  List<dynamic>? dailyData;
  Map<String, dynamic>? additionalData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final fetchedCurrentData = await fetchCurrentData();
      final fetchedHourlyData = await readJsonFile('hourly.json');
      final fetchedDailyData = await readJsonFile('daily.json');

      setState(() {
        currentData = fetchedCurrentData;
        hourlyData = fetchedHourlyData;
        dailyData = fetchedDailyData;
        additionalData = fetchedCurrentData;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FOG')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Weather
                      CurrentWeatherCard(currentData: currentData!),
                      const SizedBox(height: 20),

                      // Hourly Forecast
                      const Text(
                        'Hourly',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      HourlyForecastList(hourlyData: hourlyData!),
                      const SizedBox(height: 20),

                      // Daily Forecast
                      const Text(
                        'Daily',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      DailyForecastTable(dailyData: dailyData!),
                      const SizedBox(height: 20),

                      // Current Conditions
                      const Text(
                        'Current Conditions',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      CurrentConditionsGrid(additionalData: additionalData!),
                      const Text(
                        'Sun',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      FutureBuilder<Map<String, dynamic>>(
                        future: fetchSunPosition(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Text("Error loading sun data");
                          } else if (snapshot.hasData) {
                            final data = snapshot.data!;
                            return SunCard(
                              sunrise: data['sunrise'],
                              sunset: data['sunset'],
                              progress: data['progress'],
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Air Quality',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      FutureBuilder<Map<String, dynamic>>(
                        future: fetchAQI(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Text("Error loading AQI data");
                          } else if (snapshot.hasData) {
                            return AQICard(data: snapshot.data!);
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
