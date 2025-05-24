import 'package:flutter/material.dart';

class HourlyForecastList extends StatelessWidget {
  final List<dynamic> hourlyData;

  const HourlyForecastList({Key? key, required this.hourlyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourlyData.length,
        itemBuilder: (context, index) {
          final hour = hourlyData[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('${hour["time"]}'),
                Icon(Icons.wb_sunny), // Replace with dynamic weather icon
                Text('${hour["temperature"]}°'),
              ],
            ),
          );
        },
      ),
    );
  }
}
