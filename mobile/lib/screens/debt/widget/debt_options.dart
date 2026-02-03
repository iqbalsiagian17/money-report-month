import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/debt.dart';
import '../../../providers/debt_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../widgets/bottom_sheet/app_bottom_sheet.dart';
import '../../../widgets/bottom_sheet/variants/options_bottom_sheet.dart';
import '../../../widgets/snack_helper.dart';
import '../../transaction/widgets/shared/currency_input_formatter.dart';
import 'debt_form_sheet.dart';

enum DebtOptionAction {
  pay,
  edit,
  markPaid,
  delete,
  call,
}

class DebtOptions {
  static String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  static Future<void> show(BuildContext context, Debt debt) async {
    final isReceivable = debt.type == DebtType.receivable;

    final action = await AppBottomSheet.showOptions<DebtOptionAction>(
      context: context,
      title: debt.personName,
      subtitle:
          '${isReceivable ? "Piutang" : "Hutang"}: ${_formatCurrency(debt.remainingAmount)}',
      options: [
        if (!debt.isPaid)
          BottomSheetOption(
            title: isReceivable ? 'Terima Pembayaran' : 'Bayar Hutang',
            subtitle: 'Catat pembayaran sebagian atau lunas',
            icon: Icons.payments_rounded,
            iconColor: Colors.green,
            value: DebtOptionAction.pay,
          ),
        const BottomSheetOption(
          title: 'Edit',
          subtitle: 'Ubah detail hutang/piutang',
          icon: Icons.edit_rounded,
          iconColor: Colors.blue,
          value: DebtOptionAction.edit,
        ),
        if (!debt.isPaid)
          const BottomSheetOption(
            title: 'Tandai Lunas',
            subtitle: 'Tanpa mencatat transaksi',
            icon: Icons.check_circle_rounded,
            iconColor: Colors.teal,
            value: DebtOptionAction.markPaid,
          ),
        if (debt.personPhone != null && debt.personPhone!.isNotEmpty)
          const BottomSheetOption(
            title: 'Hubungi',
            subtitle: 'Buka aplikasi telepon',
            icon: Icons.phone_rounded,
            iconColor: Colors.orange,
            value: DebtOptionAction.call,
          ),
        const BottomSheetOption(
          title: 'Hapus',
          subtitle: 'Hapus hutang/piutang ini',
          icon: Icons.delete_forever_rounded,
          iconColor: Colors.red,
          isDestructive: true,
          value: DebtOptionAction.delete,
        ),
      ],
    );

    if (!context.mounted || action == null) return;

    switch (action) {
      case DebtOptionAction.pay:
        _showPaymentSheet(context, debt);
        break;
      case DebtOptionAction.edit:
        DebtFormSheet.show(context, debt);
        break;
      case DebtOptionAction.markPaid:
        _confirmMarkPaid(context, debt);
        break;
      case DebtOptionAction.call:
        _callPerson(debt);
        break;
      case DebtOptionAction.delete:
        _confirmDelete(context, debt);
        break;
    }
  }

  // ================= PAYMENT =================
  static void _showPaymentSheet(BuildContext context, Debt debt) {
    final amountController = TextEditingController();
    final isReceivable = debt.type == DebtType.receivable;

    AppBottomSheet.show(
      context: context,
      title: isReceivable ? 'Terima Pembayaran' : 'Bayar Hutang',
      showCloseButton: true,
      child: _PaymentContent(
        debt: debt,
        amountController: amountController,
      ),
    );
  }

  // ================= MARK PAID =================
  static Future<void> _confirmMarkPaid(BuildContext context, Debt debt) async {
    final confirmed = await AppBottomSheet.showConfirm(
      context: context,
      title: 'Tandai Lunas?',
      message:
          'Hutang/piutang "${debt.personName}" sebesar ${_formatCurrency(debt.remainingAmount)} akan ditandai lunas tanpa mencatat transaksi.',
      confirmText: 'Tandai Lunas',
      icon: Icons.check_circle_rounded,
      iconColor: Colors.teal,
    );

    if (confirmed == true && context.mounted) {
      await context.read<DebtProvider>().markAsPaid(debt.id);
      SnackHelper.success(context, 'Berhasil ditandai lunas!');
    }
  }

  // ================= CALL =================
  static void _callPerson(Debt debt) {
    if (debt.personPhone == null) return;
    // TODO: Implement url_launcher to call
    // launchUrl(Uri.parse('tel:${debt.personPhone}'));
  }

  // ================= DELETE =================
  static Future<void> _confirmDelete(BuildContext context, Debt debt) async {
    final confirmed = await AppBottomSheet.showConfirm(
      context: context,
      title: 'Hapus?',
      message:
          'Hutang/piutang "${debt.personName}" akan dihapus secara permanen.',
      isDanger: true,
      confirmText: 'Hapus',
      icon: Icons.delete_forever_rounded,
    );

    if (confirmed == true && context.mounted) {
      await context.read<DebtProvider>().deleteDebt(debt.id);
      SnackHelper.success(context, 'Berhasil dihapus!');
    }
  }
}

// ================= PAYMENT CONTENT =================
class _PaymentContent extends StatefulWidget {
  final Debt debt;
  final TextEditingController amountController;

  const _PaymentContent({
    required this.debt,
    required this.amountController,
  });

  @override
  State<_PaymentContent> createState() => _PaymentContentState();
}

class _PaymentContentState extends State<_PaymentContent> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedWalletId;
  bool _isLoading = false;

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  void initState() {
    super.initState();
    _selectedWalletId = widget.debt.walletId;
    
    // Default ke wallet pertama jika belum ada
    if (_selectedWalletId == null) {
      final wallets = context.read<WalletProvider>().wallets;
      if (wallets.isNotEmpty) {
        _selectedWalletId = wallets.first.id;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletProvider = context.watch<WalletProvider>();
    final isReceivable = widget.debt.type == DebtType.receivable;
    final mainColor = isReceivable ? Colors.green : Colors.red;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.debt.personName.isNotEmpty
                          ? widget.debt.personName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.debt.personName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sisa: ${_formatCurrency(widget.debt.remainingAmount)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: mainColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Amount input
            TextFormField(
              controller: widget.amountController,
                            keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Jumlah Pembayaran',
                prefixText: 'Rp ',
                prefixIcon: const Icon(Icons.payments_rounded),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                helperText:
                    'Maksimal: ${_formatCurrency(widget.debt.remainingAmount)}',
              ),
              validator: (v) {
                final amount = CurrencyInputFormatter.getNumericValue(v ?? '');
                if (amount <= 0) return 'Jumlah harus lebih dari 0';
                if (amount > widget.debt.remainingAmount) {
                  return 'Melebihi sisa hutang/piutang';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Quick amount chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickChip('50rb', 50000),
                _buildQuickChip('100rb', 100000),
                _buildQuickChip('500rb', 500000),
                _buildQuickChip(
                  'Lunas',
                  widget.debt.remainingAmount,
                  isHighlight: true,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Wallet selector
            Text(
              isReceivable ? 'Masuk ke Wallet' : 'Bayar dari Wallet',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                children: walletProvider.wallets.map((wallet) {
                  final isSelected = _selectedWalletId == wallet.id;
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedWalletId = wallet.id);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? mainColor.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          // Radio
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isSelected ? mainColor : Colors.grey[400]!,
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
                                        color: mainColor,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            wallet.icon ?? '💰',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wallet.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(wallet.balance),
                                  style: TextStyle(
                                    fontSize: 12,
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
            const SizedBox(height: 24),

            // Submit button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handlePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isReceivable ? 'Terima' : 'Bayar',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, double amount,
      {bool isHighlight = false}) {
    final isEnabled = amount <= widget.debt.remainingAmount;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled
            ? () {
                HapticFeedback.selectionClick();
                widget.amountController.text =
                    NumberFormat('#,###', 'id_ID').format(amount.toInt());
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isHighlight
                ? Theme.of(context).primaryColor.withOpacity(0.12)
                : (isEnabled
                    ? Colors.grey.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(20),
            border: isHighlight
                ? Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  )
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
              color: isHighlight
                  ? Theme.of(context).primaryColor
                  : (isEnabled ? null : Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWalletId == null) {
      SnackHelper.error(context, 'Pilih wallet terlebih dahulu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount =
          CurrencyInputFormatter.getNumericValue(widget.amountController.text);

      final success = await context.read<DebtProvider>().recordPayment(
            debtId: widget.debt.id,
            amount: amount,
            walletId: _selectedWalletId!,
            walletProvider: context.read<WalletProvider>(),
            transactionProvider: context.read<TransactionProvider>(),
          );

      if (mounted) {
        Navigator.pop(context);

        if (success) {
          SnackHelper.success(
            context,
            'Pembayaran ${_formatCurrency(amount)} berhasil dicatat!',
          );
        } else {
          SnackHelper.error(context, 'Gagal mencatat pembayaran');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackHelper.error(context, 'Gagal: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
