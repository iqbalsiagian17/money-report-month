import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 4)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    this.isDefault = false,
  });
}
