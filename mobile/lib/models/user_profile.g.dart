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
      photoPath: fields[1] as String?,
      dailyLimit: fields[2] as double,
      isDailyLimitEnabled: fields[3] as bool,
      weekendLimit: fields[5] as double,
      isWeekendLimitEnabled: fields[6] as bool,
      dailyLimitCategories: (fields[7] as List?)?.cast<String>(),
      weekendLimitCategories: (fields[8] as List?)?.cast<String>(),
      unlimitedCategories: (fields[9] as List?)?.cast<String>(),
      createdAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.photoPath)
      ..writeByte(2)
      ..write(obj.dailyLimit)
      ..writeByte(3)
      ..write(obj.isDailyLimitEnabled)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.weekendLimit)
      ..writeByte(6)
      ..write(obj.isWeekendLimitEnabled)
      ..writeByte(7)
      ..write(obj.dailyLimitCategories)
      ..writeByte(8)
      ..write(obj.weekendLimitCategories)
      ..writeByte(9)
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
