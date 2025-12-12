// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_notification.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomNotificationAdapter extends TypeAdapter<CustomNotification> {
  @override
  final int typeId = 11;

  @override
  CustomNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomNotification(
      id: fields[0] as String,
      title: fields[1] as String,
      message: fields[2] as String,
      hour: fields[3] as int,
      minute: fields[4] as int,
      isEnabled: fields[5] as bool,
      isDefault: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CustomNotification obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.hour)
      ..writeByte(4)
      ..write(obj.minute)
      ..writeByte(5)
      ..write(obj.isEnabled)
      ..writeByte(6)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
