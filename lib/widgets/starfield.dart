import 'package:flutter/material.dart';

class StarfieldWidget extends StatelessWidget {
  final List<Map<String, double>> stars;
  final double starSize;

  const StarfieldWidget({
    super.key,
    required this.stars,
    this.starSize = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarfieldPainter(stars: stars, starSize: starSize),
      size: Size.infinite,
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final List<Map<String, double>> stars;
  final double starSize;

  _StarfieldPainter({
    required this.stars,
    required this.starSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.3 + star['brightness']! * 0.7)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(star['x']!, star['y']!),
        starSize * (0.5 + star['brightness']! * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter oldDelegate) => true;
}
