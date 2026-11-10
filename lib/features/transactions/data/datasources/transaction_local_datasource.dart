import '../../../../core/database/hive_service.dart';
import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionLocalDatasource {
  Future<List<TransactionEntity>> getAllTransactions() async {
    try {
      final box = HiveService.transactionsBox;
      final models = box.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return models.map(_toEntity).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch transactions: $e');
    }
  }

  Future<TransactionEntity> addTransaction(TransactionEntity entity) async {
    try {
      final box = HiveService.transactionsBox;
      final model = _toModel(entity);
      await box.put(model.id, model);
      return _toEntity(model);
    } catch (e) {
      throw DatabaseException('Failed to add transaction: $e');
    }
  }

  Future<TransactionEntity> updateTransaction(TransactionEntity entity) async {
    try {
      final box = HiveService.transactionsBox;
      final model = _toModel(entity);
      await box.put(model.id, model);
      return _toEntity(model);
    } catch (e) {
      throw DatabaseException('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final box = HiveService.transactionsBox;
      await box.delete(id);
    } catch (e) {
      throw DatabaseException('Failed to delete transaction: $e');
    }
  }

  TransactionModel _toModel(TransactionEntity entity) => TransactionModel()
    ..id = entity.id
    ..type = switch (entity.type) {
      TransactionType.income => TransactionTypeHive.income,
      TransactionType.transfer => TransactionTypeHive.transfer,
      _ => TransactionTypeHive.expense,
    }
    ..amountMinor = entity.amountMinor
    ..currencyCode = entity.currencyCode
    ..categoryId = entity.categoryId
    ..accountId = entity.accountId
    ..toAccountId = entity.toAccountId
    ..date = entity.date
    ..title = entity.title
    ..note = entity.note
    ..exchangeRate = entity.exchangeRate
    ..baseAmountMinor = entity.baseAmountMinor
    ..recurringRuleId = entity.recurringRuleId
    ..createdAt = entity.createdAt
    ..updatedAt = entity.updatedAt;

  TransactionEntity _toEntity(TransactionModel model) => TransactionEntity(
        id: model.id,
        type: switch (model.type) {
          TransactionTypeHive.income => TransactionType.income,
          TransactionTypeHive.transfer => TransactionType.transfer,
          _ => TransactionType.expense,
        },
        amountMinor: model.amountMinor,
        currencyCode: model.currencyCode,
        categoryId: model.categoryId,
        accountId: model.accountId,
        toAccountId: model.toAccountId,
        date: model.date,
        title: model.title,
        note: model.note,
        exchangeRate: model.exchangeRate,
        baseAmountMinor: model.baseAmountMinor,
        recurringRuleId: model.recurringRuleId,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );
}
