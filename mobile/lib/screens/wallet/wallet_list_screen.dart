import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/wallet.dart';
import '../../providers/wallet_provider.dart';

class WalletListScreen extends StatelessWidget {
  const WalletListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet Saya'),
        actions: [
          IconButton(
            onPressed: () => _showAddWalletDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<WalletProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Total Balance
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Saldo',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(provider.totalBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cash Wallets
              if (provider.cashWallets.isNotEmpty) ...[
                _buildSectionHeader('💵 Cash'),
                ...provider.cashWallets.map((w) => _buildWalletTile(context, w, currencyFormat)),
                const SizedBox(height: 16),
              ],

              // Bank Wallets
              if (provider.bankWallets.isNotEmpty) ...[
                _buildSectionHeader('🏦 Bank'),
                ...provider.bankWallets.map((w) => _buildWalletTile(context, w, currencyFormat)),
                const SizedBox(height: 16),
              ],

              // E-Money Wallets
              if (provider.emoneyWallets.isNotEmpty) ...[
                _buildSectionHeader('📱 E-Money'),
                ...provider.emoneyWallets.map((w) => _buildWalletTile(context, w, currencyFormat)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildWalletTile(BuildContext context, Wallet wallet, NumberFormat format) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              wallet.icon ??  '💰',
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          wallet.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(wallet.typeLabel),
        trailing: Text(
          format.format(wallet.balance),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
        onTap: () => _showWalletOptions(context, wallet),
      ),
    );
  }

  void _showAddWalletDialog(BuildContext context) {
    final nameController = TextEditingController();
    WalletType selectedType = WalletType.cash;
    String selectedIcon = '💰';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Dompet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Dompet',
                  hintText: 'Contoh: BCA, Gopay',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<WalletType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipe'),
                items: WalletType.values.map((type) {
                  String label = '';
                  switch (type) {
                    case WalletType.cash:
                      label = 'Cash';
                      break;
                    case WalletType.bank:
                      label = 'Bank';
                      break;
                    case WalletType.emoney:
                      label = 'E-Money';
                      break;
                  }
                  return DropdownMenuItem(value: type, child: Text(label));
                }).toList(),
                onChanged: (value) => setState(() => selectedType = value!),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ['💰', '💵', '🏦', '💳', '📱', '💎'].map((icon) {
                  return ChoiceChip(
                    label: Text(icon),
                    selected: selectedIcon == icon,
                    onSelected: (selected) {
                      if (selected) setState(() => selectedIcon = icon);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final wallet = Wallet(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    type: selectedType,
                    icon: selectedIcon,
                  );
                  context.read<WalletProvider>().addWallet(wallet);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletOptions(BuildContext context, Wallet wallet) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              wallet.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Dompet'),
              onTap: () {
                Navigator.pop(context);
                _showEditWalletDialog(context, wallet);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus Dompet', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteWallet(context, wallet);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditWalletDialog(BuildContext context, Wallet wallet) {
    final nameController = TextEditingController(text: wallet.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Dompet'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nama Dompet'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              wallet.name = nameController.text;
              context.read<WalletProvider>().updateWallet(wallet);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteWallet(BuildContext context, Wallet wallet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Dompet? '),
        content: Text('Apakah Anda yakin ingin menghapus "${wallet.name}"? '),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<WalletProvider>().deleteWallet(wallet.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}