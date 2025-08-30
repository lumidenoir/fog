import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyForecastTable extends StatelessWidget {
  final List<dynamic> dailyData;

  const DailyForecastTable({Key? key, required this.dailyData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Day",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Min / Max",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Precip",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table rows
          ...dailyData.map((day) {
            final date = DateTime.parse(day["date"]);
            final formattedDay =
                DateFormat('E d/M').format(date).toUpperCase(); // MON 26/8

            final precip = day["precip_prob"] != null
                ? "${day["precip_prob"]}%"
                : day["total_precip"] != null
                    ? "${day["total_precip"].round()} mm"
                    : "—";

            final isToday =
                date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: isToday
                  ? BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      formattedDay,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${day["min_temp"].round()}° / ${day["max_temp"].round()}°',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      precip,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
