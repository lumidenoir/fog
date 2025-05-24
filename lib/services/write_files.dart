import 'package:fog_app/models/json_helper.dart';
import 'package:fog_app/services/weather_api.dart';

void main() async {
  try {
    // var data1 = await fetchCurrentData();
    // print("pagescrape: $data1");
    // var data2 = await fetchAQI();
    // print("pagescrape: $data2");
    // await fetchForecastData();
    // await fetchPastData();
    // final forecastData = await fetchHourlyForecastData();
    // print("Hourly Forecast Data:");
    // for (var hour in forecastData['hourly']) {
    //   print(
    //       "${hour['time']} - Temp: ${hour['temperature']}°C, Precipitation: ${hour['precipitation']} mm");
    // }
    // await createOpmJson();
    // await createFogJson();
    await createHourlyJson();
    await createDailyJson();
  } catch (e) {
    print("An error occurred: $e");
  }
}

Future<void> createDailyJson() async {
  try {
    List<Map<String, dynamic>> dailyData = [
      ...await fetchPastData(),
      ...await fetchForecastData(),
    ];
    await writeToFile('daily.json', dailyData);
  } catch (e) {
    print("Error creating daily.json: $e");
  }
}

//For debug purpose
Future<void> createFogJson() async {
  await writeToFile('fog.json', await fetchHourlyPastData());
}

Future<void> createHourlyJson() async {
  try {
    List<Map<String, dynamic>> pastHourlyData = await fetchHourlyPastData();
    List<Map<String, dynamic>> forecastHourlyData =
        await fetchHourlyForecastData();
    // Default to Unix epoch if no data
    DateTime lastPastTimestamp = DateTime(1970, 1, 1);

    if (pastHourlyData.isNotEmpty) {
      lastPastTimestamp = DateTime.parse(pastHourlyData.last['time']);
    }

    List<Map<String, dynamic>> filteredForecastData =
        forecastHourlyData.where((forecast) {
      DateTime forecastTimestamp = DateTime.parse(forecast['time']);
      return forecastTimestamp.isAfter(lastPastTimestamp);
    }).toList();

    List<Map<String, dynamic>> mergedHourlyData = [
      ...pastHourlyData,
      ...filteredForecastData,
    ];

    await writeToFile('hourly.json', mergedHourlyData);
  } catch (e) {
    print("Error creating hourly.json: $e");
  }
}

// For debug purpose
Future<void> createOpmJson() async {
  await writeToFile('opm.json', await fetchHourlyForecastData());
}

Future<void> refresh() async {
  //TODO
}
