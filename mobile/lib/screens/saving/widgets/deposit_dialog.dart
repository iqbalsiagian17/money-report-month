import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../models/saving_goal.dart';
import '../../../../providers/saving_provider.dart';
import '../../../../providers/wallet_provider.dart';
import '../../transaction/widgets/shared/currency_input_formatter.dart';

class DepositDialog extends StatefulWidget {
  final SavingGoal saving;

  const DepositDialog({
    super.key,
    required this.saving,
  });

  @override
  State<DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<DepositDialog> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final walletProvider = context.read<WalletProvider>();
    final wallet = walletProvider.getById(widget.saving.walletId);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Text(
                  'Setor Tabungan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Target Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.saving.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sisa target: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      Text(
                        currencyFormat.format(widget.saving.remaining),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (wallet != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saldo ${wallet.name}:',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        Text(
                          currencyFormat.format(wallet.balance),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                wallet.balance > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Amount Field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              autofocus: true,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Jumlah Setoran',
                prefixText: 'Rp ',
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Amount Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [50000, 100000, 200000, 500000].map((amount) {
                return GestureDetector(
                  onTap: () {
                    _amountController.text =
                        NumberFormat.decimalPattern('id_ID').format(amount);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currencyFormat.format(amount),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deposit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Setor',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deposit() {
    final amount =
        CurrencyInputFormatter.getNumericValue(_amountController.text);

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jumlah yang valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final walletProvider = context.read<WalletProvider>();
    final wallet = walletProvider.getById(widget.saving.walletId);

    if (wallet != null && amount > wallet.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo dompet tidak mencukupi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Potong saldo wallet
    walletProvider.updateBalance(widget.saving.walletId, -amount);

    // Tambah ke tabungan
    context.read<SavingProvider>().deposit(widget.saving.id, amount);

    Navigator.pop(context);

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil menyetor ${currencyFormat.format(amount)} 🎉'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
