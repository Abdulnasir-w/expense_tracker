import '../repositories/transaction_repository.dart';

/// Use case: delete a transaction by its [id].
class DeleteTransaction {
  final TransactionRepository _repository;
  const DeleteTransaction(this._repository);

  Future<void> call(int id) => _repository.deleteTransaction(id);
}

