import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_report_monthly/widgets/snack_helper.dart';
import 'package:provider/provider.dart';
import '../../../models/saving_goal.dart';
import '../../../models/wallet.dart';
import '../../../providers/saving_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../../providers/transaction_provider.dart';
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
  final _formKey = GlobalKey<FormState>();
  String? _selectedSourceWalletId; // Wallet SUMBER (dari mana uang diambil)
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default ke wallet pertama yang BUKAN wallet tujuan tabungan
    final walletProvider = context.read<WalletProvider>();
    final availableWallets = walletProvider.wallets
        .where((w) => w.id != widget.saving.targetWalletId)
        .toList();
    if (availableWallets.isNotEmpty) {
      _selectedSourceWalletId = availableWallets.first.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

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
    final walletProvider = context.watch<WalletProvider>();

    // Filter wallet: hanya tampilkan yang BUKAN wallet tujuan tabungan
    final availableWallets = walletProvider.wallets
        .where((w) => w.id != widget.saving.targetWalletId)
        .toList();

    // Wallet tujuan tabungan (read-only)
    final targetWallet = walletProvider.getById(widget.saving.targetWalletId);

    // Wallet sumber yang dipilih
    final selectedSourceWallet = _selectedSourceWalletId != null
        ? availableWallets.firstWhere(
            (w) => w.id == _selectedSourceWalletId,
            orElse: () => availableWallets.first,
          )
        : (availableWallets.isNotEmpty ? availableWallets.first : null);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                      child: const Icon(
                        Icons.savings_rounded,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Setor Tabungan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.saving.name,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Progress info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Terkumpul',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            _formatCurrency(widget.saving.currentAmount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: widget.saving.progress.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Target',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            _formatCurrency(widget.saving.targetAmount),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (widget.saving.remaining > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kurang',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
                            Text(
                              _formatCurrency(widget.saving.remaining),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ========== TRANSFER INFO ==========
                // Dompet Tujuan (Read-only)
                Text(
                  'Dompet Tujuan Tabungan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          targetWallet?.icon ?? '🎯',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              targetWallet?.name ?? 'Dompet tidak ditemukan',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'Saldo: ${_formatCurrency(targetWallet?.balance ?? 0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.lock_rounded,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pilih wallet sumber dana
                Text(
                  'Ambil Dana Dari',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Cek jika tidak ada wallet sumber yang tersedia
                if (availableWallets.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tidak ada dompet lain untuk transfer. Tambahkan dompet baru terlebih dahulu.',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Wallet selector
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: availableWallets.map((wallet) {
                        final isSelected = _selectedSourceWalletId == wallet.id;
                        return InkWell(
                          onTap: () {
                            setState(() => _selectedSourceWalletId = wallet.id);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1)
                                  : null,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                // Radio
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),

                                // Icon
                                Text(
                                  wallet.icon ?? '💰',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 10),

                                // Name & Balance
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        wallet.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Saldo: ${_formatCurrency(wallet.balance)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: wallet.balance > 0
                                              ? Colors.green
                                              : Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 20),

                // Amount input
                if (selectedSourceWallet != null)
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Nominal Setoran',
                      prefixText: 'Rp ',
                      prefixIcon: const Icon(Icons.payments_rounded),
                      filled: true,
                      fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      helperText:
                          'Saldo ${selectedSourceWallet.name}: ${_formatCurrency(selectedSourceWallet.balance)}',
                    ),
                    validator: (value) {
                      final amount =
                          CurrencyInputFormatter.getNumericValue(value ?? '');
                      if (amount <= 0) {
                        return 'Masukkan nominal yang valid';
                      }
                      if (amount > selectedSourceWallet.balance) {
                        return 'Saldo ${selectedSourceWallet.name} tidak mencukupi';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 8),

                // Quick amount buttons
                if (selectedSourceWallet != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _quickAmountChip('50rb', 50000, selectedSourceWallet),
                      _quickAmountChip('100rb', 100000, selectedSourceWallet),
                      _quickAmountChip('200rb', 200000, selectedSourceWallet),
                      _quickAmountChip('500rb', 500000, selectedSourceWallet),
                      if (widget.saving.remaining > 0 &&
                          widget.saving.remaining <=
                              selectedSourceWallet.balance)
                        _quickAmountChip('Sisa', widget.saving.remaining,
                            selectedSourceWallet,
                            isHighlight: true),
                    ],
                  ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
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
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: (_isLoading ||
                                availableWallets.isEmpty ||
                                _selectedSourceWalletId == null)
                            ? null
                            : _handleDeposit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
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
        ),
      ),
    );
  }

  Widget _quickAmountChip(String label, double amount, Wallet sourceWallet,
      {bool isHighlight = false}) {
    final isEnabled = amount <= sourceWallet.balance;
    return ActionChip(
      label: Text(label),
      backgroundColor: isHighlight
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : (isEnabled ? null : Colors.grey[200]),
      labelStyle: TextStyle(
        fontSize: 12,
        color: isHighlight
            ? Theme.of(context).primaryColor
            : (isEnabled ? null : Colors.grey),
        fontWeight: isHighlight ? FontWeight.w600 : null,
      ),
      onPressed: isEnabled
          ? () {
              _amountController.text =
                  NumberFormat('#,###', 'id_ID').format(amount.toInt());
            }
          : null,
    );
  }

  Future<void> _handleDeposit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSourceWalletId == null) return;

    setState(() => _isLoading = true);

    try {
      final amount =
          CurrencyInputFormatter.getNumericValue(_amountController.text);

      // Gunakan method depositWithTransfer
      final success = await context.read<SavingProvider>().depositWithTransfer(
            savingId: widget.saving.id,
            amount: amount,
            fromWalletId: _selectedSourceWalletId!,
            walletProvider: context.read<WalletProvider>(),
            transactionProvider: context.read<TransactionProvider>(),
          );

      if (mounted) {
        Navigator.pop(context);

        if (success) {
          SnackHelper.success(
            context,
            'Berhasil menyetor ${_formatCurrency(amount)} ke tabungan',
          );
        } else {
          SnackHelper.error(
            context,
            'Gagal menyetor. Periksa saldo wallet sumber.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackHelper.error(
          context,
          'Gagal menyetor: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
