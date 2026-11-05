import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';

/// Concrete implementation of [TransactionRepository].
/// Bridges the domain layer with [TransactionLocalDatasource].
/// Converts [AppException]s into [Failure]s for the domain/presentation layers.
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDatasource _localDatasource;

  const TransactionRepositoryImpl(this._localDatasource);

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    try {
      return await _localDatasource.getAllTransactions();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<List<TransactionEntity>> getIncomeTransactions() async {
    try {
      return await _localDatasource.getByType(TransactionTypeHive.income);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<List<TransactionEntity>> getExpenseTransactions() async {
    try {
      return await _localDatasource.getByType(TransactionTypeHive.expense);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await _localDatasource.getByDateRange(start, end);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<TransactionEntity> addTransaction(TransactionEntity transaction) async {
    try {
      return await _localDatasource.addTransaction(transaction);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<void> deleteTransaction(int id) async {
    try {
      await _localDatasource.deleteTransaction(id);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction) async {
    try {
      return await _localDatasource.updateTransaction(transaction);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<double> getTotalIncome() async {
    try {
      return await _localDatasource.getTotalByType(TransactionTypeHive.income);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<double> getTotalExpenses() async {
    try {
      return await _localDatasource.getTotalByType(TransactionTypeHive.expense);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }
}
