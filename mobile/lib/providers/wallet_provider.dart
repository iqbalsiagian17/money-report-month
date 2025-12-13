import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/wallet.dart';

class WalletProvider extends ChangeNotifier {
  final Box<Wallet> _box = Hive.box<Wallet>('wallets');

  List<Wallet> get wallets => _box.values.toList();

  double get totalBalance {
    return wallets
        .where((w) => !w.excludeFromTotal)
        .fold(0.0, (sum, w) => sum + w.balance);
  }

  List<Wallet> get cashWallets =>
      wallets.where((w) => w.type == WalletType.cash).toList();

  List<Wallet> get bankWallets =>
      wallets.where((w) => w.type == WalletType.bank).toList();

  List<Wallet> get emoneyWallets =>
      wallets.where((w) => w.type == WalletType.emoney).toList();

  Wallet? getById(String id) {
    try {
      return wallets.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addWallet(Wallet wallet) async {
    await _box.put(wallet.id, wallet);
    notifyListeners();
  }

  Future<void> updateWallet(Wallet wallet) async {
    await _box.put(wallet.id, wallet);
    notifyListeners();
  }

  Future<void> deleteWallet(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> updateBalance(String walletId, double amount) async {
    final wallet = getById(walletId);
    if (wallet != null) {
      wallet.balance += amount;
      await wallet.save();
      notifyListeners();
    }
  }

  Future<void> initDefaultWallets() async {
    if (wallets.isEmpty) {
      await addWallet(Wallet(
        id: 'cash_default',
        name: 'Cash',
        type: WalletType.cash,
        icon: '💵',
      ));
      await addWallet(Wallet(
        id: 'bca_default',
        name: 'BCA',
        type: WalletType.bank,
        icon: '🏦',
      ));
      await addWallet(Wallet(
        id: 'gopay_default',
        name: 'GoPay',
        type: WalletType.emoney,
        icon: '📱',
      ));
      await addWallet(Wallet(
        id: 'emergency_default',
        name: 'Dana Darurat',
        type: WalletType.bank,
        icon: '🛟',
        excludeFromTotal: true, // 🔥 penting
      ));
    }
  }
}
