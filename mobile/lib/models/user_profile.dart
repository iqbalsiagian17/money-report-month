import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 10)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  // ⭐ FOTO PROFIL (BARU)
  @HiveField(1)
  String? photoPath; // local path / asset / url

  @HiveField(2)
  double dailyLimit;

  @HiveField(3)
  bool isDailyLimitEnabled;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  double weekendLimit;

  @HiveField(6)
  bool isWeekendLimitEnabled;

  @HiveField(7)
  List<String> dailyLimitCategories;

  @HiveField(8)
  List<String> weekendLimitCategories;

  @HiveField(9)
  List<String> unlimitedCategories;

  UserProfile({
    required this.name,
    this.photoPath,
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
