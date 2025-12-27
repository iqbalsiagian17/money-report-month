import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_report_monthly/widgets/snack_helper.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import '../../models/recurring_transaction.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/bottom_sheet/app_bottom_sheet.dart';
import '../transaction/widgets/shared/currency_input_formatter.dart';

// Widgets
import 'widgets/recurring_section.dart';
import 'widgets/empty_recurring_state.dart';
import 'widgets/recurring_options.dart';
import 'widgets/recurring_form_fields.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  Box<RecurringTransaction> get _box =>
      Hive.box<RecurringTransaction>('recurring');

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaksi Rutin'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark, // Ikon status bar hitam
            statusBarBrightness: Brightness.light, // Untuk iOS
          ),
          actions: [
            IconButton(
              onPressed: () => _showAddRecurringSheet(context),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: _box.listenable(),
          builder: (context, Box<RecurringTransaction> box, _) {
            final recurring = box.values.toList();

            if (recurring.isEmpty) {
              return EmptyRecurringState(
                onCreateTap: () => _showAddRecurringSheet(context),
              );
            }

            final income = recurring.where((r) => r.isIncome).toList();
            final expense = recurring.where((r) => !r.isIncome).toList();
            final walletProvider = context.read<WalletProvider>();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                RecurringSection(
                  title: 'Pemasukan Rutin',
                  items: income,
                  getWallet: walletProvider.getById,
                  onItemTap: (item) => RecurringOptions.show(context, item),
                  color: Colors.green,
                ),
                if (income.isNotEmpty && expense.isNotEmpty)
                  const SizedBox(height: 28),
                RecurringSection(
                  title: 'Pengeluaran Rutin',
                  items: expense,
                  getWallet: walletProvider.getById,
                  onItemTap: (item) => RecurringOptions.show(context, item),
                  color: Colors.red,
                ),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
    );
  }

  // ================= ADD RECURRING =================
  void _showAddRecurringSheet(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    bool isIncome = false;
    String? selectedWalletId;
    RecurringType? recurringType;
    int? dayOfMonth;

    AppBottomSheet.showForm<bool>(
      context: context,
      title: 'Transaksi Rutin Baru',
      subtitle: 'Tambahkan transaksi yang berulang secara otomatis',
      submitText: 'Simpan',
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
              onChanged: (v) => setState(() => recurringType = v),
            ),
            const SizedBox(height: 16),
            if (recurringType == RecurringType.monthly ||
                recurringType == RecurringType.yearly)
              RecurringDayPicker(
                selectedDay: dayOfMonth ?? 1,
                recurringType: recurringType!,
                onChanged: (v) => setState(() => dayOfMonth = v),
              ),
          ],
        );
      },
      onSubmit: () async {
        // Validasi
        if (nameController.text.trim().isEmpty) {
          _showValidationError(context, 'Nama transaksi tidak boleh kosong');
          return null;
        }

        if (selectedWalletId == null) {
          _showValidationError(context, 'Pilih dompet terlebih dahulu');
          return null;
        }

        final amount =
            CurrencyInputFormatter.getNumericValue(amountController.text);
        if (amount <= 0) {
          _showValidationError(context, 'Nominal harus lebih dari 0');
          return null;
        }

        if (recurringType == null) {
          _showValidationError(
              context, 'Pilih periode transaksi terlebih dahulu');
          return null;
        }

        // Calculate next due date
        final now = DateTime.now();
        DateTime nextDue;

        switch (recurringType!) {
          case RecurringType.daily:
            nextDue = DateTime(now.year, now.month, now.day + 1);
            break;
          case RecurringType.weekly:
            nextDue = now.add(Duration(days: 7 - now.weekday + 1));
            break;
          case RecurringType.monthly:
            nextDue = DateTime(now.year, now.month, dayOfMonth ?? 1);
            if (!nextDue.isAfter(now)) {
              nextDue = DateTime(now.year, now.month + 1, dayOfMonth ?? 1);
            }
            break;
          case RecurringType.yearly:
            nextDue = DateTime(now.year + 1, now.month, now.day);
            break;
        }

        final recurring = RecurringTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: nameController.text.trim(),
          amount: amount,
          isIncome: isIncome,
          walletId: selectedWalletId!,
          recurringType: recurringType!,
          dayOfMonth: dayOfMonth!,
          nextDueDate: nextDue,
        );

        _box.put(recurring.id, recurring);

        // Show success
        if (context.mounted) {
          SnackHelper.success(
              context, '✅ ${recurring.name} berhasil ditambahkan');
        }

        return true;
      },
    );
  }

  void _showValidationError(BuildContext context, String message) {
    SnackHelper.error(context, message);
  }
}