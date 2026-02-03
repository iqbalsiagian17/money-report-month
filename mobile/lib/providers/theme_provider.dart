import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  Box get _box => Hive.isBoxOpen('settings')
      ? Hive.box('settings')
      : throw HiveError('Settings box is not open');

  // ✅ Cache values untuk menghindari akses Hive berulang
  bool? _cachedIsDarkMode;
  Color? _cachedPrimaryColor;

  ThemeMode get themeMode {
    _cachedIsDarkMode ??= _box.get('isDarkMode', defaultValue: false);
    return _cachedIsDarkMode! ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  Color get primaryColor {
    _cachedPrimaryColor ??=
        Color(_box.get('primaryColor', defaultValue: 0xFF6C63FF));
    return _cachedPrimaryColor!;
  }

  // ✅ Toggle dengan smooth update
  Future<void> toggleTheme() async {
    final newValue = !isDarkMode;

    // Update cache dulu (UI langsung responsive)
    _cachedIsDarkMode = newValue;

    // Notify di frame berikutnya untuk smooth animation
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    // Simpan ke storage di background
    await _box.put('isDarkMode', newValue);
  }

  Future<void> setPrimaryColor(Color color) async {
    if (_cachedPrimaryColor == color) return;

    _cachedPrimaryColor = color;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    await _box.put('primaryColor', color.value);
  }

  List<Color> get availableColors => const [
        Color(0xFF6C63FF),
        Color(0xFF00BFA5),
        Color(0xFFFF6B6B),
        Color(0xFFFFB74D),
        Color(0xFF64B5F6),
        Color(0xFFBA68C8),
        Color(0xFF4DB6AC),
        Color(0xFFFFD54F),
      ];
}
