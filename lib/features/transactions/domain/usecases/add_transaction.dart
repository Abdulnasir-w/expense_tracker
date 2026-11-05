import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Use case: persist a new income or expense transaction.
class AddTransaction {
  final TransactionRepository _repository;
  const AddTransaction(this._repository);

  Future<TransactionEntity> call(TransactionEntity transaction) =>
      _repository.addTransaction(transaction);
}

