import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';

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
  Future<TransactionEntity> addTransaction(TransactionEntity transaction) async {
    try {
      return await _localDatasource.addTransaction(transaction);
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
  Future<void> deleteTransaction(String id) async {
    try {
      await _localDatasource.deleteTransaction(id);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }
}
