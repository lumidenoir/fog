import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class SunCard extends StatefulWidget {
  final DateTime startEvent;
  final DateTime endEvent;
  final double progress; // 0.0 - 1.0
  final bool isNight;

  const SunCard({
    Key? key,
    required this.startEvent,
    required this.endEvent,
    required this.progress,
    required this.isNight,
  }) : super(key: key);

  @override
  State<SunCard> createState() => _SunCardState();
}

class _SunCardState extends State<SunCard>
    with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(SunCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress || oldWidget.isNight != widget.isNight) {
      _animation = Tween<double>(begin: _animation.value, end: widget.progress.clamp(0, 1))
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: LinearSunPainter(
                    _animation.value,
                    startText: timeFormat.format(widget.startEvent),
                    endText: timeFormat.format(widget.endEvent),
                    isNight: widget.isNight,
                  ),
                  size: const Size(double.infinity, 80),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LinearSunPainter extends CustomPainter {
  final double progress;
  final String startText;
  final String endText;
  final bool isNight;

  LinearSunPainter(this.progress,
      {required this.startText,
      required this.endText,
      required this.isNight});

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = isNight ? Colors.indigoAccent : Colors.orangeAccent
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double lineY = size.height / 2;
    const double padding = 20.0;
    final double startX = padding;
    final double endX = size.width - padding;
    final double lineLength = endX - startX;

    // Background line
    canvas.drawLine(Offset(startX, lineY), Offset(endX, lineY), trackPaint);

    // Progress line
    final double currentX = startX + (lineLength * progress);
    canvas.drawLine(
        Offset(startX, lineY), Offset(currentX, lineY), progressPaint);

    // Current icon position
    final Offset iconPos = Offset(currentX, lineY);

    // Glow
    canvas.drawCircle(
      iconPos,
      12,
      Paint()
        ..color = isNight ? Colors.indigoAccent : Colors.orangeAccent
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Draw the icon text '☀' or '🌙'
    final TextPainter iconPainter = TextPainter(
      text: TextSpan(
        text: isNight ? '🌙' : '☀',
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
        canvas,
        iconPos -
            Offset(iconPainter.width / 2, iconPainter.height / 2));

    // Draw left text (start time)
    final TextPainter startTextPainter = TextPainter(
      text: TextSpan(
        text: startText,
        style: const TextStyle(fontSize: 14, color: Colors.white70),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    startTextPainter.layout();
    startTextPainter.paint(
        canvas, Offset(startX - (startTextPainter.width / 2), lineY + 16));

    // Draw right text (end time)
    final TextPainter endTextPainter = TextPainter(
      text: TextSpan(
        text: endText,
        style: const TextStyle(fontSize: 14, color: Colors.white70),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    endTextPainter.layout();
    endTextPainter.paint(
        canvas, Offset(endX - (endTextPainter.width / 2), lineY + 16));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
