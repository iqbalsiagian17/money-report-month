import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/wallet.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_tile.dart';

class WalletDetailScreen extends StatelessWidget {
  const WalletDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = ModalRoute.of(context)!.settings.arguments as Wallet;
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
      ),
      body: Consumer2<WalletProvider, TransactionProvider>(
        builder: (context, walletProvider, txProvider, _) {
          final currentWallet = walletProvider.getById(wallet.id);
          if (currentWallet == null) return const SizedBox();

          final transactions = txProvider.getByWallet(wallet.id);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Balance Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      currentWallet.icon ?? '💰',
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Saldo',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(currentWallet.balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Transaction History
              const Text(
                'Riwayat Transaksi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              if (transactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Belum ada transaksi',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...transactions.map((tx) => TransactionTile(transaction: tx)),
            ],
          );
        },
      ),
    );
  }
}
