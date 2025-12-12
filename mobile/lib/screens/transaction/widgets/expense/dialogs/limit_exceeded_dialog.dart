import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LimitCheckResult {
  final String type;
  final String limitName;
  final double currentSpent;
  final double newAmount;
  final double limit;
  final double exceeded;

  LimitCheckResult({
    required this.type,
    required this.limitName,
    required this.currentSpent,
    required this.newAmount,
    required this.limit,
    required this.exceeded,
  });
}

class LimitExceededDialog extends StatelessWidget {
  final LimitCheckResult result;

  const LimitExceededDialog({
    super.key,
    required this.result,
  });

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = result.type == 'daily' ? Colors.blue : Colors.purple;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning_rounded,
                color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Limit Terlampaui! ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(result.limitName,
                    style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _DialogRow(
                    label: result.limitName,
                    value: _formatCurrency(result.limit),
                    color: color),
                const Divider(height: 20),
                _DialogRow(
                    label: 'Sudah Terpakai',
                    value: _formatCurrency(result.currentSpent)),
                const Divider(height: 20),
                _DialogRow(
                    label: 'Pengeluaran Baru',
                    value: _formatCurrency(result.newAmount)),
                const Divider(height: 20),
                _DialogRow(
                    label: 'Melebihi Limit',
                    value: _formatCurrency(result.exceeded),
                    isHighlight: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Apakah ini pengeluaran darurat yang harus dilakukan?',
                    style: TextStyle(fontSize: 13, color: Colors.orange[800]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.emergency_rounded, size: 18),
          label: const Text('Mode Darurat'),
        ),
      ],
    );
  }
}

class _DialogRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final Color? color;

  const _DialogRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isHighlight ? Colors.red : (color ?? Colors.grey[600]),
            fontWeight: isHighlight || color != null
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isHighlight ? Colors.red : null,
          ),
        ),
      ],
    );
  }
}
