import 'package:hive_ce_flutter/hive_ce_flutter.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
enum TransactionTypeHive {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,

  @HiveField(2)
  transfer,
}

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late TransactionTypeHive type;

  @HiveField(2)
  late int amountMinor; // integer minor units (e.g. 1250)

  @HiveField(3)
  late String currencyCode;

  @HiveField(4)
  late String categoryId;

  @HiveField(5)
  late String accountId;

  @HiveField(6)
  String? toAccountId;

  @HiveField(7)
  late DateTime date;

  @HiveField(8)
  late String title;

  @HiveField(9)
  String? note;

  @HiveField(10)
  double? exchangeRate;

  @HiveField(11)
  int? baseAmountMinor;

  @HiveField(12)
  String? recurringRuleId;

  @HiveField(13)
  late DateTime createdAt;

  @HiveField(14)
  late DateTime updatedAt;
}
