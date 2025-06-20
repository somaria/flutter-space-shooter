import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback onShoot;
  final Function(bool) onMoveLeft;
  final Function(bool) onMoveRight;

  const ControlButtons({
    super.key,
    required this.onShoot,
    required this.onMoveLeft,
    required this.onMoveRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: 80,
      child: Row(
        children: [
          // Shoot button
          Expanded(
            child: GestureDetector(
              onTap: onShoot,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'SHOOT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Left button
          Expanded(
            child: GestureDetector(
              onTapDown: (_) => onMoveLeft(true),
              onTapUp: (_) => onMoveLeft(false),
              onTapCancel: () => onMoveLeft(false),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_left, color: Colors.white, size: 36),
                ),
              ),
            ),
          ),
          // Right button
          Expanded(
            child: GestureDetector(
              onTapDown: (_) => onMoveRight(true),
              onTapUp: (_) => onMoveRight(false),
              onTapCancel: () => onMoveRight(false),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_right, color: Colors.white, size: 36),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
