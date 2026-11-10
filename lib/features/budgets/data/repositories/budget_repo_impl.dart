import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDatasource _datasource;

  BudgetRepositoryImpl(this._datasource);

  @override
  Future<List<BudgetEntity>> getBudgets() async {
    final models = await _datasource.getBudgets();
    return models.map(_toEntity).toList();
  }

  @override
  Future<void> setBudget(BudgetEntity budget) async {
    final model = BudgetModel()
      ..id = budget.id
      ..categoryId = budget.categoryId
      ..limitMinor = budget.limitMinor
      ..period = budget.period.name;
    await _datasource.putBudget(model);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _datasource.deleteBudget(id);
  }

  BudgetEntity _toEntity(BudgetModel model) {
    return BudgetEntity(
      id: model.id,
      categoryId: model.categoryId,
      limitMinor: model.limitMinor,
      period: BudgetPeriod.values.firstWhere(
        (p) => p.name == model.period,
        orElse: () => BudgetPeriod.monthly,
      ),
    );
  }
}

