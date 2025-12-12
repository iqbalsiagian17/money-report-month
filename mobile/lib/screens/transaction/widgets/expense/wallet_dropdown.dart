import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../providers/wallet_provider.dart';
import '../../../../models/wallet.dart';

class ExpenseWalletDropdown extends StatelessWidget {
  final String? selectedWalletId;
  final WalletProvider walletProvider;
  final double currentAmount;
  final ValueChanged<String?> onChanged;

  const ExpenseWalletDropdown({
    super.key,
    required this.selectedWalletId,
    required this.walletProvider,
    required this.currentAmount,
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
    final wallets = walletProvider.wallets;

    if (wallets.isEmpty) {
      return _buildEmptyWarning();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: selectedWalletId,
          isExpanded: true, // Penting:  tambahkan ini
          decoration: InputDecoration(
            labelText: 'Metode Pembayaran',
            prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
            filled: true,
            fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          items: wallets.map((wallet) {
            return DropdownMenuItem<String>(
              value: wallet.id,
              child: _WalletItem(
                wallet: wallet,
                formatCurrency: _formatCurrency,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) =>
              value == null ? 'Pilih metode pembayaran' : null,
        ),
        if (selectedWalletId != null)
          _WalletBalanceWarning(
            wallet: wallets.firstWhere(
              (w) => w.id == selectedWalletId,
              orElse: () =>
                  Wallet(id: '', name: '', balance: 0, type: WalletType.cash),
            ),
            amount: currentAmount,
            formatCurrency: _formatCurrency,
          ),
      ],
    );
  }

  Widget _buildEmptyWarning() {
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
              'Belum ada dompet. Tambahkan di Settings > Kelola Dompet',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletItem extends StatelessWidget {
  final Wallet wallet;
  final String Function(double) formatCurrency;

  const _WalletItem({
    required this.wallet,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Penting: gunakan min
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
                  color: wallet.balance > 0 ? Colors.green : Colors.red,
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

class _WalletBalanceWarning extends StatelessWidget {
  final Wallet wallet;
  final double amount;
  final String Function(double) formatCurrency;

  const _WalletBalanceWarning({
    required this.wallet,
    required this.amount,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    if (wallet.id.isEmpty) return const SizedBox.shrink();

    // Saldo kosong
    if (wallet.balance <= 0) {
      return _buildWarningBox(
        icon: Icons.block,
        title: 'Saldo ${wallet.name} kosong! ',
        subtitle: 'Tidak bisa melakukan pengeluaran',
        color: Colors.red,
      );
    }

    // Saldo tidak cukup
    if (amount > 0 && amount > wallet.balance) {
      return _buildWarningBox(
        icon: Icons.block,
        title: 'Saldo tidak cukup!',
        subtitle: 'Saldo tersedia: ${formatCurrency(wallet.balance)}',
        extra: 'Kekurangan: ${formatCurrency(amount - wallet.balance)}',
        color: Colors.red,
      );
    }

    // Saldo cukup
    if (amount > 0) {
      final remaining = wallet.balance - amount;
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, size: 18, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sisa saldo setelah transaksi: ${formatCurrency(remaining)}',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildWarningBox({
    required IconData icon,
    required String title,
    required String subtitle,
    String? extra,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: color)),
                  if (extra != null)
                    Text(
                      extra,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
