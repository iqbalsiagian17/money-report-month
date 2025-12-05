import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 6)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  double limitAmount;

  @HiveField(3)
  int month;

  @HiveField(4)
  int year;

  Budget({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.year,
  });
}
