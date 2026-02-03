// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_card_style.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BalanceCardStyleAdapter extends TypeAdapter<BalanceCardStyle> {
  @override
  final int typeId = 19;

  @override
  BalanceCardStyle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BalanceCardStyle(
      type: fields[0] as BalanceCardType,
      gradientColors: (fields[1] as List?)?.cast<int>(),
      showWalletCount: fields[2] as bool,
      showDate: fields[3] as bool,
      showIcon: fields[4] as bool,
      borderRadius: fields[5] as double?,
      elevation: fields[6] as double?,
      showBorder: fields[7] as bool?,
      borderColor: fields[8] as int?,
      borderWidth: fields[9] as double?,
      textColor: fields[10] as int?,
      backgroundColor: fields[11] as int?,
      useGradient: fields[12] as bool?,
      gradientDirection: fields[13] as String?,
      opacity: fields[14] as double?,
      showShadow: fields[15] as bool?,
      shadowBlur: fields[16] as double?,
      shadowSpread: fields[17] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, BalanceCardStyle obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.gradientColors)
      ..writeByte(2)
      ..write(obj.showWalletCount)
      ..writeByte(3)
      ..write(obj.showDate)
      ..writeByte(4)
      ..write(obj.showIcon)
      ..writeByte(5)
      ..write(obj.borderRadius)
      ..writeByte(6)
      ..write(obj.elevation)
      ..writeByte(7)
      ..write(obj.showBorder)
      ..writeByte(8)
      ..write(obj.borderColor)
      ..writeByte(9)
      ..write(obj.borderWidth)
      ..writeByte(10)
      ..write(obj.textColor)
      ..writeByte(11)
      ..write(obj.backgroundColor)
      ..writeByte(12)
      ..write(obj.useGradient)
      ..writeByte(13)
      ..write(obj.gradientDirection)
      ..writeByte(14)
      ..write(obj.opacity)
      ..writeByte(15)
      ..write(obj.showShadow)
      ..writeByte(16)
      ..write(obj.shadowBlur)
      ..writeByte(17)
      ..write(obj.shadowSpread);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BalanceCardStyleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BalanceCardTypeAdapter extends TypeAdapter<BalanceCardType> {
  @override
  final int typeId = 18;

  @override
  BalanceCardType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BalanceCardType.gradient;
      case 1:
        return BalanceCardType.glass;
      case 2:
        return BalanceCardType.minimal;
      case 3:
        return BalanceCardType.neon;
      case 4:
        return BalanceCardType.card;
      case 5:
        return BalanceCardType.modern;
      case 6:
        return BalanceCardType.custom;
      default:
        return BalanceCardType.gradient;
    }
  }

  @override
  void write(BinaryWriter writer, BalanceCardType obj) {
    switch (obj) {
      case BalanceCardType.gradient:
        writer.writeByte(0);
        break;
      case BalanceCardType.glass:
        writer.writeByte(1);
        break;
      case BalanceCardType.minimal:
        writer.writeByte(2);
        break;
      case BalanceCardType.neon:
        writer.writeByte(3);
        break;
      case BalanceCardType.card:
        writer.writeByte(4);
        break;
      case BalanceCardType.modern:
        writer.writeByte(5);
        break;
      case BalanceCardType.custom:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BalanceCardTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
