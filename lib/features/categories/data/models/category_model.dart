import 'package:hive_ce_flutter/hive_ce_flutter.dart';

part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String iconKey;

  @HiveField(3)
  late int colorValue;

  @HiveField(4)
  late String type; // 'income' | 'expense' | 'both'

  @HiveField(5)
  bool isArchived = false;

  @HiveField(6)
  int sortOrder = 0;
}

