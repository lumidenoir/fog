import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class SunCard extends StatefulWidget {
  final DateTime sunrise;
  final DateTime sunset;
  final double progress; // 0.0 - 1.0

  const SunCard({
    Key? key,
    required this.sunrise,
    required this.sunset,
    required this.progress,
  }) : super(key: key);

  @override
  State<SunCard> createState() => _SunCardState();
}

class _SunCardState extends State<SunCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: widget.progress.clamp(0, 1))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: SunArcPainter(
                    _animation.value,
                    sunrise: timeFormat.format(widget.sunrise),
                    sunset: timeFormat.format(widget.sunset),
                  ),
                  size: const Size(double.infinity, 140),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SunArcPainter extends CustomPainter {
  final double progress;
  final String sunrise;
  final String sunset;

  SunArcPainter(this.progress, {required this.sunrise, required this.sunset});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint trackPaint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // rounded edges

    final Paint progressPaint = Paint()
      ..color = Colors.orangeAccent
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // rounded edges

    final double radius = size.width / 2 - 16;
    final Offset center = Offset(size.width / 2, size.height);

    const double startAngle = math.pi;
    const double sweepAngle = math.pi;

    // background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );

    // sun position
    final double sunAngle = startAngle + sweepAngle * progress;
    final Offset sunPos = Offset(
      center.dx + radius * math.cos(sunAngle),
      center.dy + radius * math.sin(sunAngle),
    );

    canvas.drawCircle(
      sunPos,
      10,
      Paint()
        ..color = Colors.orangeAccent
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // sun icon
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '☀',
        style: TextStyle(fontSize: 14, color: Colors.white),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas, sunPos - Offset(textPainter.width / 2, textPainter.height / 2));

    // --- sunrise text (below left end) ---
    final sunrisePainter = TextPainter(
      text: TextSpan(
        text: sunrise,
        style: const TextStyle(fontSize: 14, color: Colors.white70),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    sunrisePainter.layout();
    sunrisePainter.paint(
      canvas,
      Offset(center.dx - radius - sunrisePainter.width / 2, center.dy + 8),
    );

    // --- sunset text (below right end) ---
    final sunsetPainter = TextPainter(
      text: TextSpan(
        text: sunset,
        style: const TextStyle(fontSize: 14, color: Colors.white70),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    sunsetPainter.layout();
    sunsetPainter.paint(
      canvas,
      Offset(center.dx + radius - sunsetPainter.width / 2, center.dy + 8),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
