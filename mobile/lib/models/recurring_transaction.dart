import 'package:hive/hive.dart';

part 'recurring_transaction.g.dart';

@HiveType(typeId: 7)
enum RecurringType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
}

@HiveType(typeId: 8)
class RecurringTransaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double amount;

  @HiveField(3)
  bool isIncome;

  @HiveField(4)
  String walletId;

  @HiveField(5)
  String? categoryId;

  @HiveField(6)
  RecurringType recurringType;

  @HiveField(7)
  int dayOfMonth;

  @HiveField(8)
  DateTime nextDueDate;

  @HiveField(9)
  bool isActive;

  RecurringTransaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.isIncome,
    required this.walletId,
    this.categoryId,
    required this.recurringType,
    required this.dayOfMonth,
    required this.nextDueDate,
    this.isActive = true,
  });
}
