import 'package:flutter/material.dart';

class CurrentWeatherCard extends StatelessWidget {
  final Map<String, dynamic> currentData;

  const CurrentWeatherCard({Key? key, required this.currentData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${currentData["temperature"]}°',
          style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
        ),
        Text(
          '${currentData["temperature"]}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
