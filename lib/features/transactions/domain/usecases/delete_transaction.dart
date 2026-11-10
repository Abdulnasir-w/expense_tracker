import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository _repository;
  const DeleteTransaction(this._repository);

  Future<void> call(String id) => _repository.deleteTransaction(id);
}
