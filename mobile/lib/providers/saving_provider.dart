import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/saving_goal.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';

class SavingProvider extends ChangeNotifier {
  final Box<SavingGoal> _box = Hive.box<SavingGoal>('savings');

  List<SavingGoal> get savings => _box.values.toList();

  List<SavingGoal> get activeSavings =>
      savings.where((s) => !s.isCompleted).toList();

  List<SavingGoal> get completedSavings =>
      savings.where((s) => s.isCompleted).toList();

  SavingGoal? getById(String id) {
    try {
      return _box.get(id);
    } catch (_) {
      return null;
    }
  }

  // ================= ADD =================
  Future<void> addSaving(SavingGoal saving) async {
    await _box.put(saving.id, saving);
    notifyListeners();
  }

  // ================= UPDATE =================
  Future<void> updateSaving(SavingGoal saving) async {
    await _box.put(saving.id, saving);
    notifyListeners();
  }

  // ================= DELETE =================
  Future<void> deleteSaving(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  // ================= DEPOSIT WITH TRANSFER (SINGLE TRANSACTION) =================
  Future<bool> depositWithTransfer({
    required String savingId,
    required double amount,
    required String fromWalletId,
    required WalletProvider walletProvider,
    required TransactionProvider transactionProvider,
  }) async {
    if (amount <= 0) return false;

    final saving = _box.get(savingId);
    if (saving == null) return false;

    // Validasi: wallet sumber tidak boleh sama dengan wallet tujuan
    if (fromWalletId == saving.targetWalletId) {
      return false;
    }

    // Validasi: cek saldo wallet sumber
    final fromWallet = walletProvider.getById(fromWalletId);
    if (fromWallet == null || fromWallet.balance < amount) {
      return false;
    }

    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;

    // ✅ UPDATED: Buat SATU transaksi transfer saja
    final transaction = TransactionModel(
      id: '${timestamp}_saving_transfer',
      type: TransactionType.transfer,
      amount: amount,
      walletId: fromWalletId, // Wallet sumber
      toWalletId: saving.targetWalletId, // Wallet tujuan
      categoryId: null,
      dateTime: now,
      note: 'Setor tabungan: ${saving.name}',
      savingGoalId: saving.id, // ✅ Track saving goal
    );

    // Simpan transaksi (hanya 1)
    await transactionProvider.addTransaction(transaction);

    // Transfer saldo antar wallet
    await walletProvider.transferById(
      fromWalletId: fromWalletId,
      toWalletId: saving.targetWalletId,
      amount: amount,
    );

    // Update progress tabungan
    saving.currentAmount += amount;
    if (saving.currentAmount >= saving.targetAmount) {
      saving.isCompleted = true;
    }

    await _box.put(saving.id, saving);
    notifyListeners();

    return true;
  }

  // ================= DEPOSIT SIMPLE =================
  Future<void> deposit(String savingId, double amount) async {
    if (amount <= 0) return;

    final saving = _box.get(savingId);
    if (saving == null) return;

    saving.currentAmount += amount;

    if (saving.currentAmount >= saving.targetAmount) {
      saving.isCompleted = true;
    }

    await _box.put(saving.id, saving);
    notifyListeners();
  }
}
