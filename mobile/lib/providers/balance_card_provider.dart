import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/balance_card_style.dart';

class BalanceCardProvider extends ChangeNotifier {
  late Box _box;
  bool _isInitialized = false;

  static const String _key = 'balance_card_style';

  BalanceCardProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = Hive.box('settings');
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing BalanceCardProvider: $e');
    }
  }

  BalanceCardStyle get currentStyle {
    if (!_isInitialized) return BalanceCardStyle.defaultGradient;

    try {
      final stored = _box.get(_key);
      if (stored is BalanceCardStyle) {
        return stored;
      }
    } catch (e) {
      debugPrint('Error loading balance card style: $e');
    }
    return BalanceCardStyle.defaultGradient;
  }

  Future<void> updateStyle(BalanceCardStyle style) async {
    if (!_isInitialized) return;

    try {
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating style: $e');
    }
  }

  Future<void> updateType(BalanceCardType type) async {
    if (!_isInitialized) return;

    try {
      final style = currentStyle;
      style.type = type;
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating type: $e');
    }
  }

  Future<void> updateColors(List<Color> colors) async {
    if (!_isInitialized) return;

    try {
      final style = currentStyle;
      style.gradientColors = colors.map((c) => c.value).toList();
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating colors: $e');
    }
  }

  // ✅ UPDATED: Extended update methods with proper null handling
  Future<void> updateBorderRadius(double value) async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.borderRadius = value;
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating border radius: $e');
    }
  }

  Future<void> updateElevation(double value) async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.elevation = value;
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating elevation: $e');
    }
  }

  Future<void> toggleBorder() async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.showBorder = !(style.showBorder ?? false);
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling border: $e');
    }
  }

  Future<void> updateBorderColor(Color color) async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.borderColor = color.value;
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating border color: $e');
    }
  }

  Future<void> updateBorderWidth(double value) async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.borderWidth = value;
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating border width: $e');
    }
  }

  Future<void> updateTextColor(Color? color) async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.textColor = color?.value;
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating text color: $e');
    }
  }

  Future<void> updateBackgroundColor(Color? color) async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.backgroundColor = color?.value;
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating background color: $e');
    }
  }

  Future<void> toggleGradient() async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.useGradient = !(style.useGradient ?? true);
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling gradient: $e');
    }
  }

  Future<void> updateGradientDirection(String direction) async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.gradientDirection = direction;
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating gradient direction: $e');
    }
  }

  Future<void> updateOpacity(double value) async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.opacity = value;
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating opacity: $e');
    }
  }

  Future<void> toggleShadow() async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.showShadow = !(style.showShadow ?? true);
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling shadow: $e');
    }
  }

  Future<void> updateShadowBlur(double value) async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.shadowBlur = value;
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating shadow blur: $e');
    }
  }

  Future<void> toggleWalletCount() async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.showWalletCount = !style.showWalletCount;
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling wallet count: $e');
    }
  }

  Future<void> toggleDate() async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.showDate = !style.showDate;
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling date: $e');
    }
  }

  Future<void> toggleIcon() async {
    if (!_isInitialized) return;
    try {
      final style = currentStyle;
      style.showIcon = !style.showIcon;
      await _box.put(_key, style);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling icon: $e');
    }
  }

  List<BalanceCardStyle> get presetStyles => [
        BalanceCardStyle.defaultGradient,
        BalanceCardStyle.glass,
        BalanceCardStyle.minimal,
        BalanceCardStyle.neon,
        BalanceCardStyle.card,
        BalanceCardStyle.modern,
      ];
}
