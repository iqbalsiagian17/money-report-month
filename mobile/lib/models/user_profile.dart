import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 10)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double dailyLimit;

  @HiveField(2)
  bool isDailyLimitEnabled;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  double weekendLimit;

  @HiveField(5)
  bool isWeekendLimitEnabled;

  @HiveField(6)
  List<String> dailyLimitCategories; // Kategori yang kena limit harian

  @HiveField(7)
  List<String> weekendLimitCategories; // Kategori yang kena limit weekend

  @HiveField(8)
  List<String> unlimitedCategories; // Kategori tanpa limit

  UserProfile({
    required this.name,
    this.dailyLimit = 100000,
    this.isDailyLimitEnabled = false,
    this.weekendLimit = 300000,
    this.isWeekendLimitEnabled = false,
    List<String>? dailyLimitCategories,
    List<String>? weekendLimitCategories,
    List<String>? unlimitedCategories,
    DateTime? createdAt,
  })  : dailyLimitCategories = dailyLimitCategories ?? [],
        weekendLimitCategories = weekendLimitCategories ?? [],
        unlimitedCategories = unlimitedCategories ?? [],
        createdAt = createdAt ?? DateTime.now();
}
