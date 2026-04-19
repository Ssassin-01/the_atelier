// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BusinessTransactionAdapter extends TypeAdapter<BusinessTransaction> {
  @override
  final int typeId = 5;

  @override
  BusinessTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BusinessTransaction(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      type: fields[2] as String,
      amount: fields[3] as double,
      category: fields[4] as String,
      description: fields[5] as String,
      relatedItemId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BusinessTransaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.relatedItemId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
