import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_report_monthly/screens/saving/widgets/deposit_bottom_sheet.dart';
import 'package:money_report_monthly/screens/saving/widgets/saving_form_fields.dart';
import 'package:money_report_monthly/screens/saving/widgets/saving_header_icon.dart';
import 'package:money_report_monthly/screens/saving/widgets/saving_options.dart';
import 'package:money_report_monthly/screens/transaction/widgets/shared/currency_input_formatter.dart';
import 'package:money_report_monthly/widgets/bottom_sheet/app_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../models/saving_goal.dart';
import '../../providers/saving_provider.dart';
import '../../providers/wallet_provider.dart';

// Import widgets
import 'widgets/saving_card.dart';
import 'widgets/deposit_dialog.dart';

class SavingListScreen extends StatelessWidget {
  const SavingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // ANDROID → ikon hitam
        statusBarBrightness: Brightness.light, // IOS
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tabungan Saya'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark, // Android: ikon hitam
            statusBarBrightness: Brightness.light, // iOS: background terang
          ),
          actions: [
            IconButton(
              onPressed: () => _showAddSavingSheet(context),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        body: Consumer2<SavingProvider, WalletProvider>(
          builder: (context, savingProvider, walletProvider, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Active Savings
                if (savingProvider.activeSavings.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Target Aktif',
                    icon: Icons.flag_rounded,
                    count: savingProvider.activeSavings.length,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  ...savingProvider.activeSavings.map(
                    (saving) => SavingCard(
                      saving: saving,
                      wallet: walletProvider.getById(saving.targetWalletId),
                      onTap: () => SavingOptions.show(context, saving),
                      onDeposit: () => DepositBottomSheet.show(context, saving),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Completed Savings
                if (savingProvider.completedSavings.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Target Tercapai',
                    icon: Icons.check_circle_rounded,
                    count: savingProvider.completedSavings.length,
                    isDark: isDark,
                    isCompleted: true,
                  ),
                  const SizedBox(height: 12),
                  ...savingProvider.completedSavings.map(
                    (saving) => SavingCard(
                      saving: saving,
                      wallet: walletProvider.getById(saving.targetWalletId),
                      onTap: () => SavingOptions.show(context, saving),
                      onDeposit: () => DepositBottomSheet.show(context, saving),
                    ),
                  ),
                ],

                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context, SavingGoal saving) {
    showDialog(
      context: context,
      builder: (context) => DepositDialog(saving: saving),
    );
  }
}

void _showAddSavingSheet(BuildContext context) {
  final nameController = TextEditingController();
  final targetController = TextEditingController();
  String? selectedWalletId;
  DateTime? targetDate;

  AppBottomSheet.showForm<bool>(
    context: context,
    title: 'Target Tabungan Baru',
    submitText: 'Simpan Target',
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SavingHeaderIcon(),
          const SizedBox(height: 24),
          SavingNameField(controller: nameController),
          const SizedBox(height: 16),
          SavingTargetField(controller: targetController),
          const SizedBox(height: 16),
          Consumer<WalletProvider>(
            builder: (context, walletProvider, _) {
              return SavingWalletDropdown(
                selectedWalletId: selectedWalletId,
                wallets: walletProvider.wallets,
                onChanged: (value) {
                  setState(() => selectedWalletId = value);
                },
              );
            },
          ),
          const SizedBox(height: 16),
          SavingDatePicker(
            selectedDate: targetDate,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
              );
              if (picked != null) {
                setState(() => targetDate = picked);
              }
            },
          ),
        ],
      );
    },
    onSubmit: () async {
      if (selectedWalletId == null) return null;

      final savingProvider = context.read<SavingProvider>();

      final targetAmount =
          CurrencyInputFormatter.getNumericValue(targetController.text);

      await savingProvider.addSaving(
        SavingGoal(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: nameController.text.trim(),
          targetAmount: targetAmount,
          currentAmount: 0,
          targetWalletId: selectedWalletId!,
          createdAt: DateTime.now(),
          targetDate: targetDate,
          isCompleted: false,
        ),
      );

      return true;
    },
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final bool isDark;
  final bool isCompleted;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.count,
    required this.isDark,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? Colors.green : Theme.of(context).primaryColor;

    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        if (isCompleted) ...[
          const SizedBox(width: 6),
          const Text('🎉', style: TextStyle(fontSize: 16)),
        ],
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
