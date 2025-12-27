import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_report_monthly/screens/wallet/widgets/wallet_options_sheet.dart';
import 'package:provider/provider.dart';
import '../../models/wallet.dart';
import '../../providers/wallet_provider.dart';

// Widgets
import 'widgets/total_balance_card.dart';
import 'widgets/wallet_section.dart';

// Bottom Sheet System
import '../../widgets/bottom_sheet/app_bottom_sheet.dart';

class WalletListScreen extends StatelessWidget {
  const WalletListScreen({super.key});

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
          title: const Text('Dompet Saya'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          actions: [
            IconButton(
              onPressed: () => _showAddWalletForm(context),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        body: Consumer<WalletProvider>(
          builder: (context, provider, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TotalBalanceCard(totalBalance: provider.totalBalance),
                const SizedBox(height: 24),
                WalletSection(
                  title: 'Cash',
                  icon: Icons.payments_rounded,
                  iconColor: Colors.green,
                  wallets: provider.cashWallets,
                  onWalletTap: (wallet) => _showWalletOptions(context, wallet),
                ),
                WalletSection(
                  title: 'Bank',
                  icon: Icons.account_balance_rounded,
                  iconColor: Colors.blue,
                  wallets: provider.bankWallets,
                  onWalletTap: (wallet) => _showWalletOptions(context, wallet),
                ),
                WalletSection(
                  title: 'E-Money',
                  icon: Icons.smartphone_rounded,
                  iconColor: Colors.orange,
                  wallets: provider.emoneyWallets,
                  onWalletTap: (wallet) => _showWalletOptions(context, wallet),
                ),
                if (provider.wallets.isEmpty) _buildEmptyState(context),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada dompet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan dompet pertamamu',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showAddWalletForm(BuildContext context) {
    final nameController = TextEditingController();
    WalletType selectedType = WalletType.cash;

    AppBottomSheet.showForm<Wallet>(
      context: context,
      title: 'Tambah Dompet',
      subtitle: 'Buat dompet baru untuk pencatatan keuangan',
      submitText: 'Simpan',
      cancelText: 'Batal',
      builder: (context, setState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nama Dompet',
                hintText: 'Contoh: Dompet Utama',
                prefixIcon: Icon(
                  getWalletTypeIcon(selectedType),
                  color: getWalletTypeColor(selectedType),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama dompet wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Jenis Dompet',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Wallet Type Selector - Card Style
            ...WalletType.values.map((type) {
              final isSelected = selectedType == type;
              return GestureDetector(
                onTap: () => setState(() => selectedType = type),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? getWalletTypeColor(type).withOpacity(0.1)
                        : (isDark ? Colors.grey[850] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? getWalletTypeColor(type)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Radio indicator
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? getWalletTypeColor(type)
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: getWalletTypeColor(type),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),

                      // Icon
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: getWalletTypeColor(type).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          getWalletTypeIcon(type),
                          color: getWalletTypeColor(type),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getWalletTypeLabel(type),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              getWalletTypeDescription(type),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
      onSubmit: () async {
        final provider = context.read<WalletProvider>();

        final wallet = Wallet(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: nameController.text.trim(),
          type: selectedType,
          balance: 0,
          icon: getWalletTypeIconName(selectedType),
          createdAt: DateTime.now(),
        );

        await provider.addWallet(wallet);

        return wallet;
      },
    );
  }

  void _showWalletOptions(BuildContext context, Wallet wallet) {
    WalletOptions.show(context, wallet);
  }

  // ================= HELPER FUNCTIONS =================

  static IconData getWalletTypeIcon(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return Icons.payments_rounded;
      case WalletType.bank:
        return Icons.account_balance_rounded;
      case WalletType.emoney:
        return Icons.smartphone_rounded;
    }
  }

  static Color getWalletTypeColor(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return Colors.green;
      case WalletType.bank:
        return Colors.blue;
      case WalletType.emoney:
        return Colors.orange;
    }
  }

  static String getWalletTypeLabel(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return 'Cash';
      case WalletType.bank:
        return 'Bank';
      case WalletType.emoney:
        return 'E-Money';
    }
  }

  static String getWalletTypeDescription(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return 'Uang tunai di dompet fisik';
      case WalletType.bank:
        return 'Rekening bank atau tabungan';
      case WalletType.emoney:
        return 'GoPay, OVO, Dana, ShopeePay, dll';
    }
  }

  static String getWalletTypeIconName(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return 'payments';
      case WalletType.bank:
        return 'account_balance';
      case WalletType.emoney:
        return 'smartphone';
    }
  }
}
