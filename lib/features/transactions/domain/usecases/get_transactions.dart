import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Use case: fetch all transactions.
class GetTransactions {
  final TransactionRepository _repository;
  const GetTransactions(this._repository);

  Future<List<TransactionEntity>> call() => _repository.getAllTransactions();
}
