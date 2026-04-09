import 'package:flutter/material.dart';
import '../services/weather_api.dart';
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
  Map<String, dynamic>? sunData;
  Map<String, dynamic>? aqiData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Try to load from cache first for instant UI
    final cached = await getCachedWeatherData();
    if (cached != null && mounted) {
      setState(() {
        currentData = cached['currentData'];
        hourlyData = cached['hourlyData'];
        dailyData = cached['dailyData'];
        additionalData = cached['currentData'];
        sunData = cached['sunData'];
        aqiData = cached['aqiData'];
        isLoading = false;
      });
    }
    // Then fetch latest data
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final results = await fetchAllWeatherData();

      if (mounted) {
        setState(() {
          currentData = results['currentData'];
          hourlyData = results['hourlyData'];
          dailyData = results['dailyData'];
          additionalData = results['currentData'];
          sunData = results['sunData'];
          aqiData = results['aqiData'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      if (mounted && currentData == null) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FOG')),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white70),
                  const SizedBox(height: 20),
                  const Text('Updating weather...', style: TextStyle(fontSize: 18, color: Colors.white54)),
                ],
              ),
            )
          : currentData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      const Text("Failed to load weather data.", style: TextStyle(fontSize: 18, color: Colors.white)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchData,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
                        child: const Text("Retry", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                )
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
                      HourlyForecastList(hourlyData: hourlyData ?? []),
                      const SizedBox(height: 20),

                      // Daily Forecast
                      const Text(
                        'Daily',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      DailyForecastTable(dailyData: dailyData ?? []),
                      const SizedBox(height: 20),

                      // Current Conditions
                      const Text(
                        'Current Conditions',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      CurrentConditionsGrid(additionalData: additionalData ?? {}),
                      const Text(
                        'Sun',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (sunData != null)
                        SunCard(
                          startEvent: DateTime.parse(sunData!['startEvent']),
                          endEvent: DateTime.parse(sunData!['endEvent']),
                          progress: (sunData!['progress'] as num).toDouble(),
                          isNight: sunData!['isNight'],
                        )
                      else
                        const Text("Error loading sun data"),
                      const SizedBox(height: 40),
                      const Text(
                        'Air Quality',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (aqiData != null)
                        AQICard(data: aqiData!)
                      else
                        const Text("Error loading AQI data"),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
