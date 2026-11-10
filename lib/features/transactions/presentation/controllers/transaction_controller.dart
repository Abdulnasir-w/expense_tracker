import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionController extends AsyncNotifier<List<TransactionEntity>> {
  @override
  Future<List<TransactionEntity>> build() async {
    return _fetchAll();
  }

  Future<List<TransactionEntity>> _fetchAll() =>
      ref.read(getTransactionsProvider).call();

  Future<void> addTransaction(TransactionEntity entity) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addTransactionProvider).call(entity);
      return _fetchAll();
    });
  }

  Future<void> updateTransaction(TransactionEntity entity) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateTransactionProvider).call(entity);
      return _fetchAll();
    });
  }

  Future<void> deleteTransaction(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteTransactionProvider).call(id);
      return _fetchAll();
    });
  }
}

final transactionControllerProvider =
    AsyncNotifierProvider<TransactionController, List<TransactionEntity>>(
  TransactionController.new,
);

/// Derived provider: total income across all transactions (excludes transfers)
final totalIncomeProvider = Provider<int>((ref) {
  final transactions = ref.watch(transactionControllerProvider).valueOrNull;
  if (transactions == null) return 0;
  return transactions
      .where((t) => t.isIncome)
      .fold<int>(0, (sum, t) => sum + t.amountMinor);
});

/// Derived provider: total expenses across all transactions (excludes transfers)
final totalExpensesProvider = Provider<int>((ref) {
  final transactions = ref.watch(transactionControllerProvider).valueOrNull;
  if (transactions == null) return 0;
  return transactions
      .where((t) => t.isExpense)
      .fold<int>(0, (sum, t) => sum + t.amountMinor);
});

/// Derived provider: net balance (income - expenses in minor units)
final balanceProvider = Provider<int>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expenses = ref.watch(totalExpensesProvider);
  return income - expenses;
});
