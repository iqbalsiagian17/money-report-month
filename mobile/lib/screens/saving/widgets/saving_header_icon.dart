import 'package:flutter/material.dart';

class SavingHeaderIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const SavingHeaderIcon({
    super.key,
    this.icon = Icons.savings_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).primaryColor;

    return Center(
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.15),
              primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: 44,
          color: primaryColor,
        ),
      ),
    );
  }
}
