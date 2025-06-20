import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback onShoot;
  final Function(bool) onMoveLeft;
  final Function(bool) onMoveRight;
  final VoidCallback? onSingleTapLeft; // Added for single tap movement
  final VoidCallback? onSingleTapRight; // Added for single tap movement

  const ControlButtons({
    super.key,
    required this.onShoot,
    required this.onMoveLeft,
    required this.onMoveRight,
    this.onSingleTapLeft,
    this.onSingleTapRight,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Add additional margin (20 points) on top of the existing padding
    final standardMargin = 16.0;
    final additionalMargin = 20.0;

    return Container(
      color: Colors.black,
      height: 80 +
          (bottomInset > 0
              ? bottomInset + additionalMargin
              : standardMargin + additionalMargin),
      padding: EdgeInsets.only(
          bottom: bottomInset > 0
              ? bottomInset + additionalMargin
              : standardMargin +
                  additionalMargin), // Add padding for home indicator or standard margin, plus extra margin
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
              onTap: () {
                // Use single tap if provided, otherwise use normal behavior
                if (onSingleTapLeft != null) {
                  onSingleTapLeft!();
                }
              },
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
              onTap: () {
                // Use single tap if provided, otherwise use normal behavior
                if (onSingleTapRight != null) {
                  onSingleTapRight!();
                }
              },
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
