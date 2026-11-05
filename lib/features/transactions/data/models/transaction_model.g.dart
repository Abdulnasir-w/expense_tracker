// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final typeId = 0;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel()
      ..title = fields[0] as String
      ..amount = (fields[1] as num).toDouble()
      ..type = fields[2] as TransactionTypeHive
      ..date = fields[3] as DateTime
      ..category = fields[4] as String
      ..note = fields[5] as String?;
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeHiveAdapter extends TypeAdapter<TransactionTypeHive> {
  @override
  final typeId = 1;

  @override
  TransactionTypeHive read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionTypeHive.income;
      case 1:
        return TransactionTypeHive.expense;
      default:
        return TransactionTypeHive.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionTypeHive obj) {
    switch (obj) {
      case TransactionTypeHive.income:
        writer.writeByte(0);
      case TransactionTypeHive.expense:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
