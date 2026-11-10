import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../../../../core/database/hive_service.dart';
import '../models/budget_model.dart';

class BudgetLocalDatasource {
  Box<BudgetModel> get _box => HiveService.budgetsBox;

  Future<List<BudgetModel>> getBudgets() async {
    return _box.values.toList();
  }

  Future<void> putBudget(BudgetModel budget) async {
    await _box.put(budget.id, budget);
  }

  Future<void> deleteBudget(String id) async {
    await _box.delete(id);
  }
}

