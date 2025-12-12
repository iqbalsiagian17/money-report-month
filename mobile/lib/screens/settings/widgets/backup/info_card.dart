import 'package:flutter/material.dart';

class BackupInfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const BackupInfoCard({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
