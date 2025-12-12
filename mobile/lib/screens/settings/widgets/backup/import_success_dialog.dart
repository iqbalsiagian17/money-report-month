import 'package:flutter/material.dart';
import '../../../../services/backup_service.dart';

class ImportSuccessDialog extends StatelessWidget {
  final ImportStats? stats;

  const ImportSuccessDialog({
    super.key,
    this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Import Berhasil!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data berhasil di-import:'),
          const SizedBox(height: 12),
          if (stats != null) ...[
            _StatRow(label: 'Dompet', count: stats!.wallets),
            _StatRow(label: 'Transaksi', count: stats!.transactions),
            _StatRow(label: 'Kategori', count: stats!.categories),
            _StatRow(label: 'Tabungan', count: stats!.savings),
            _StatRow(label: 'Budget', count: stats!.budgets),
          ],
          const SizedBox(height: 12),
          const Text(
            'Silakan restart aplikasi untuk melihat perubahan.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // close dialog
            Navigator.pop(context); // back to previous page (optional)
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int count;

  const _StatRow({
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$count item',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
