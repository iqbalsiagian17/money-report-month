import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final Color?  color;
  final double height;

  const ProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? Theme.of(context).primaryColor;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: constraints.maxWidth * clampedProgress,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      progressColor,
                      progressColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}