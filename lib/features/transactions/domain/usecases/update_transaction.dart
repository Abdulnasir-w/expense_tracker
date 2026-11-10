import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository _repository;
  const UpdateTransaction(this._repository);

  Future<TransactionEntity> call(TransactionEntity transaction) =>
      _repository.updateTransaction(transaction);
}

