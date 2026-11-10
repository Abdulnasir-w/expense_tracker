import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../../../../core/database/hive_service.dart';
import '../models/recurring_rule_model.dart';

class RecurringLocalDatasource {
  Box<RecurringRuleModel> get _box => HiveService.recurringBox;

  Future<List<RecurringRuleModel>> getRules() async {
    return _box.values.toList();
  }

  Future<void> putRule(RecurringRuleModel model) async {
    await _box.put(model.id, model);
  }

  Future<void> deleteRule(String id) async {
    await _box.delete(id);
  }
}

