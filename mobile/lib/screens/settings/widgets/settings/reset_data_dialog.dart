import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../../../providers/wallet_provider.dart';
import '../../../../providers/category_provider.dart';

class ResetDataDialog extends StatelessWidget {
  const ResetDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Semua Data? '),
      content: const Text(
        'Semua data transaksi, dompet, tabungan, dan pengaturan akan dihapus permanen.  Tindakan ini tidak dapat dibatalkan.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => _resetData(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Reset'),
        ),
      ],
    );
  }

  Future<void> _resetData(BuildContext context) async {
    await Hive.box('wallets').clear();
    await Hive.box('transactions').clear();
    await Hive.box('categories').clear();
    await Hive.box('savings').clear();
    await Hive.box('budgets').clear();
    await Hive.box('recurring').clear();
    await Hive.box('settings').clear();

    if (context.mounted) {
      await context.read<WalletProvider>().initDefaultWallets();
      await context.read<CategoryProvider>().initDefaultCategories();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua data berhasil direset'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
