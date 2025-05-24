import 'package:flutter/material.dart';

class CurrentConditionsGrid extends StatelessWidget {
  final Map<String, dynamic> additionalData;

  const CurrentConditionsGrid({Key? key, required this.additionalData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      children: [
        _buildConditionTile('Wind', '${additionalData["wind_speed"]} km/h'),
        _buildConditionTile('Direction', additionalData["wind_direction"]),
        _buildConditionTile('Humidity', '${additionalData["humidity"]}%'),
        _buildConditionTile('Pressure', '${additionalData["pressure"]} hPa'),
      ],
    );
  }

  Widget _buildConditionTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
