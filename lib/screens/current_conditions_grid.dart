import 'package:flutter/material.dart';
import 'dart:math' as math;

class CurrentConditionsGrid extends StatelessWidget {
  final Map<String, dynamic> additionalData;

  const CurrentConditionsGrid({Key? key, required this.additionalData})
      : super(key: key);

  String _getCompassLabel(double degrees) {
    const directions = [
      "N",
      "NE",
      "E",
      "SE",
      "S",
      "SW",
      "W",
      "NW",
    ];
    int index = ((degrees % 360) / 45).round() % 8;
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    final windSpeed = (additionalData["windSpeed"]*18/5)?.round() ?? 0;
    final windDir = (additionalData["windDirection"] ?? 0).toDouble();
    final compass = _getCompassLabel(windDir);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2,
      children: [
        _buildWindTile(windSpeed, windDir, compass),
        _buildConditionTile(
            'Sunshine', '${additionalData["sunshine"].round()} W/m²'),
        _buildConditionTile(
            'Humidity', '${additionalData["humidity"].round()}%'),
        _buildConditionTile(
            'Pressure', '${additionalData["pressure"].round()} hPa'),
      ],
    );
  }

Widget _buildWindTile(int speed, double direction, String compass) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$speed kmph",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: (direction) * math.pi / 180,
                child: const Icon(Icons.arrow_upward, size: 20),
              ),
              const SizedBox(width: 6),
              Text(
                compass,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildConditionTile(String title, String value) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    ),
  );
}
}
