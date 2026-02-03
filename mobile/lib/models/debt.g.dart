// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtAdapter extends TypeAdapter<Debt> {
  @override
  final int typeId = 15;

  @override
  Debt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Debt(
      id: fields[0] as String,
      type: fields[1] as DebtType,
      personName: fields[2] as String,
      personPhone: fields[3] as String?,
      amount: fields[4] as double,
      paidAmount: fields[5] as double,
      description: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
      dueDate: fields[8] as DateTime?,
      status: fields[9] as DebtStatus,
      walletId: fields[10] as String?,
      payments: (fields[11] as List?)?.cast<DebtPayment>(),
    );
  }

  @override
  void write(BinaryWriter writer, Debt obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.personName)
      ..writeByte(3)
      ..write(obj.personPhone)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.paidAmount)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.dueDate)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.walletId)
      ..writeByte(11)
      ..write(obj.payments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DebtPaymentAdapter extends TypeAdapter<DebtPayment> {
  @override
  final int typeId = 16;

  @override
  DebtPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DebtPayment(
      id: fields[0] as String,
      amount: fields[1] as double,
      date: fields[2] as DateTime?,
      note: fields[3] as String?,
      walletId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DebtPayment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.walletId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DebtTypeAdapter extends TypeAdapter<DebtType> {
  @override
  final int typeId = 13;

  @override
  DebtType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DebtType.receivable;
      case 1:
        return DebtType.payable;
      default:
        return DebtType.receivable;
    }
  }

  @override
  void write(BinaryWriter writer, DebtType obj) {
    switch (obj) {
      case DebtType.receivable:
        writer.writeByte(0);
        break;
      case DebtType.payable:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DebtStatusAdapter extends TypeAdapter<DebtStatus> {
  @override
  final int typeId = 14;

  @override
  DebtStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DebtStatus.pending;
      case 1:
        return DebtStatus.partial;
      case 2:
        return DebtStatus.paid;
      default:
        return DebtStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, DebtStatus obj) {
    switch (obj) {
      case DebtStatus.pending:
        writer.writeByte(0);
        break;
      case DebtStatus.partial:
        writer.writeByte(1);
        break;
      case DebtStatus.paid:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
