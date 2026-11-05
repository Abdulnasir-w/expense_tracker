import '../entities/transaction_entity.dart';

/// Abstract contract for the transactions repository.
/// Implemented in the data layer; depends on no frameworks.
abstract class TransactionRepository {
  /// Returns all transactions ordered by date descending.
  Future<List<TransactionEntity>> getAllTransactions();

  /// Returns all income transactions.
  Future<List<TransactionEntity>> getIncomeTransactions();

  /// Returns all expense transactions.
  Future<List<TransactionEntity>> getExpenseTransactions();

  /// Returns transactions within [start]...[end] date range.
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Persists a new [transaction]. Returns the saved entity with assigned [id].
  Future<TransactionEntity> addTransaction(TransactionEntity transaction);

  /// Removes the transaction with [id].
  Future<void> deleteTransaction(int id);

  /// Replaces an existing transaction.
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction);

  /// Returns total income across all time.
  Future<double> getTotalIncome();

  /// Returns total expenses across all time.
  Future<double> getTotalExpenses();
}

