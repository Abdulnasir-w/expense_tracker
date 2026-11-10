import '../entities/recurring_rule_entity.dart';

abstract class RecurringRepository {
  Future<List<RecurringRuleEntity>> getRules();
  Future<void> addRule(RecurringRuleEntity rule);
  Future<void> updateRule(RecurringRuleEntity rule);
  Future<void> deleteRule(String id);
}

