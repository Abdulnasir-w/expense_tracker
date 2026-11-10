import 'package:flutter_riverpod/flutter_riverpod.dart';

// Transactions
import '../../features/transactions/data/datasources/transaction_local_datasource.dart';
import '../../features/transactions/data/repositories/transaction_repo_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/add_transaction.dart';
import '../../features/transactions/domain/usecases/get_transactions.dart';
import '../../features/transactions/domain/usecases/update_transaction.dart';
import '../../features/transactions/domain/usecases/delete_transaction.dart';

// Categories
import '../../features/categories/data/datasources/category_local_datasource.dart';
import '../../features/categories/data/repositories/category_repo_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';

// Accounts
import '../../features/accounts/data/datasources/account_local_datasource.dart';
import '../../features/accounts/data/repositories/account_repo_impl.dart';
import '../../features/accounts/domain/repositories/account_repository.dart';

// Budgets
import '../../features/budgets/data/datasources/budget_local_datasource.dart';
import '../../features/budgets/data/repositories/budget_repo_impl.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';

// Recurring
import '../../features/recurring/data/datasources/recurring_local_datasource.dart';
import '../../features/recurring/data/repositories/recurring_repo_impl.dart';
import '../../features/recurring/domain/repositories/recurring_repository.dart';

// ── Transactions Providers ──────────────────────────────────────────────────
final transactionLocalDatasourceProvider =
    Provider<TransactionLocalDatasource>((ref) => TransactionLocalDatasource());

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.watch(transactionLocalDatasourceProvider));
});

final getTransactionsProvider = Provider<GetTransactions>((ref) {
  return GetTransactions(ref.watch(transactionRepositoryProvider));
});

final addTransactionProvider = Provider<AddTransaction>((ref) {
  return AddTransaction(ref.watch(transactionRepositoryProvider));
});

final updateTransactionProvider = Provider<UpdateTransaction>((ref) {
  return UpdateTransaction(ref.watch(transactionRepositoryProvider));
});

final deleteTransactionProvider = Provider<DeleteTransaction>((ref) {
  return DeleteTransaction(ref.watch(transactionRepositoryProvider));
});

// ── Categories Providers ────────────────────────────────────────────────────
final categoryLocalDatasourceProvider =
    Provider<CategoryLocalDatasource>((ref) => CategoryLocalDatasource());

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryLocalDatasourceProvider));
});

// ── Accounts Providers ──────────────────────────────────────────────────────
final accountLocalDatasourceProvider =
    Provider<AccountLocalDatasource>((ref) => AccountLocalDatasource());

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(accountLocalDatasourceProvider));
});

// ── Budgets Providers ───────────────────────────────────────────────────────
final budgetLocalDatasourceProvider =
    Provider<BudgetLocalDatasource>((ref) => BudgetLocalDatasource());

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(ref.watch(budgetLocalDatasourceProvider));
});

// ── Recurring Providers ─────────────────────────────────────────────────────
final recurringLocalDatasourceProvider =
    Provider<RecurringLocalDatasource>((ref) => RecurringLocalDatasource());

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepositoryImpl(ref.watch(recurringLocalDatasourceProvider));
});
