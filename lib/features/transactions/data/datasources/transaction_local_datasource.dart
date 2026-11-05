import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../../../../core/database/hive_service.dart';
import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/transaction_entity.dart';

/// Local Hive CE datasource for transaction CRUD operations.
class TransactionLocalDatasource {
  Box<TransactionModel> get _box => HiveService.transactionsBox;

  // ── Mappers ────────────────────────────────────────────────────────────────

  TransactionModel _toModel(TransactionEntity entity) {
    final model = TransactionModel()
      ..title = entity.title
      ..amount = entity.amount
      ..type = entity.isIncome
          ? TransactionTypeHive.income
          : TransactionTypeHive.expense
      ..date = entity.date
      ..category = entity.category
      ..note = entity.note;
    return model;
  }

  TransactionEntity _toEntity(dynamic key, TransactionModel model) =>
      TransactionEntity(
        id: key as int,
        title: model.title,
        amount: model.amount,
        type: model.type == TransactionTypeHive.income
            ? TransactionType.income
            : TransactionType.expense,
        date: model.date,
        category: model.category,
        note: model.note,
      );

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<List<TransactionEntity>> getAllTransactions() async {
    try {
      final entries = _box.toMap().entries.toList()
        ..sort((a, b) => b.value.date.compareTo(a.value.date));
      return entries.map((e) => _toEntity(e.key, e.value)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch transactions: $e');
    }
  }

  Future<List<TransactionEntity>> getByType(TransactionTypeHive type) async {
    try {
      final entries = _box
          .toMap()
          .entries
          .where((e) => e.value.type == type)
          .toList()
        ..sort((a, b) => b.value.date.compareTo(a.value.date));
      return entries.map((e) => _toEntity(e.key, e.value)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch transactions by type: $e');
    }
  }

  Future<List<TransactionEntity>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final entries = _box
          .toMap()
          .entries
          .where((e) =>
              !e.value.date.isBefore(start) && !e.value.date.isAfter(end))
          .toList()
        ..sort((a, b) => b.value.date.compareTo(a.value.date));
      return entries.map((e) => _toEntity(e.key, e.value)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch transactions by date: $e');
    }
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<TransactionEntity> addTransaction(TransactionEntity entity) async {
    try {
      final model = _toModel(entity);
      final key = await _box.add(model);
      return _toEntity(key, model);
    } catch (e) {
      throw DatabaseException('Failed to add transaction: $e');
    }
  }

  Future<TransactionEntity> updateTransaction(TransactionEntity entity) async {
    try {
      final model = _toModel(entity);
      await _box.put(entity.id, model);
      return _toEntity(entity.id, model);
    } catch (e) {
      throw DatabaseException('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw DatabaseException('Failed to delete transaction: $e');
    }
  }

  // ── Aggregates ─────────────────────────────────────────────────────────────

  Future<double> getTotalByType(TransactionTypeHive type) async {
    final transactions = await getByType(type);
    return transactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  }
}
