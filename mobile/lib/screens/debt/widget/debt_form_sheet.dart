import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/debt.dart';
import '../../../providers/debt_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../../widgets/bottom_sheet/app_bottom_sheet.dart';
import '../../../widgets/snack_helper.dart';
import '../../transaction/widgets/shared/currency_input_formatter.dart';

class DebtFormSheet {
  DebtFormSheet._();

  static Future<void> show(BuildContext context, [Debt? existing]) {
    return AppBottomSheet.show(
      context: context,
      title: existing == null ? 'Tambah Hutang/Piutang' : 'Edit Hutang/Piutang',
      showCloseButton: true,
      maxHeight: MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.zero,
      child: _DebtFormContent(existing: existing),
    );
  }
}

class _DebtFormContent extends StatefulWidget {
  final Debt? existing;

  const _DebtFormContent({this.existing});

  @override
  State<_DebtFormContent> createState() => _DebtFormContentState();
}

class _DebtFormContentState extends State<_DebtFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DebtType _selectedType = DebtType.receivable;
  DateTime? _dueDate;
  String? _selectedWalletId;
  bool _isLoading = false;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final debt = widget.existing!;
      _nameController.text = debt.personName;
      _phoneController.text = debt.personPhone ?? '';
      _amountController.text =
          NumberFormat('#,###', 'id_ID').format(debt.amount.toInt());
      _descriptionController.text = debt.description ?? '';
      _selectedType = debt.type;
      _dueDate = debt.dueDate;
      _selectedWalletId = debt.walletId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletProvider = context.watch<WalletProvider>();

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Type selector
            _buildTypeSelector(isDark),
            const SizedBox(height: 20),

            // Person name
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: _selectedType == DebtType.receivable
                    ? 'Nama yang Berhutang'
                    : 'Nama Pemberi Hutang',
                prefixIcon: const Icon(Icons.person_rounded),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // Phone (optional)
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'No. HP (Opsional)',
                prefixIcon: const Icon(Icons.phone_rounded),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'Jumlah',
                prefixText: 'Rp ',
                prefixIcon: const Icon(Icons.payments_rounded),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) {
                final amount = CurrencyInputFormatter.getNumericValue(v ?? '');
                if (amount <= 0) return 'Jumlah harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Keterangan (Opsional)',
                prefixIcon: const Icon(Icons.notes_rounded),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Due date
            _buildDatePicker(isDark),
            const SizedBox(height: 14),

            // Wallet (optional)
            _buildWalletSelector(isDark, walletProvider),
            const SizedBox(height: 24),

            // Submit button
            _buildSubmitButton(),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeOption(
              type: DebtType.receivable,
              label: 'Piutang',
              subtitle: 'Orang lain hutang ke saya',
              icon: Icons.call_received_rounded,
              color: Colors.green,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTypeOption(
              type: DebtType.payable,
              label: 'Hutang',
              subtitle: 'Saya hutang ke orang lain',
              icon: Icons.call_made_rounded,
              color: Colors.red,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required DebtType type,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedType = type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color.withOpacity(0.3)) : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[400],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? color
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (picked != null) {
          setState(() => _dueDate = picked);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Jatuh Tempo (Opsional)',
          prefixIcon: const Icon(Icons.event_rounded),
          suffixIcon: _dueDate != null
              ? IconButton(
                  onPressed: () => setState(() => _dueDate = null),
                  icon: const Icon(Icons.clear, size: 20),
                )
              : null,
          filled: true,
          fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          _dueDate != null
              ? DateFormat('dd MMMM yyyy', 'id_ID').format(_dueDate!)
              : 'Pilih tanggal jatuh tempo',
          style: TextStyle(
            color: _dueDate != null
                ? (isDark ? Colors.white : Colors.black87)
                : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletSelector(bool isDark, WalletProvider walletProvider) {
    return DropdownButtonFormField<String>(
      value: _selectedWalletId,
      decoration: InputDecoration(
        labelText: 'Wallet Terkait (Opsional)',
        prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Tidak terkait wallet'),
        ),
        ...walletProvider.wallets.map((wallet) => DropdownMenuItem(
              value: wallet.id,
              child: Row(
                children: [
                  Text(wallet.icon ?? '💰'),
                  const SizedBox(width: 8),
                  Text(wallet.name),
                ],
              ),
            )),
      ],
      onChanged: (value) => setState(() => _selectedWalletId = value),
    );
  }

  Widget _buildSubmitButton() {
    final color =
        _selectedType == DebtType.receivable ? Colors.green : Colors.red;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
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
                isEditing
                    ? 'Simpan Perubahan'
                    : 'Tambah ${_selectedType == DebtType.receivable ? 'Piutang' : 'Hutang'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<DebtProvider>();
      final amount =
          CurrencyInputFormatter.getNumericValue(_amountController.text);

      if (isEditing) {
        // Update existing
        widget.existing!.type = _selectedType;
        widget.existing!.personName = _nameController.text.trim();
        widget.existing!.personPhone = _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null;
        widget.existing!.amount = amount;
        widget.existing!.description =
            _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null;
        widget.existing!.dueDate = _dueDate;
        widget.existing!.walletId = _selectedWalletId;
        widget.existing!.updateStatus();

        await provider.updateDebt(widget.existing!);
      } else {
        // Create new
        final debt = Debt(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: _selectedType,
          personName: _nameController.text.trim(),
          personPhone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          amount: amount,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          dueDate: _dueDate,
          walletId: _selectedWalletId,
        );

        await provider.addDebt(debt);
      }

      if (mounted) {
        Navigator.pop(context);
        SnackHelper.success(
          context,
          isEditing ? 'Berhasil diperbarui!' : 'Berhasil ditambahkan!',
        );
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
