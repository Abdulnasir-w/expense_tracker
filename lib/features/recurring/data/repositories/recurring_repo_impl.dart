import '../../domain/entities/recurring_rule_entity.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../datasources/recurring_local_datasource.dart';
import '../models/recurring_rule_model.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  final RecurringLocalDatasource _datasource;

  RecurringRepositoryImpl(this._datasource);

  @override
  Future<List<RecurringRuleEntity>> getRules() async {
    final models = await _datasource.getRules();
    return models.map(_toEntity).toList();
  }

  @override
  Future<void> addRule(RecurringRuleEntity rule) async {
    await _datasource.putRule(_toModel(rule));
  }

  @override
  Future<void> updateRule(RecurringRuleEntity rule) async {
    await _datasource.putRule(_toModel(rule));
  }

  @override
  Future<void> deleteRule(String id) async {
    await _datasource.deleteRule(id);
  }

  RecurringRuleEntity _toEntity(RecurringRuleModel model) {
    return RecurringRuleEntity(
      id: model.id,
      type: model.type,
      amountMinor: model.amountMinor,
      currencyCode: model.currencyCode,
      categoryId: model.categoryId,
      accountId: model.accountId,
      toAccountId: model.toAccountId,
      title: model.title,
      note: model.note,
      frequency: RecurringFrequency.values.firstWhere(
        (f) => f.name == model.frequency,
        orElse: () => RecurringFrequency.monthly,
      ),
      interval: model.interval,
      startDate: model.startDate,
      endDate: model.endDate,
      nextDueDate: model.nextDueDate,
      isActive: model.isActive,
      autoAdd: model.autoAdd,
    );
  }

  RecurringRuleModel _toModel(RecurringRuleEntity entity) {
    return RecurringRuleModel()
      ..id = entity.id
      ..type = entity.type
      ..amountMinor = entity.amountMinor
      ..currencyCode = entity.currencyCode
      ..categoryId = entity.categoryId
      ..accountId = entity.accountId
      ..toAccountId = entity.toAccountId
      ..title = entity.title
      ..note = entity.note
      ..frequency = entity.frequency.name
      ..interval = entity.interval
      ..startDate = entity.startDate
      ..endDate = entity.endDate
      ..nextDueDate = entity.nextDueDate
      ..isActive = entity.isActive
      ..autoAdd = entity.autoAdd;
  }
}

