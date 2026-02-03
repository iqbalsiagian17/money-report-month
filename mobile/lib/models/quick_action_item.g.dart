// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_action_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuickActionItemAdapter extends TypeAdapter<QuickActionItem> {
  @override
  final int typeId = 17;

  @override
  QuickActionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuickActionItem(
      id: fields[0] as String,
      label: fields[1] as String,
      route: fields[2] as String,
      iconCodePoint: fields[3] as int,
      colorValue: fields[4] as int,
      order: fields[5] as int,
      isVisible: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, QuickActionItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.route)
      ..writeByte(3)
      ..write(obj.iconCodePoint)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.order)
      ..writeByte(6)
      ..write(obj.isVisible);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickActionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
