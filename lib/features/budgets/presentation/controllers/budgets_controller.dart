import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/budget_entity.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';

class BudgetsController extends AsyncNotifier<List<BudgetEntity>> {
  @override
  Future<List<BudgetEntity>> build() async {
    return ref.read(budgetRepositoryProvider).getBudgets();
  }

  Future<void> setBudget(BudgetEntity budget) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(budgetRepositoryProvider).setBudget(budget);
      return ref.read(budgetRepositoryProvider).getBudgets();
    });
  }

  Future<void> deleteBudget(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(budgetRepositoryProvider).deleteBudget(id);
      return ref.read(budgetRepositoryProvider).getBudgets();
    });
  }
}

final budgetsProvider =
    AsyncNotifierProvider<BudgetsController, List<BudgetEntity>>(
  BudgetsController.new,
);

/// Computes total spent in the current month for each category from transactions.
final categorySpentThisMonthProvider = Provider<Map<String, int>>((ref) {
  final transactions = ref.watch(transactionControllerProvider).valueOrNull ?? [];
  final now = DateTime.now();

  final Map<String, int> spentMap = {};
  for (final t in transactions) {
    if (t.isExpense && t.date.year == now.year && t.date.month == now.month) {
      spentMap[t.categoryId] = (spentMap[t.categoryId] ?? 0) + t.amountMinor;
    }
  }
  return spentMap;
});

/// Total expense spent across all categories this month
final totalSpentThisMonthProvider = Provider<int>((ref) {
  final spentMap = ref.watch(categorySpentThisMonthProvider);
  return spentMap.values.fold<int>(0, (sum, val) => sum + val);
});

