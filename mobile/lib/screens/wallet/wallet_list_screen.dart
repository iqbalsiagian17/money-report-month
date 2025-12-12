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
        statusBarIconBrightness: Brightness.dark, // ANDROID
        statusBarBrightness: Brightness.light, // IOS
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dompet Saya'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
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
                  icon: '💵',
                  wallets: provider.cashWallets,
                  onWalletTap: (wallet) => _showWalletOptions(context, wallet),
                ),
                WalletSection(
                  title: 'Bank',
                  icon: '🏦',
                  wallets: provider.bankWallets,
                  onWalletTap: (wallet) => _showWalletOptions(context, wallet),
                ),
                WalletSection(
                  title: 'E-Money',
                  icon: '📱',
                  wallets: provider.emoneyWallets,
                  onWalletTap: (wallet) => _showWalletOptions(context, wallet),
                ),
                if (provider.wallets.isEmpty) _buildEmptyState(context),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddWalletForm(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah Dompet'),
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================
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

  // ================= ADD WALLET =================
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Dompet',
                hintText: 'Contoh: Dompet Utama',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama dompet wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Jenis Dompet',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: WalletType.values.map((type) {
                final isSelected = selectedType == type;
                return ChoiceChip(
                  label: Text(_walletTypeLabel(type)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => selectedType = type);
                  },
                );
              }).toList(),
            ),
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
          icon: _walletTypeIcon(selectedType),
          createdAt: DateTime.now(),
        );

        await provider.addWallet(wallet);

        return wallet; // ⬅️ auto close bottom sheet
      },
    );
  }

  String _walletTypeLabel(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return 'Cash';
      case WalletType.bank:
        return 'Bank';
      case WalletType.emoney:
        return 'E-Money';
    }
  }

  String _walletTypeIcon(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return '💵';
      case WalletType.bank:
        return '🏦';
      case WalletType.emoney:
        return '📱';
    }
  }

  // ================= WALLET OPTIONS =================
  void _showWalletOptions(BuildContext context, Wallet wallet) {
    WalletOptions.show(context, wallet);
  }
}
