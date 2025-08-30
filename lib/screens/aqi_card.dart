import 'package:flutter/material.dart';

class AQICard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AQICard({Key? key, required this.data}) : super(key: key);

  Color _aqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade500;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }

  String _aqiLabel(int aqi) {
    if (aqi <= 50) return "Good";
    if (aqi <= 100) return "Moderate";
    if (aqi <= 150) return "Unhealthy (SG)";
    if (aqi <= 200) return "Unhealthy";
    if (aqi <= 300) return "Very Unhealthy";
    return "Hazardous";
  }

  Color _uvColor(double uv) {
    if (uv <= 2) return Colors.green;
    if (uv <= 5) return Colors.yellow.shade500;
    if (uv <= 7) return Colors.orange;
    if (uv <= 10) return Colors.red;
    return Colors.purple;
  }

  String _uvLabel(double uv) {
    if (uv <= 2) return "Low";
    if (uv <= 5) return "Moderate";
    if (uv <= 7) return "High";
    if (uv <= 10) return "Very High";
    return "Extreme";
  }

  @override
  Widget build(BuildContext context) {
    final int aqi = data['aqi'];
    final String aqiLabel = _aqiLabel(aqi);

    final double uv = data['uvIndex'];
    final String uvLabel = _uvLabel(uv);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // AQI + UV row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // AQI
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("AQI"),
                    Row(
                      children: [
                        Text(
                          "$aqi",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _aqiColor(aqi),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          aqiLabel,
                          style: TextStyle(
                            fontSize: 16,
                            color: _aqiColor(aqi),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // UV Index
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("UV Index"),
                    Row(
                      children: [
                        Text(
                          uv.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _uvColor(uv),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          uvLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _uvColor(uv),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Other pollutants row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _pollutantTile(
                  "Dust",
                  "${data['dust'].toStringAsFixed(1)} µg/m³",
                ),
                _pollutantTile(
                  "CO",
                  "${data['carbonMonoxide'].toStringAsFixed(1)} ppm",
                ),
                _pollutantTile(
                  "NO₂",
                  "${data['nitrogenDioxide'].toStringAsFixed(1)} µg/m³",
                ),
                _pollutantTile(
                  "SO₂",
                  "${data['sulphurDioxide'].toStringAsFixed(1)} µg/m³",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pollutantTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
