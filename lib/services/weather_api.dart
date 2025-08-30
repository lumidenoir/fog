import 'dart:convert'; // For JSON decoding

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String iitkUrl =
    "https://fog.iitk.ac.in/fog-prediction/apis/sensordata3.php";
const String latitude = "26.512345";
const String longitude = "80.233944";

const String aqiUrl = "https://air-quality-api.open-meteo.com/v1/air-quality"
    "?latitude=$latitude&longitude=$longitude&current=us_aqi,dust,uv_index,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide";
const String openMeteoUrl =
    "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude";

Future<Map<String, dynamic>> fetchAQI() async {
  final response = await http.get(Uri.parse(aqiUrl));
  if (response.statusCode != 200) {
    throw Exception('Failed to fetch AQI: HTTP ${response.statusCode}');
  }

  final Map<String, dynamic> json = jsonDecode(response.body);
  final current = json['current'];

  if (current == null) {
    throw Exception("No 'current' block in API response.");
  }

  final String timestamp = current['time'];
  final int aqi = (current['us_aqi'] as num).round();
  final double dust = (current['dust'] as num).toDouble();
  final double uvIndex = (current['uv_index'] as num).toDouble();
  final double carbonMonoxide = (current['carbon_monoxide'] as num).toDouble();
  final double nitrogenDioxide =
      (current['nitrogen_dioxide'] as num).toDouble();
  final double sulphurDioxide = (current['sulphur_dioxide'] as num).toDouble();

  return {
    'time': timestamp,
    'aqi': aqi,
    'uvIndex': uvIndex,
    'carbonMonoxide': carbonMonoxide,
    'nitrogenDioxide': nitrogenDioxide,
    'sulphurDioxide': sulphurDioxide,
    'dust': dust,
  };
}

// deprecated function due to incorrect sensor outputs
Future<Map<String, dynamic>> fetchCampusAQI() async {
  String url = "$iitkUrl?&select=1&interval=1";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      if (data.isNotEmpty) {
        var entry = data[0];

        String timestamp =
            DateTime.fromMillisecondsSinceEpoch((entry[0] as int) * 1000)
                .toIso8601String()
                .substring(0, 16);
        double pm25 = double.parse(entry[9].toStringAsFixed(1));
        double pm10 = double.parse(entry[11].toStringAsFixed(1));

        // Calculate PM10 AQI
        double pm10AQI = pm10 <= 100
            ? pm10
            : pm10 <= 250
                ? 100 + (pm10 - 100) * 100 / 150
                : pm10 <= 350
                    ? 200 + (pm10 - 250)
                    : pm10 <= 430
                        ? 300 + (pm10 - 350) * (100 / 80)
                        : 400 + (pm10 - 430) * (100 / 80);

        // Calculate PM2.5 AQI
        double pm25AQI = pm25 <= 30
            ? pm25 * 50 / 30
            : pm25 <= 60
                ? 50 + (pm25 - 30) * 50 / 30
                : pm25 <= 90
                    ? 100 + (pm25 - 60) * 100 / 30
                    : pm25 <= 120
                        ? 200 + (pm25 - 90) * (100 / 30)
                        : pm25 <= 250
                            ? 300 + (pm25 - 120) * (100 / 130)
                            : 400 + (pm25 - 250) * (100 / 130);

        // Final AQI is the maximum of PM10 AQI and PM2.5 AQI
        double aqi = pm25AQI > pm10AQI ? pm25AQI : pm10AQI;

        return {
          'time': timestamp,
          'aqi': int.parse(aqi.toStringAsFixed(0)),
          'pm2.5': int.parse(pm25.toStringAsFixed(0)),
          'pm10': int.parse(pm10.toStringAsFixed(0))
        };
      } else {
        throw Exception("No data available in API response.");
      }
    } else {
      throw Exception("Failed to fetch data: ${response.statusCode}");
    }
  } catch (e) {
    print("Error in fetchAQI: $e");
    rethrow;
  }
}

// Function to fetch and process data from `sensordata3.php`
// view-source:https://fog.iitk.ac.in/fog-prediction/js/sensordata3.js
Future<Map<String, dynamic>> fetchCurrentData() async {
  String url = "$iitkUrl?select=4&station=IIT%20Kanpur&interval=1";
  String url1 = "$openMeteoUrl&current=apparent_temperature";

  try {
    var response = await http.get(Uri.parse(url));
    var response1 = await http.get(Uri.parse(url1));

    if (response.statusCode == 200 && response1.statusCode == 200) {
      String rawData = response.body;

      Map<String, dynamic> data = jsonDecode(response1.body);
      int appTemperature =
          (data["current"]["apparent_temperature"] as num).round();

      // fetch weather condition from open-meteo
      String weatherCondition = await fetchWeatherCode(current: true);

      // Split and process the response parts
      if (rawData.split(';').length < 2) {
        throw Exception("Invalid data structure from API.");
      }

      // Decode the parts
      List<dynamic> weatherData = jsonDecode(rawData.split(';')[1]);

      if (weatherData.isEmpty || weatherData[0].length < 11) {
        throw Exception("Missing or incomplete data from API.");
      }

      // Return map
      return {
        'date': weatherData[0][0],
        'date_txt': DateFormat('yyyy-MM-dd HH:mm').format(
            DateTime.fromMillisecondsSinceEpoch(weatherData[0][0] * 1000)),
        'temperature': ((weatherData[0][2] + weatherData[0][3]) / 2).round(),
        'rainfall': weatherData[0][4],
        'humidity': (weatherData[0][5] + weatherData[0][6]) / 2,
        'windSpeed': weatherData[0][7],
        'windDirection': weatherData[0][8],
        'sunshine': weatherData[0][9],
        'pressure': weatherData[0][10],
        'appTemperature': appTemperature,
        'weatherCondition': weatherCondition,
      };
    } else {
      throw Exception("Failed to fetch data: ${response.statusCode}");
    }
  } catch (e) {
    print("Error in fetchCurrentData: $e");
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> fetchForecastData() async {
  final url =
      "$openMeteoUrl&daily=temperature_2m_min,temperature_2m_max,precipitation_probability_max&timezone=auto";

  try {
    // Fetch data from the API
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> dates = data['daily']['time'];
      List<dynamic> minTemps = data['daily']['temperature_2m_min'];
      List<dynamic> maxTemps = data['daily']['temperature_2m_max'];
      List<dynamic> preciProbMax =
          data['daily']['precipitation_probability_max'];

      // Convert the data to the desired format
      List<Map<String, dynamic>> forecastData = [];
      for (int i = 0; i < dates.length; i++) {
        String timestamp =
            DateTime.parse(dates[i]).toIso8601String().split('T')[0];

        forecastData.add({
          "date": timestamp,
          "min_temp": minTemps[i],
          "max_temp": maxTemps[i],
          "precip_prob": preciProbMax[i],
        });
      }

      return forecastData;
    } else {
      throw Exception("Failed to fetch weather data: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
    return [];
  }
}

Future<List<Map<String, dynamic>>> fetchHourlyForecastData() async {
  final String url =
      '$openMeteoUrl&hourly=temperature_2m,precipitation_probability&timezone=auto&forecast_days=2';

  try {
    // Make the API request
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the response body
      final data = jsonDecode(response.body);

      // Extract hourly temperature and precipitation data
      final List<String> times = List<String>.from(data['hourly']['time']);
      final List<double> temperatures =
          List<double>.from(data['hourly']['temperature_2m']);
      final List<int> precipitationProbability =
          List<int>.from(data['hourly']['precipitation_probability']);

      // Combine data into a structured format
      List<Map<String, dynamic>> hourlyData = [];
      for (int i = 0; i < times.length; i++) {
        hourlyData.add({
          'time': times[i],
          'temperature': temperatures[i],
          'precip_prob': precipitationProbability[i],
        });
      }

      // Return the formatted hourly data
      return hourlyData;
    } else {
      throw Exception('Failed to fetch forecast data: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching hourly forecast data: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchHourlyPastData() async {
  String todayDate = DateTime.now().toIso8601String().split('T')[0];
  String url = "$iitkUrl?select=4&start_date=$todayDate&end_date=$todayDate";

  try {
    // Fetch IITK data (temperature)
    var response = await http.get(Uri.parse(url));

    // Fetch Open-Meteo hourly precipitation
    String urlOpenMeteo =
        "$openMeteoUrl&hourly=precipitation&timezone=auto&start_date=$todayDate&end_date=$todayDate";
    var responseOpenMeteo = await http.get(Uri.parse(urlOpenMeteo));

    if (response.statusCode == 200 && responseOpenMeteo.statusCode == 200) {
      String rawData = response.body;

      if (rawData.split(';').length < 2) {
        throw Exception("Invalid data structure from IITK API.");
      }

      List<dynamic> weatherData = jsonDecode(rawData.split(';')[1]);
      var meteoData = jsonDecode(responseOpenMeteo.body);

      // Extract Open-Meteo time & precipitation
      List<String> meteoTimes =
          (meteoData["hourly"]["time"] as List<dynamic>).cast<String>();
      List<double> meteoPrecip =
          (meteoData["hourly"]["precipitation"] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList();

      // Build a lookup map for Open-Meteo
      Map<String, double> precipMap = {};
      for (int i = 0; i < meteoTimes.length; i++) {
        precipMap[meteoTimes[i].substring(0, 16)] = meteoPrecip[i];
      }

      List<Map<String, dynamic>> mergedData = [];
      for (int i = 0; i < weatherData.length; i += 2) {
        if (i + 1 >= weatherData.length) break;

        double avgTempOdd = (weatherData[i][2] + weatherData[i][3]) / 2;
        double avgTempEven =
            (weatherData[i + 1][2] + weatherData[i + 1][3]) / 2;
        double combinedAvgTemp = (avgTempOdd + avgTempEven) / 2;

        String timestamp = DateTime.fromMillisecondsSinceEpoch(
                (weatherData[i][0] as int) * 1000)
            .toIso8601String()
            .substring(0, 16);

        double combinedPrecipitation = 0.0;
        if (precipMap.containsKey(timestamp)) {
          double val1 = precipMap[timestamp] ?? 0.0;
          double val2 = precipMap[DateTime.parse(timestamp)
                  .add(Duration(minutes: 30))
                  .toIso8601String()
                  .substring(0, 16)] ??
              0.0;
          combinedPrecipitation = val1 + val2;
        }

        mergedData.add({
          "time": timestamp,
          "temperature": (combinedAvgTemp * 10).roundToDouble() / 10,
          "precipitation": (combinedPrecipitation * 10).roundToDouble() / 10,
        });
      }

      return mergedData;
    } else {
      throw Exception(
          "Failed to fetch data: ${response.statusCode}, ${responseOpenMeteo.statusCode}");
    }
  } catch (e) {
    print("Error fetching hourly past data: $e");
    return [];
  }
}

Future<List<Map<String, dynamic>>> fetchPastData() async {
  // Get yesterday and the day before
  DateTime now = DateTime.now();
  String yesterday =
      now.subtract(Duration(days: 1)).toIso8601String().split('T')[0];
  String dayBeforeYesterday =
      now.subtract(Duration(days: 2)).toIso8601String().split('T')[0];

  // API URLs
  String urlYesterday =
      "$iitkUrl?select=4&start_date=$yesterday&end_date=$yesterday";
  String urlDayBefore =
      "$iitkUrl?select=4&start_date=$dayBeforeYesterday&end_date=$dayBeforeYesterday";

  // Helper function to process API data
  Future<Map<String, dynamic>> processApiData(String url, String date) async {
    try {
      // IITK data (for temperature)
      var response = await http.get(Uri.parse(url));

      // Open-Meteo for precipitation
      String urlOpenMeteo =
          "$openMeteoUrl&daily=precipitation_sum&timezone=auto&start_date=$date&end_date=$date";
      var responseOpenMeteo = await http.get(Uri.parse(urlOpenMeteo));

      if (response.statusCode == 200 && responseOpenMeteo.statusCode == 200) {
        String rawData = response.body;

        if (rawData.split(';').length < 2) {
          throw Exception("Invalid data structure from IITK API.");
        }

        List<dynamic> weatherData = jsonDecode(rawData.split(';')[1]);

        // Compute average temperatures
        List<double> avgTemperatures = [];
        for (var dataPoint in weatherData) {
          double maxTemp = dataPoint[2].toDouble();
          double minTemp = dataPoint[3].toDouble();
          avgTemperatures.add((maxTemp + minTemp) / 2);
        }

        // Calculate max & min temperatures
        double maxTemperature = avgTemperatures.reduce((a, b) => a > b ? a : b);
        double minTemperature = avgTemperatures.reduce((a, b) => a < b ? a : b);

        // --- old precipitation ---
        // List<double> precipitations = [];
        // for (var dataPoint in weatherData) {
        //   double precip = dataPoint[4].toDouble();
        //   precipitations.add(precip);
        // }
        // double totalPrecipitation =
        //     precipitations.reduce((a, b) => a + b);

        var meteoData = jsonDecode(responseOpenMeteo.body);
        double totalPrecipitation =
            (meteoData["daily"]["precipitation_sum"][0] as num).toDouble();

        return {
          "date": date,
          "min_temp": (minTemperature * 10).roundToDouble() / 10,
          "max_temp": (maxTemperature * 10).roundToDouble() / 10,
          "total_precip": (totalPrecipitation * 10).roundToDouble() / 10,
        };
      } else {
        throw Exception(
            "Failed to fetch data: ${response.statusCode}, ${responseOpenMeteo.statusCode}");
      }
    } catch (e) {
      print("Error processing data for $date: $e");
      return {};
    }
  }

  try {
    // Fetch and process data for both days
    Map<String, dynamic> yesterdayData =
        await processApiData(urlYesterday, yesterday);
    Map<String, dynamic> dayBeforeYesterdayData =
        await processApiData(urlDayBefore, dayBeforeYesterday);

    return [dayBeforeYesterdayData, yesterdayData];
  } catch (e) {
    print("Error fetching past data: $e");
    return [];
  }
}

Future<Map<String, dynamic>> fetchSunPosition() async {
  final url = "$openMeteoUrl&daily=sunrise,sunset&timezone=auto";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    final sunriseStr = data["daily"]["sunrise"][0];
    final sunsetStr = data["daily"]["sunset"][0];

    final sunrise = DateTime.parse(sunriseStr);
    final sunset = DateTime.parse(sunsetStr);
    final now = DateTime.now();

    double progress = 0;
    if (now.isAfter(sunrise) && now.isBefore(sunset)) {
      final totalDay = sunset.difference(sunrise).inSeconds;
      final elapsed = now.difference(sunrise).inSeconds;
      progress = elapsed / totalDay;
    } else if (now.isAfter(sunset)) {
      progress = 1.0;
    }

    return {
      "sunrise": sunrise,
      "sunset": sunset,
      "progress": progress.clamp(0.0, 1.0),
      // "progress": 0.3,
    };
  } else {
    throw Exception("Failed to fetch sun data");
  }
}

Future<String> fetchWeatherCode({bool current = true}) async {
  final String endpoint =
      current ? 'current=weather_code' : 'daily=weather_code&forecast_days=1';
  final String url = "$openMeteoUrl&$endpoint&timezone=auto";
  try {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      int code = current
          ? data['current']['weather_code']
          : data['daily']['weather_code'][0];
      return getWeatherCondition(code);
    } else {
      throw Exception("Failed to fetch weather data: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Error fetching weather code: $e");
  }
}

String getWeatherCondition(int code) {
  if (code == 0) {
    return "Clear";
  } else if (code == 1 || code == 2 || code == 3) {
    return "Partly cloudy";
  } else if (code == 45 || code == 48) {
    return "Fog";
  } else if (code == 51 || code == 53 || code == 55) {
    return "Drizzle";
  } else if (code == 56 || code == 57) {
    return "Freezing drizzle";
  } else if (code == 61 || code == 63 || code == 65) {
    return "Rain";
  } else if (code == 66 || code == 67) {
    return "Freezing rain";
  } else if (code == 71 || code == 73 || code == 75) {
    return "Snowfall";
  } else if (code == 77) {
    return "Snow grains";
  } else if (code == 80 || code == 81 || code == 82) {
    return "Rain showers";
  } else if (code == 85 || code == 86) {
    return "Snow showers";
  } else if (code == 95) {
    return "Thunderstorm";
  } else if (code == 96 || code == 99) {
    return "Thunderstorm with hail";
  } else {
    return "Unknown condition";
  }
}
