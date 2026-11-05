import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/transactions/data/datasources/transaction_local_datasource.dart';
import '../../features/transactions/data/repositories/transaction_repo_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/add_transaction.dart';
import '../../features/transactions/domain/usecases/delete_transaction.dart';
import '../../features/transactions/domain/usecases/get_transactions.dart';
// ── Datasources ────────────────────────────────────────────────────────────

final transactionLocalDatasourceProvider =
    Provider<TransactionLocalDatasource>((ref) {
  return TransactionLocalDatasource();
});

// ── Repositories ───────────────────────────────────────────────────────────

final transactionRepositoryProvider =
    Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    ref.watch(transactionLocalDatasourceProvider),
  );
});

// ── Use Cases ──────────────────────────────────────────────────────────────

final getTransactionsProvider = Provider<GetTransactions>((ref) {
  return GetTransactions(ref.watch(transactionRepositoryProvider));
});

final addTransactionProvider = Provider<AddTransaction>((ref) {
  return AddTransaction(ref.watch(transactionRepositoryProvider));
});

final deleteTransactionProvider = Provider<DeleteTransaction>((ref) {
  return DeleteTransaction(ref.watch(transactionRepositoryProvider));
});
