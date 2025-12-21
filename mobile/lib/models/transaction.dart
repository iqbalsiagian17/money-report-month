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
  String walletId;

  @HiveField(3)
  String? categoryId;

  @HiveField(4)
  double amount;

  /// Wajib sesuai HiveService → dateTime
  @HiveField(5)
  DateTime dateTime;

  @HiveField(6)
  String? note; // <- nullable

  TransactionModel({
    required this.id,
    required this.type,
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.dateTime,
    this.note,
  });
}