import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HourlyForecastList extends StatelessWidget {
  final List<dynamic> hourlyData;

  const HourlyForecastList({Key? key, required this.hourlyData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Keep only past 4 hours + all future
    final filteredData = hourlyData.where((hour) {
      final time = DateTime.parse(hour["time"]);
      return time.isAfter(now.subtract(const Duration(hours: 4)));
    }).toList();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filteredData.length,
        itemBuilder: (context, index) {
          final hour = filteredData[index];
          final time = DateTime.parse(hour["time"]);
          final displayTime = DateFormat.j().format(time); // "1 AM", "12 PM"

          // Precip: mm if available, else %
          String precipText;
          if (hour["precipitation"] != null) {
            precipText = '${hour["precipitation"].round()} mm';
          } else if (hour["precip_prob"] != null) {
            precipText = '${hour["precip_prob"]}%';
          } else {
            precipText = '-';
          }

          // Check if this is first item of a new day
          final bool isNewDay = index == 0 ||
              time.day != DateTime.parse(filteredData[index - 1]["time"]).day;

          if (isNewDay) {
            // Show date card instead of hour
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('d').format(time), // Day (25)
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      height: 1,
                      color: Colors.white.withOpacity(0.7), // divider line
                      width: 24,
                    ),
                    Text(
                      DateFormat('MMM').format(time), // Month (Aug)
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          // Check if this hour matches current hour
          final bool isCurrentHour =
              time.hour == now.hour && time.day == now.day;

          // Normal / highlighted hour card
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                color: isCurrentHour
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isCurrentHour
                    ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isCurrentHour ? "Now" : displayTime,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isCurrentHour
                              ? Theme.of(context).colorScheme.surface
                              : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hour["temperature"].round()}°',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isCurrentHour
                              ? Theme.of(context).colorScheme.surface
                              : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    precipText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCurrentHour
                              ? Theme.of(context).colorScheme.surface
                              : null,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
