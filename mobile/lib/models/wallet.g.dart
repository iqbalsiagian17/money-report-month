// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 1;

  @override
  Wallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wallet(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as WalletType,
      balance: fields[3] as double,
      icon: fields[4] as String?,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WalletTypeAdapter extends TypeAdapter<WalletType> {
  @override
  final int typeId = 0;

  @override
  WalletType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WalletType.cash;
      case 1:
        return WalletType.bank;
      case 2:
        return WalletType.emoney;
      default:
        return WalletType.cash;
    }
  }

  @override
  void write(BinaryWriter writer, WalletType obj) {
    switch (obj) {
      case WalletType.cash:
        writer.writeByte(0);
        break;
      case WalletType.bank:
        writer.writeByte(1);
        break;
      case WalletType.emoney:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
