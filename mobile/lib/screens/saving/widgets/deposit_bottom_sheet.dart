import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/saving_goal.dart';
import '../../../models/wallet.dart';
import '../../../providers/saving_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../widgets/bottom_sheet/app_bottom_sheet.dart';
import '../../../widgets/snack_helper.dart';
import '../../transaction/widgets/shared/currency_input_formatter.dart';

class DepositBottomSheet {
  DepositBottomSheet._();

  /// Menampilkan bottom sheet setor tabungan
  static Future<bool?> show(BuildContext context, SavingGoal saving) {
    return AppBottomSheet.show<bool>(
      context: context,
      title: 'Setor Tabungan',
      subtitle: saving.name,
      showCloseButton: true,
      maxHeight: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.zero,
      child: _DepositContent(saving: saving),
    );
  }
}

class _DepositContent extends StatefulWidget {
  final SavingGoal saving;

  const _DepositContent({required this.saving});

  @override
  State<_DepositContent> createState() => _DepositContentState();
}

class _DepositContentState extends State<_DepositContent> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedSourceWalletId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initDefaultWallet();
  }

  void _initDefaultWallet() {
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

    final availableWallets = walletProvider.wallets
        .where((w) => w.id != widget.saving.targetWalletId)
        .toList();

    final targetWallet = walletProvider.getById(widget.saving.targetWalletId);

    final selectedSourceWallet = _selectedSourceWalletId != null
        ? availableWallets.firstWhere(
            (w) => w.id == _selectedSourceWalletId,
            orElse: () => availableWallets.first,
          )
        : (availableWallets.isNotEmpty ? availableWallets.first : null);

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress info
            _buildProgressCard(isDark),
            const SizedBox(height: 20),

            // Dompet Tujuan (Read-only)
            _buildTargetWallet(isDark, targetWallet),
            const SizedBox(height: 16),

            // Pilih wallet sumber
            _buildSourceWalletSelector(isDark, availableWallets),
            const SizedBox(height: 20),

            // Amount input
            if (selectedSourceWallet != null) ...[
              _buildAmountInput(isDark, selectedSourceWallet),
              const SizedBox(height: 12),
              _buildQuickAmounts(selectedSourceWallet),
            ],
            const SizedBox(height: 24),

            // Buttons
            _buildButtons(availableWallets),

            // Safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(bool isDark) {
    final progress = widget.saving.progress.clamp(0.0, 1.0);
    final progressPercent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey[850]!, Colors.grey[900]!]
              : [Colors.grey[50]!, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          // Progress header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terkumpul',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(widget.saving.currentAmount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$progressPercent%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Target & Remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressItem(
                'Target',
                _formatCurrency(widget.saving.targetAmount),
                Colors.grey[600]!,
              ),
              if (widget.saving.remaining > 0)
                _buildProgressItem(
                  'Kurang',
                  _formatCurrency(widget.saving.remaining),
                  Colors.orange[700]!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetWallet(bool isDark, Wallet? targetWallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dompet Tujuan Tabungan',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.green.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  targetWallet?.icon ?? '🎯',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      targetWallet?.name ?? 'Tidak ditemukan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceWalletSelector(
      bool isDark, List<Wallet> availableWallets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ambil Dana Dari',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        if (availableWallets.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tidak ada dompet lain. Tambahkan dompet baru terlebih dahulu.',
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
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
            child: Column(
              children: availableWallets
                  .asMap()
                  .entries
                  .map((entry) => _buildWalletOption(
                        entry.value,
                        isDark,
                        isLast: entry.key == availableWallets.length - 1,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildWalletOption(Wallet wallet, bool isDark, {bool isLast = false}) {
    final isSelected = _selectedSourceWalletId == wallet.id;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedSourceWalletId = wallet.id);
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                wallet.icon ?? '💰',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(wallet.balance),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: wallet.balance > 0
                          ? Colors.green[600]
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Check icon
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).primaryColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput(bool isDark, Wallet selectedSourceWallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nominal Setoran',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
          ],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            prefixText: 'Rp ',
            prefixStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).primaryColor,
            ),
            hintText: '0',
            hintStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            helperText:
                'Saldo tersedia: ${_formatCurrency(selectedSourceWallet.balance)}',
            helperStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          validator: (value) {
            final amount = CurrencyInputFormatter.getNumericValue(value ?? '');
            if (amount <= 0) {
              return 'Masukkan nominal yang valid';
            }
            if (amount > selectedSourceWallet.balance) {
              return 'Saldo tidak mencukupi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildQuickAmounts(Wallet sourceWallet) {
    final amounts = [
      ('50rb', 50000.0),
      ('100rb', 100000.0),
      ('200rb', 200000.0),
      ('500rb', 500000.0),
    ];

    // Add "Sisa" if applicable
    final showSisa = widget.saving.remaining > 0 &&
        widget.saving.remaining <= sourceWallet.balance;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...amounts.map((item) => _buildQuickChip(
              item.$1,
              item.$2,
              sourceWallet,
            )),
        if (showSisa)
          _buildQuickChip(
            'Sisa',
            widget.saving.remaining,
            sourceWallet,
            isHighlight: true,
          ),
      ],
    );
  }

  Widget _buildQuickChip(
    String label,
    double amount,
    Wallet sourceWallet, {
    bool isHighlight = false,
  }) {
    final isEnabled = amount <= sourceWallet.balance;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled
            ? () {
                HapticFeedback.selectionClick();
                _amountController.text =
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

  Widget _buildButtons(List<Wallet> availableWallets) {
    final canSubmit = !_isLoading &&
        availableWallets.isNotEmpty &&
        _selectedSourceWalletId != null;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: const Text('Batal'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: canSubmit ? _handleDeposit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
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
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.savings_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Setor',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDeposit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSourceWalletId == null) return;

    setState(() => _isLoading = true);

    try {
      final amount =
          CurrencyInputFormatter.getNumericValue(_amountController.text);

      final success = await context.read<SavingProvider>().depositWithTransfer(
            savingId: widget.saving.id,
            amount: amount,
            fromWalletId: _selectedSourceWalletId!,
            walletProvider: context.read<WalletProvider>(),
            transactionProvider: context.read<TransactionProvider>(),
          );

      if (mounted) {
        Navigator.pop(context, success);

        if (success) {
          SnackHelper.success(
            context,
            'Berhasil menyetor ${_formatCurrency(amount)}',
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
        SnackHelper.error(context, 'Gagal menyetor: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
