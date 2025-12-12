import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/wallet.dart';

class IncomeWalletSelector extends StatelessWidget {
  final String? selectedWalletId;
  final List<Wallet> wallets;
  final ValueChanged<String?> onChanged;

  const IncomeWalletSelector({
    super.key,
    required this.selectedWalletId,
    required this.wallets,
    required this.onChanged,
  });

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (wallets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Belum ada dompet.  Tambahkan di Settings > Kelola Dompet',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: selectedWalletId,
      isExpanded: true, // Tambahkan ini agar dropdown bisa expand
      decoration: InputDecoration(
        labelText: 'Simpan ke Dompet',
        prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: wallets.map((wallet) {
        return DropdownMenuItem(
          value: wallet.id,
          child: _WalletItemContent(
            wallet: wallet,
            formatCurrency: _formatCurrency,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Pilih dompet' : null,
    );
  }
}

class _WalletItemContent extends StatelessWidget {
  final Wallet wallet;
  final String Function(double) formatCurrency;

  const _WalletItemContent({
    required this.wallet,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Gunakan min, bukan max
      children: [
        Text(wallet.icon ?? '💰', style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        // Gunakan Flexible bukan Expanded
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                wallet.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                formatCurrency(wallet.balance),
                style: TextStyle(
                  fontSize: 11,
                  color: wallet.balance >= 0 ? Colors.green : Colors.red,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
