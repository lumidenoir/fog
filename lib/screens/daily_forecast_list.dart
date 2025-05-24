import 'package:flutter/material.dart';

class DailyForecastList extends StatelessWidget {
  final List<dynamic> dailyData;

  const DailyForecastList({Key? key, required this.dailyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dailyData.length,
      itemBuilder: (context, index) {
        final day = dailyData[index];
        return ListTile(
          leading: Icon(Icons.wb_cloudy), // Replace with dynamic weather icon
          title: Text(day["date"]),
          trailing: Text('${day["min"]}° / ${day["max"]}°'),
        );
      },
    );
  }
}
