import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../models/wallet.dart';

class InsufficientBalanceDialog extends StatelessWidget {
  final Wallet wallet;
  final double amount;

  const InsufficientBalanceDialog({
    super.key,
    required this.wallet,
    required this.amount,
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
    final shortage = amount - wallet.balance;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.block, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Saldo Tidak Cukup! ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                Row(
                  children: [
                    Text(wallet.icon ?? '💰',
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(wallet.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            'Saldo: ${_formatCurrency(wallet.balance)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: wallet.balance > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _DialogRow(
                    label: 'Pengeluaran', value: _formatCurrency(amount)),
                const SizedBox(height: 8),
                _DialogRow(
                    label: 'Saldo Dompet',
                    value: _formatCurrency(wallet.balance)),
                const SizedBox(height: 8),
                _DialogRow(
                    label: 'Kekurangan',
                    value: _formatCurrency(shortage),
                    isHighlight: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.red, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Saldo tidak boleh minus.  Tambahkan saldo terlebih dahulu atau kurangi jumlah pengeluaran.',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Mengerti'),
          ),
        ),
      ],
    );
  }
}

class _DialogRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _DialogRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
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
            color: isHighlight ? Colors.red : Colors.grey[600],
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
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
