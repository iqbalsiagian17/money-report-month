import 'package:flutter/material.dart';

class NotificationInfoTip extends StatelessWidget {
  const NotificationInfoTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Gunakan {nama} di pesan untuk menampilkan nama kamu secara otomatis.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
