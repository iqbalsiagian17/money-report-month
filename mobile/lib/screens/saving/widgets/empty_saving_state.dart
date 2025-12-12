import 'package:flutter/material.dart';

class EmptySavingState extends StatelessWidget {
  final VoidCallback onCreateTap;

  const EmptySavingState({
    super.key,
    required this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.savings_outlined,
                size: 50,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Target Tabungan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai menabung dengan membuat\ntarget tabungan pertamamu!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
