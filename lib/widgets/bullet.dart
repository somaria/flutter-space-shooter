import 'package:flutter/material.dart';

class BulletWidget extends StatelessWidget {
  final Offset position;

  const BulletWidget({
    super.key,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        width: 5,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
      ),
    );
  }
}
