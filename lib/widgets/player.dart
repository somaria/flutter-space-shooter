import 'package:flutter/material.dart';

class PlayerWidget extends StatelessWidget {
  final double playerX;
  final double playerY;

  const PlayerWidget({
    super.key,
    required this.playerX,
    required this.playerY,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: playerX,
      bottom: playerY,
      child: SizedBox(
        width: 50,
        height: 30,
        child: CustomPaint(
          painter: _SpaceshipPainter(),
        ),
      ),
    );
  }
}

class _SpaceshipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path();
    // Draw spaceship body
    path.moveTo(size.width * 0.5, 0); // Top middle
    path.lineTo(size.width, size.height); // Bottom right
    path.lineTo(0, size.height); // Bottom left
    path.close();

    canvas.drawPath(path, paint);

    // Draw window/cockpit
    final windowPaint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.15,
      windowPaint,
    );
  }

  @override
  bool shouldRepaint(_SpaceshipPainter oldDelegate) => false;
}
