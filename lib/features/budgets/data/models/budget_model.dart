import 'package:hive_ce_flutter/hive_ce_flutter.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 4)
class BudgetModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  String? categoryId;

  @HiveField(2)
  late int limitMinor;

  @HiveField(3)
  String period = 'monthly';
}

