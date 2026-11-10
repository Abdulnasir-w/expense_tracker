import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getAllTransactions();
  Future<TransactionEntity> addTransaction(TransactionEntity transaction);
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
}
