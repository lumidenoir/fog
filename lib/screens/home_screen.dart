import 'package:flutter/material.dart';
import 'weather_screen.dart';
import '../services/weather_api.dart';
import '../models/json_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      // Fetch data asynchronously
      final fetchedCurrentData = await fetchCurrentData();
      final fetchedHourlyData = await readJsonFile('hourly.json');
      final fetchedDailyData = await readJsonFile('daily.json');
      final fetchedAdditionalData = {
        "wind_speed": 10,
        "wind_direction": "NW",
        "humidity": 60,
        "pressure": 1012,
      };

      // Update state to reflect new data
      setState(() {
        currentData = fetchedCurrentData;
        hourlyData = fetchedHourlyData;
        dailyData = fetchedDailyData;
        additionalData = fetchedAdditionalData;
        isLoading = false;
      });

      // Navigate to WeatherScreen with the fetched data
      if (currentData != null && hourlyData != null && dailyData != null && additionalData != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherScreen(
              currentData: currentData!,
              hourlyData: hourlyData!,
              dailyData: dailyData!,
              additionalData: additionalData!,
            ),
          ),
        );
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false; // Ensure loading ends even if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ElevatedButton(
                onPressed: fetchData,
                child: const Text('Load Weather Data'),
              ),
            ),
    );
  }
}
