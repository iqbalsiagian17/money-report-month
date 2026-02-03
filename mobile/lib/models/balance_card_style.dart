import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'balance_card_style.g.dart';

@HiveType(typeId: 18)
enum BalanceCardType {
  @HiveField(0)
  gradient,

  @HiveField(1)
  glass,

  @HiveField(2)
  minimal,

  @HiveField(3)
  neon,

  @HiveField(4)
  card,

  @HiveField(5)
  modern,

  @HiveField(6)
  custom, // ✅ NEW: Custom style
}

@HiveType(typeId: 19)
class BalanceCardStyle extends HiveObject {
  @HiveField(0)
  BalanceCardType type;

  @HiveField(1)
  List<int> gradientColors;

  @HiveField(2)
  bool showWalletCount;

  @HiveField(3)
  bool showDate;

  @HiveField(4)
  bool showIcon;

  // ✅ NEW: Extended customization properties - now nullable
  @HiveField(5)
  double? borderRadius;

  @HiveField(6)
  double? elevation;

  @HiveField(7)
  bool? showBorder;

  @HiveField(8)
  int? borderColor;

  @HiveField(9)
  double? borderWidth;

  @HiveField(10)
  int? textColor;

  @HiveField(11)
  int? backgroundColor;

  @HiveField(12)
  bool? useGradient;

  @HiveField(13)
  String?
      gradientDirection; // 'topLeft', 'topRight', 'bottomLeft', 'bottomRight', 'horizontal', 'vertical'

  @HiveField(14)
  double? opacity;

  @HiveField(15)
  bool? showShadow;

  @HiveField(16)
  double? shadowBlur;

  @HiveField(17)
  double? shadowSpread;

  BalanceCardStyle({
    this.type = BalanceCardType.gradient,
    List<int>? gradientColors,
    this.showWalletCount = true,
    this.showDate = true,
    this.showIcon = true,
    this.borderRadius = 24.0,
    this.elevation = 4.0,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 1.0,
    this.textColor,
    this.backgroundColor,
    this.useGradient = true,
    this.gradientDirection = 'topLeft',
    this.opacity = 1.0,
    this.showShadow = true,
    this.shadowBlur = 20.0,
    this.shadowSpread = 0.0,
  }) : gradientColors = gradientColors ?? [0xFF1A1A2E, 0xFF16213E, 0xFF0F3460];

  List<Color> get colors => gradientColors.map((c) => Color(c)).toList();

  Color? get borderColorValue =>
      borderColor != null ? Color(borderColor!) : null;
  Color? get textColorValue => textColor != null ? Color(textColor!) : null;
  Color? get backgroundColorValue =>
      backgroundColor != null ? Color(backgroundColor!) : null;

  // ✅ Add getters with default values
  double get borderRadiusValue => borderRadius ?? 24.0;
  double get elevationValue => elevation ?? 4.0;
  bool get showBorderValue => showBorder ?? false;
  double get borderWidthValue => borderWidth ?? 1.0;
  bool get useGradientValue => useGradient ?? true;
  String get gradientDirectionValue => gradientDirection ?? 'topLeft';
  double get opacityValue => opacity ?? 1.0;
  bool get showShadowValue => showShadow ?? true;
  double get shadowBlurValue => shadowBlur ?? 20.0;
  double get shadowSpreadValue => shadowSpread ?? 0.0;

  AlignmentGeometry get gradientBegin {
    switch (gradientDirectionValue) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topRight':
        return Alignment.topRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomRight':
        return Alignment.bottomRight;
      case 'horizontal':
        return Alignment.centerLeft;
      case 'vertical':
        return Alignment.topCenter;
      default:
        return Alignment.topLeft;
    }
  }

  AlignmentGeometry get gradientEnd {
    switch (gradientDirectionValue) {
      case 'topLeft':
        return Alignment.bottomRight;
      case 'topRight':
        return Alignment.bottomLeft;
      case 'bottomLeft':
        return Alignment.topRight;
      case 'bottomRight':
        return Alignment.topLeft;
      case 'horizontal':
        return Alignment.centerRight;
      case 'vertical':
        return Alignment.bottomCenter;
      default:
        return Alignment.bottomRight;
    }
  }

  // Predefined styles
  static BalanceCardStyle get defaultGradient => BalanceCardStyle(
        type: BalanceCardType.gradient,
        gradientColors: [0xFF1A1A2E, 0xFF16213E, 0xFF0F3460],
      );

  static BalanceCardStyle get glass => BalanceCardStyle(
        type: BalanceCardType.glass,
        gradientColors: [0x40FFFFFF, 0x20FFFFFF],
      );

  static BalanceCardStyle get minimal => BalanceCardStyle(
        type: BalanceCardType.minimal,
        gradientColors: [0xFFF5F5F5, 0xFFE0E0E0],
        useGradient: false,
      );

  static BalanceCardStyle get neon => BalanceCardStyle(
        type: BalanceCardType.neon,
        gradientColors: [0xFF0F0F0F, 0xFF1A1A1A],
      );

  static BalanceCardStyle get card => BalanceCardStyle(
        type: BalanceCardType.card,
        gradientColors: [0xFF2C3E50, 0xFF34495E],
      );

  static BalanceCardStyle get modern => BalanceCardStyle(
        type: BalanceCardType.modern,
        gradientColors: [0xFF667EEA, 0xFF764BA2],
      );
}
