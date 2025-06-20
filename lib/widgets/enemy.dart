import 'package:flutter/material.dart';

class EnemyWidget extends StatelessWidget {
  final Offset position;
  final double size;

  const EnemyWidget({
    super.key,
    required this.position,
    this.size = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _EnemyPainter(),
        ),
      ),
    );
  }
}

class _EnemyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // Draw enemy body (inverted triangle)
    final path = Path();
    path.moveTo(size.width * 0.5, size.height); // Bottom middle
    path.lineTo(0, 0); // Top left
    path.lineTo(size.width, 0); // Top right
    path.close();

    canvas.drawPath(path, paint);

    // Draw eyes
    final eyePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Left eye
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.3),
      size.width * 0.1,
      eyePaint,
    );

    // Right eye
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.3),
      size.width * 0.1,
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(_EnemyPainter oldDelegate) => false;
}
