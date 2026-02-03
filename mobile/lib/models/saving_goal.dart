import 'package:hive/hive.dart';

part 'saving_goal.g.dart';

@HiveType(typeId: 5)
class SavingGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double currentAmount;

  @HiveField(4)
  String targetWalletId; 

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? targetDate;

  @HiveField(7)
  bool isCompleted;

  SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.targetWalletId,
    DateTime? createdAt,
    this.targetDate,
    this.isCompleted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount) : 0;

  double get remaining => targetAmount - currentAmount;
}
