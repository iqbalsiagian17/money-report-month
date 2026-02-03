import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/saving_goal.dart';
import '../../../providers/saving_provider.dart';
import '../../../widgets/bottom_sheet/app_bottom_sheet.dart';
import '../../../widgets/bottom_sheet/variants/options_bottom_sheet.dart';
import '../../../screens/transaction/widgets/shared/currency_input_formatter.dart';
import 'deposit_bottom_sheet.dart'; // ✅ Import DepositBottomSheet

enum SavingOptionAction {
  deposit,
  edit,
  delete,
}

class SavingOptions {
  static Future<void> show(
    BuildContext context,
    SavingGoal saving,
  ) async {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final action = await AppBottomSheet.showOptions<SavingOptionAction>(
      context: context,
      title: 'Opsi Tabungan',
      subtitle:
          '${saving.name}\n${currency.format(saving.currentAmount)} / ${currency.format(saving.targetAmount)}',
      options: [
        if (!saving.isCompleted)
          const BottomSheetOption(
            title: 'Setor Tabungan',
            subtitle: 'Tambah dana ke tabungan',
            icon: Icons.add_circle_rounded,
            iconColor: Colors.green,
            value: SavingOptionAction.deposit,
          ),
        const BottomSheetOption(
          title: 'Edit Target',
          subtitle: 'Ubah nama atau target',
          icon: Icons.edit_rounded,
          iconColor: Colors.blue,
          value: SavingOptionAction.edit,
        ),
        const BottomSheetOption(
          title: 'Hapus Target',
          subtitle: 'Hapus target tabungan',
          icon: Icons.delete_forever_rounded,
          iconColor: Colors.red,
          isDestructive: true,
          value: SavingOptionAction.delete,
        ),
      ],
    );

    if (!context.mounted || action == null) return;

    switch (action) {
      case SavingOptionAction.deposit:
        // ✅ Gunakan DepositBottomSheet
        DepositBottomSheet.show(context, saving);
        break;
      case SavingOptionAction.edit:
        _showEditForm(context, saving);
        break;
      case SavingOptionAction.delete:
        _confirmDelete(context, saving);
        break;
    }
  }

  // ================= EDIT =================
  static void _showEditForm(
    BuildContext context,
    SavingGoal saving,
  ) {
    final nameController = TextEditingController(text: saving.name);
    final targetController = TextEditingController(
      text: NumberFormat('#,###', 'id_ID').format(saving.targetAmount.toInt()),
    );

    AppBottomSheet.showForm<bool>(
      context: context,
      title: 'Edit Target',
      submitText: 'Simpan',
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama Target',
                prefixIcon: Icon(Icons.flag_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: targetController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Target Nominal',
                prefixText: 'Rp ',
                prefixIcon: Icon(Icons.monetization_on_rounded),
              ),
              validator: (v) {
                final amount = CurrencyInputFormatter.getNumericValue(v ?? '');
                if (amount <= 0) return 'Target harus lebih dari 0';
                return null;
              },
            ),
          ],
        );
      },
      onSubmit: () async {
        final target =
            CurrencyInputFormatter.getNumericValue(targetController.text);

        saving.name = nameController.text.trim();
        saving.targetAmount = target;

        // Reset completed jika target dinaikkan
        if (saving.currentAmount < saving.targetAmount) {
          saving.isCompleted = false;
        }

        await context.read<SavingProvider>().updateSaving(saving);

        return true;
      },
    );
  }

  // ================= DELETE =================
  static Future<void> _confirmDelete(
    BuildContext context,
    SavingGoal saving,
  ) async {
    final confirmed = await AppBottomSheet.showConfirm(
      context: context,
      title: 'Hapus Target',
      message:
          'Target "${saving.name}" akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.',
      isDanger: true,
      confirmText: 'Hapus',
      icon: Icons.delete_forever_rounded,
    );

    if (confirmed == true && context.mounted) {
      await context.read<SavingProvider>().deleteSaving(saving.id);
    }
  }
}
