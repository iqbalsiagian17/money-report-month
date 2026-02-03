import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/debt.dart';
import '../models/transaction.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';

class DebtProvider extends ChangeNotifier {
  final Box<Debt> _box = Hive.box<Debt>('debts');

  // ============ GETTERS ============
  List<Debt> get debts =>
      _box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // Semua piutang (orang lain hutang ke kita)
  List<Debt> get receivables =>
      debts.where((d) => d.type == DebtType.receivable).toList();

  // Semua hutang (kita hutang ke orang lain)
  List<Debt> get payables =>
      debts.where((d) => d.type == DebtType.payable).toList();

  // Hutang/Piutang yang belum lunas
  List<Debt> get pendingDebts =>
      debts.where((d) => d.status != DebtStatus.paid).toList();

  // Hutang/Piutang yang sudah lunas
  List<Debt> get paidDebts =>
      debts.where((d) => d.status == DebtStatus.paid).toList();

  // Yang sudah jatuh tempo
  List<Debt> get overdueDebts => debts.where((d) => d.isOverdue).toList();

  // ============ TOTALS ============
  // Total piutang (yang harus kita terima)
  double get totalReceivables =>
      receivables.fold(0, (sum, d) => sum + d.remainingAmount);

  // Total hutang (yang harus kita bayar)
  double get totalPayables =>
      payables.fold(0, (sum, d) => sum + d.remainingAmount);

  // Net (piutang - hutang)
  double get netAmount => totalReceivables - totalPayables;

  // ============ CRUD ============
  Debt? getById(String id) {
    try {
      return _box.get(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addDebt(Debt debt) async {
    await _box.put(debt.id, debt);
    notifyListeners();
  }

  Future<void> updateDebt(Debt debt) async {
    await _box.put(debt.id, debt);
    notifyListeners();
  }

  Future<void> deleteDebt(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  // ============ PAYMENT ============
  /// Bayar hutang/piutang dengan transfer ke/dari wallet
  Future<bool> recordPayment({
    required String debtId,
    required double amount,
    required String walletId,
    required WalletProvider walletProvider,
    required TransactionProvider transactionProvider,
    String? note,
  }) async {
    final debt = _box.get(debtId);
    if (debt == null) return false;
    if (amount <= 0 || amount > debt.remainingAmount) return false;

    final wallet = walletProvider.getById(walletId);
    if (wallet == null) return false;

    // Untuk hutang (payable): kita bayar, saldo berkurang
    // Untuk piutang (receivable): kita terima, saldo bertambah
    if (debt.type == DebtType.payable && wallet.balance < amount) {
      return false; // Saldo tidak cukup untuk bayar hutang
    }

    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;

    // Buat payment record
    final payment = DebtPayment(
      id: timestamp.toString(),
      amount: amount,
      date: now,
      note: note,
      walletId: walletId,
    );

    // Update debt
    debt.addPayment(payment);
    await _box.put(debt.id, debt);

    // Buat transaksi
    final transaction = TransactionModel(
      id: '${timestamp}_debt',
      type: debt.type == DebtType.payable
          ? TransactionType.expense // Bayar hutang = pengeluaran
          : TransactionType.income, // Terima piutang = pemasukan
      amount: amount,
      walletId: walletId,
      categoryId: null,
      dateTime: now,
      note: debt.type == DebtType.payable
          ? 'Bayar hutang: ${debt.personName}'
          : 'Terima piutang: ${debt.personName}',
    );

    await transactionProvider.addTransaction(transaction);

    // Update wallet balance
    if (debt.type == DebtType.payable) {
      wallet.balance -= amount;
    } else {
      wallet.balance += amount;
    }
    await wallet.save();
    walletProvider.notifyListeners();

    notifyListeners();
    return true;
  }

  /// Tandai lunas tanpa transaksi (misal: dihapuskan)
  Future<void> markAsPaid(String debtId) async {
    final debt = _box.get(debtId);
    if (debt == null) return;

    debt.paidAmount = debt.amount;
    debt.status = DebtStatus.paid;
    await _box.put(debt.id, debt);
    notifyListeners();
  }

  // ============ FILTER ============
  List<Debt> filterDebts({
    DebtType? type,
    DebtStatus? status,
    bool? isOverdue,
    String? searchQuery,
  }) {
    return debts.where((debt) {
      if (type != null && debt.type != type) return false;
      if (status != null && debt.status != status) return false;
      if (isOverdue == true && !debt.isOverdue) return false;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!debt.personName.toLowerCase().contains(query) &&
            !(debt.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
