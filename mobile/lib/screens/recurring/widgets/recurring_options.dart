import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:money_report_monthly/screens/transaction/widgets/shared/currency_input_formatter.dart';
import 'package:provider/provider.dart';
import '../../../../models/recurring_transaction.dart';
import '../../../../providers/wallet_provider.dart';
import '../../../../widgets/bottom_sheet/app_bottom_sheet.dart';
import '../../../../widgets/bottom_sheet/variants/options_bottom_sheet.dart';
import 'recurring_form_fields.dart';

enum RecurringOptionAction {
  toggle,
  edit,
  delete,
}

class RecurringOptions {
  RecurringOptions._();

  static Future<void> show(
    BuildContext context,
    RecurringTransaction recurring,
  ) async {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final type = recurring.isIncome ? 'Pemasukan' : 'Pengeluaran';
    final status = recurring.isActive ? '🟢 Aktif' : '⚪ Nonaktif';

    final action = await AppBottomSheet.showOptions<RecurringOptionAction>(
      context: context,
      title: recurring.name,
      subtitle: '$type • ${currency.format(recurring.amount)} • $status',
      options: [
        BottomSheetOption(
          title: recurring.isActive ? 'Nonaktifkan' : 'Aktifkan',
          subtitle: recurring.isActive
              ? 'Hentikan transaksi otomatis sementara'
              : 'Mulai kembali transaksi otomatis',
          icon: recurring.isActive
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          iconColor: recurring.isActive ? Colors.orange : Colors.green,
          value: RecurringOptionAction.toggle,
        ),
        const BottomSheetOption(
          title: 'Edit Transaksi Rutin',
          subtitle: 'Ubah detail transaksi',
          icon: Icons.edit_rounded,
          iconColor: Colors.blue,
          value: RecurringOptionAction.edit,
        ),
        const BottomSheetOption(
          title: 'Hapus Transaksi Rutin',
          subtitle: 'Hapus secara permanen',
          icon: Icons.delete_forever_rounded,
          iconColor: Colors.red,
          isDestructive: true,
          value: RecurringOptionAction.delete,
        ),
      ],
    );

    if (!context.mounted || action == null) return;

    switch (action) {
      case RecurringOptionAction.toggle:
        _toggleActive(context, recurring);
        break;
      case RecurringOptionAction.edit:
        _showEditForm(context, recurring);
        break;
      case RecurringOptionAction.delete:
        _confirmDelete(context, recurring);
        break;
    }
  }

  // ================= TOGGLE ACTIVE =================
  static void _toggleActive(
      BuildContext context, RecurringTransaction recurring) {
    recurring.isActive = !recurring.isActive;
    recurring.save();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          recurring.isActive
              ? '✅ ${recurring.name} diaktifkan'
              : '⏸️ ${recurring.name} dinonaktifkan',
        ),
        backgroundColor: recurring.isActive ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ================= EDIT =================
  static void _showEditForm(
      BuildContext context, RecurringTransaction recurring) {
    final nameController = TextEditingController(text: recurring.name);
    final amountController = TextEditingController(
      text: recurring.amount.toInt().toString(),
    );

    bool isIncome = recurring.isIncome;
    String? selectedWalletId = recurring.walletId;
    RecurringType recurringType = recurring.recurringType;
    int dayOfMonth = recurring.dayOfMonth;

    AppBottomSheet.showForm<bool>(
      context: context,
      title: 'Edit Transaksi Rutin',
      subtitle: 'Ubah detail ${recurring.name}',
      submitText: 'Simpan Perubahan',
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecurringTypeSwitch(
              isIncome: isIncome,
              onChanged: (v) => setState(() => isIncome = v),
            ),
            const SizedBox(height: 20),
            RecurringNameField(controller: nameController),
            const SizedBox(height: 16),
            RecurringAmountField(controller: amountController),
            const SizedBox(height: 16),
            Consumer<WalletProvider>(
              builder: (_, walletProvider, __) {
                return RecurringWalletDropdown(
                  selectedWalletId: selectedWalletId,
                  wallets: walletProvider.wallets,
                  onChanged: (v) => setState(() => selectedWalletId = v),
                );
              },
            ),
            const SizedBox(height: 16),
            RecurringPeriodDropdown(
              selectedType: recurringType,
              onChanged: (v) {
                if (v != null) setState(() => recurringType = v);
              },
            ),
            if (recurringType == RecurringType.monthly) ...[
              const SizedBox(height: 16),
              RecurringDayDropdown(
                selectedDay: dayOfMonth,
                onChanged: (v) {
                  if (v != null) setState(() => dayOfMonth = v);
                },
              ),
            ],
          ],
        );
      },
      onSubmit: () async {
        // Validasi
        if (nameController.text.trim().isEmpty) return null;
        if (selectedWalletId == null) return null;

        final amount =
            CurrencyInputFormatter.getNumericValue(amountController.text);
        if (amount <= 0) return null;

        // Update recurring
        recurring.name = nameController.text.trim();
        recurring.amount = amount;
        recurring.isIncome = isIncome;
        recurring.walletId = selectedWalletId!;
        recurring.recurringType = recurringType;
        recurring.dayOfMonth = dayOfMonth;

        // Recalculate next due if type/day changed
        final now = DateTime.now();
        switch (recurringType) {
          case RecurringType.daily:
            recurring.nextDueDate = DateTime(now.year, now.month, now.day + 1);
            break;
          case RecurringType.weekly:
            recurring.nextDueDate =
                now.add(Duration(days: 7 - now.weekday + 1));
            break;
          case RecurringType.monthly:
            var nextDue = DateTime(now.year, now.month, dayOfMonth);
            if (!nextDue.isAfter(now)) {
              nextDue = DateTime(now.year, now.month + 1, dayOfMonth);
            }
            recurring.nextDueDate = nextDue;
            break;
          case RecurringType.yearly:
            recurring.nextDueDate = DateTime(now.year + 1, now.month, now.day);
            break;
        }

        await recurring.save();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✏️ ${recurring.name} berhasil diupdate'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }

        return true;
      },
    );
  }

  // ================= DELETE =================
  static Future<void> _confirmDelete(
    BuildContext context,
    RecurringTransaction recurring,
  ) async {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final confirmed = await AppBottomSheet.showConfirm(
      context: context,
      title: 'Hapus ${recurring.name}?',
      message:
          'Transaksi rutin ini akan dihapus secara permanen dan tidak dapat dikembalikan.',
      isDanger: true,
      confirmText: 'Ya, Hapus',
      cancelText: 'Batal',
      content: _buildDeletePreview(recurring, currency),
    );

    if (confirmed == true && context.mounted) {
      Hive.box<RecurringTransaction>('recurring').delete(recurring.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🗑️ ${recurring.name} berhasil dihapus'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // ================= DELETE PREVIEW WIDGET =================
  static Widget _buildDeletePreview(
    RecurringTransaction recurring,
    NumberFormat currency,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final color = recurring.isIncome ? Colors.green : Colors.red;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  recurring.isIncome
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recurring.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currency.format(recurring.amount),
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: recurring.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  recurring.isActive ? 'Aktif' : 'Nonaktif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: recurring.isActive ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
