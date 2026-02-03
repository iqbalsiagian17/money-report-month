import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
  @HiveField(2)
  transfer,
}

@HiveType(typeId: 3)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  TransactionType type;

  @HiveField(2)
  String
      walletId; // Wallet utama (sumber untuk transfer/expense, tujuan untuk income)

  @HiveField(3)
  String? categoryId;

  @HiveField(4)
  double amount;

  @HiveField(5)
  DateTime dateTime;

  @HiveField(6)
  String? note;

  // ✅ NEW: Untuk transfer - wallet tujuan
  @HiveField(7)
  String? toWalletId;

  // ✅ NEW: Untuk tracking setor tabungan
  @HiveField(8)
  String? savingGoalId;

  TransactionModel({
    required this.id,
    required this.type,
    required this.walletId,
    this.categoryId,
    required this.amount,
    required this.dateTime,
    this.note,
    this.toWalletId, // ✅ NEW
    this.savingGoalId, // ✅ NEW
  });

  // ✅ Helper: Apakah ini transaksi transfer?
  bool get isTransfer => type == TransactionType.transfer && toWalletId != null;

  // ✅ Helper: Apakah ini setor tabungan?
  bool get isSavingDeposit => savingGoalId != null;
}
