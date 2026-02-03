import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'quick_action_item.g.dart';

@HiveType(typeId: 17)
class QuickActionItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  String route;

  @HiveField(3)
  int iconCodePoint;

  @HiveField(4)
  int colorValue;

  @HiveField(5)
  int order;

  @HiveField(6)
  bool isVisible;

  QuickActionItem({
    required this.id,
    required this.label,
    required this.route,
    required this.iconCodePoint,
    required this.colorValue,
    required this.order,
    this.isVisible = true,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  // Factory untuk membuat dari SettingsTile
  factory QuickActionItem.fromSettingsTile({
    required String id,
    required String label,
    required String route,
    required IconData icon,
    required Color iconColor,
    required int order,
  }) {
    return QuickActionItem(
      id: id,
      label: label,
      route: route,
      iconCodePoint: icon.codePoint,
      colorValue: iconColor.value,
      order: order,
    );
  }
}
