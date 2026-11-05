import 'package:equatable/equatable.dart';

/// Enum representing the type of a financial transaction.
enum TransactionType { income, expense }

/// Pure domain entity — no framework dependencies, no JSON, no Isar.
/// Used by use cases, controllers, and UI.
class TransactionEntity extends Equatable {
  final int id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String category;
  final String? note;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    this.note,
  });

  /// Returns `true` if this transaction is an income.
  bool get isIncome => type == TransactionType.income;

  /// Returns `true` if this transaction is an expense.
  bool get isExpense => type == TransactionType.expense;

  TransactionEntity copyWith({
    int? id,
    String? title,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? category,
    String? note,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, title, amount, type, date, category, note];
}

