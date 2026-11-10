import 'package:hive_ce_flutter/hive_ce_flutter.dart';

part 'recurring_rule_model.g.dart';

@HiveType(typeId: 5)
class RecurringRuleModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String type;

  @HiveField(2)
  late int amountMinor;

  @HiveField(3)
  late String currencyCode;

  @HiveField(4)
  late String categoryId;

  @HiveField(5)
  late String accountId;

  @HiveField(6)
  String? toAccountId;

  @HiveField(7)
  late String title;

  @HiveField(8)
  String? note;

  @HiveField(9)
  late String frequency; // 'daily' | 'weekly' | 'monthly' | 'yearly'

  @HiveField(10)
  int interval = 1;

  @HiveField(11)
  late DateTime startDate;

  @HiveField(12)
  DateTime? endDate;

  @HiveField(13)
  late DateTime nextDueDate;

  @HiveField(14)
  bool isActive = true;

  @HiveField(15)
  bool autoAdd = true;
}

