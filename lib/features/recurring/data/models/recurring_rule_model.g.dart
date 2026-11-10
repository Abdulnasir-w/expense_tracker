// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_rule_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringRuleModelAdapter extends TypeAdapter<RecurringRuleModel> {
  @override
  final typeId = 5;

  @override
  RecurringRuleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringRuleModel()
      ..id = fields[0] as String
      ..type = fields[1] as String
      ..amountMinor = (fields[2] as num).toInt()
      ..currencyCode = fields[3] as String
      ..categoryId = fields[4] as String
      ..accountId = fields[5] as String
      ..toAccountId = fields[6] as String?
      ..title = fields[7] as String
      ..note = fields[8] as String?
      ..frequency = fields[9] as String
      ..interval = (fields[10] as num).toInt()
      ..startDate = fields[11] as DateTime
      ..endDate = fields[12] as DateTime?
      ..nextDueDate = fields[13] as DateTime
      ..isActive = fields[14] as bool
      ..autoAdd = fields[15] as bool;
  }

  @override
  void write(BinaryWriter writer, RecurringRuleModel obj) {
    writer
      ..writeByte(16)
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
      ..write(obj.title)
      ..writeByte(8)
      ..write(obj.note)
      ..writeByte(9)
      ..write(obj.frequency)
      ..writeByte(10)
      ..write(obj.interval)
      ..writeByte(11)
      ..write(obj.startDate)
      ..writeByte(12)
      ..write(obj.endDate)
      ..writeByte(13)
      ..write(obj.nextDueDate)
      ..writeByte(14)
      ..write(obj.isActive)
      ..writeByte(15)
      ..write(obj.autoAdd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringRuleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
