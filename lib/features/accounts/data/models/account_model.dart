import 'package:hive_ce_flutter/hive_ce_flutter.dart';

part 'account_model.g.dart';

@HiveType(typeId: 3)
class AccountModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String type; // 'cash' | 'bank' | 'wallet' | 'card'

  @HiveField(3)
  late String currencyCode;

  @HiveField(4)
  int initialBalanceMinor = 0;

  @HiveField(5)
  late int colorValue;

  @HiveField(6)
  late String iconKey;

  @HiveField(7)
  bool isArchived = false;
}

