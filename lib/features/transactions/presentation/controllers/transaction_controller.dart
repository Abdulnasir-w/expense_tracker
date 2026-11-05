import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/transaction_entity.dart';

/// Riverpod [AsyncNotifier] that manages the full transaction list.
///
/// Exposes [AsyncValue<List<TransactionEntity>>]:
///   - [AsyncLoading] while fetching
///   - [AsyncError]   on failure
///   - [AsyncData]    with the list when ready
class TransactionController
    extends AsyncNotifier<List<TransactionEntity>> {

  @override
  Future<List<TransactionEntity>> build() async {
    return _fetchAll();
  }

  Future<List<TransactionEntity>> _fetchAll() =>
      ref.read(getTransactionsProvider).call();

  /// Adds an [entity] and refreshes the list.
  Future<void> addTransaction(TransactionEntity entity) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addTransactionProvider).call(entity);
      return _fetchAll();
    });
  }

  /// Deletes transaction by [id] and refreshes the list.
  Future<void> deleteTransaction(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteTransactionProvider).call(id);
      return _fetchAll();
    });
  }
}

/// Global provider for [TransactionController].
final transactionControllerProvider =
    AsyncNotifierProvider<TransactionController, List<TransactionEntity>>(
  TransactionController.new,
);

/// Derived provider: total income across all transactions.
final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionControllerProvider).valueOrNull;
  if (transactions == null) return 0.0;
  return transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Derived provider: total expenses across all transactions.
final totalExpensesProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionControllerProvider).valueOrNull;
  if (transactions == null) return 0.0;
  return transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Derived provider: net balance (income - expenses).
final balanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expenses = ref.watch(totalExpensesProvider);
  return income - expenses;
});

