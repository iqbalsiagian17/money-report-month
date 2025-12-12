import 'package:flutter/material.dart';

class EmptyRecurringState extends StatelessWidget {
  final VoidCallback onCreateTap;

  const EmptyRecurringState({
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
                Icons.repeat_rounded,
                size: 50,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Transaksi Rutin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transaksi rutin membantu mencatat\npemasukan dan pengeluaran berulang',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Examples
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Contoh transaksi rutin: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _ExampleChip(label: '💰 Gaji bulanan', isDark: isDark),
                      _ExampleChip(label: '🏠 Sewa kos', isDark: isDark),
                      _ExampleChip(label: '📺 Netflix', isDark: isDark),
                      _ExampleChip(label: '💡 Listrik', isDark: isDark),
                      _ExampleChip(label: '📱 Internet', isDark: isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onCreateTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Tambah Transaksi Rutin',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _ExampleChip({
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? Colors.grey[300] : Colors.grey[700],
        ),
      ),
    );
  }
}
