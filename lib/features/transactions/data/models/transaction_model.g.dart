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
      ..id = fields[0] as String
      ..type = fields[1] as TransactionTypeHive
      ..amountMinor = (fields[2] as num).toInt()
      ..currencyCode = fields[3] as String
      ..categoryId = fields[4] as String
      ..accountId = fields[5] as String
      ..toAccountId = fields[6] as String?
      ..date = fields[7] as DateTime
      ..title = fields[8] as String
      ..note = fields[9] as String?
      ..exchangeRate = (fields[10] as num?)?.toDouble()
      ..baseAmountMinor = (fields[11] as num?)?.toInt()
      ..recurringRuleId = fields[12] as String?
      ..createdAt = fields[13] as DateTime
      ..updatedAt = fields[14] as DateTime;
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amountMinor)
      ..writeByte(3)
      ..write(obj.currencyCode)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.accountId)
      ..writeByte(6)
      ..write(obj.toAccountId)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.title)
      ..writeByte(9)
      ..write(obj.note)
      ..writeByte(10)
      ..write(obj.exchangeRate)
      ..writeByte(11)
      ..write(obj.baseAmountMinor)
      ..writeByte(12)
      ..write(obj.recurringRuleId)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
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
      case 2:
        return TransactionTypeHive.transfer;
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
      case TransactionTypeHive.transfer:
        writer.writeByte(2);
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
