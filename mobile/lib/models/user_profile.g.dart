// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 10;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      dailyLimit: fields[1] as double,
      isDailyLimitEnabled: fields[2] as bool,
      weekendLimit: fields[4] as double,
      isWeekendLimitEnabled: fields[5] as bool,
      dailyLimitCategories: (fields[6] as List?)?.cast<String>(),
      weekendLimitCategories: (fields[7] as List?)?.cast<String>(),
      unlimitedCategories: (fields[8] as List?)?.cast<String>(),
      createdAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.dailyLimit)
      ..writeByte(2)
      ..write(obj.isDailyLimitEnabled)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.weekendLimit)
      ..writeByte(5)
      ..write(obj.isWeekendLimitEnabled)
      ..writeByte(6)
      ..write(obj.dailyLimitCategories)
      ..writeByte(7)
      ..write(obj.weekendLimitCategories)
      ..writeByte(8)
      ..write(obj.unlimitedCategories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
