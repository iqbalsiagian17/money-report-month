import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  final Box _box = Hive.box('settings');

  ThemeMode get themeMode {
    final isDark = _box.get('isDarkMode', defaultValue: false);
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  Color get primaryColor {
    final colorValue = _box.get('primaryColor', defaultValue: 0xFF6C63FF);
    return Color(colorValue);
  }

  Future<void> toggleTheme() async {
    await _box.put('isDarkMode', !isDarkMode);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    await _box.put('primaryColor', color.value);
    notifyListeners();
  }

  List<Color> get availableColors => [
        const Color(0xFF6C63FF),
        const Color(0xFF00BFA5),
        const Color(0xFFFF6B6B),
        const Color(0xFFFFB74D),
        const Color(0xFF64B5F6),
        const Color(0xFFBA68C8),
        const Color(0xFF4DB6AC),
        const Color(0xFFFFD54F),
      ];
}
