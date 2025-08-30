import 'package:flutter/material.dart';

class CurrentWeatherCard extends StatelessWidget {
  final Map<String, dynamic> currentData;

  const CurrentWeatherCard({Key? key, required this.currentData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Current temperature big
          Expanded(
            child: Text(
              '${currentData["temperature"]}°',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),

          // Vertical divider
          Container(
            width: 1,
            height: 60,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),

          // Right side: app temp (top) + metric (bottom)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Feels like ${currentData["appTemperature"]}°',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${currentData["weatherCondition"]}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
