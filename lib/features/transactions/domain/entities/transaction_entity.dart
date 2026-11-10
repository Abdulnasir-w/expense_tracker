import 'package:equatable/equatable.dart';

enum TransactionType { income, expense, transfer }

class TransactionEntity extends Equatable {
  final String id;
  final TransactionType type;
  final int amountMinor; // Stored as integer minor units (e.g. $12.50 = 1250)
  final String currencyCode;
  final String categoryId;
  final String accountId;
  final String? toAccountId; // For transfer transactions
  final DateTime date;
  final String title;
  final String? note;
  final double? exchangeRate;
  final int? baseAmountMinor;
  final String? recurringRuleId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.currencyCode,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    required this.date,
    required this.title,
    this.note,
    this.exchangeRate,
    this.baseAmountMinor,
    this.recurringRuleId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isTransfer => type == TransactionType.transfer;

  TransactionEntity copyWith({
    String? id,
    TransactionType? type,
    int? amountMinor,
    String? currencyCode,
    String? categoryId,
    String? accountId,
    String? toAccountId,
    DateTime? date,
    String? title,
    String? note,
    double? exchangeRate,
    int? baseAmountMinor,
    String? recurringRuleId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      date: date ?? this.date,
      title: title ?? this.title,
      note: note ?? this.note,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      baseAmountMinor: baseAmountMinor ?? this.baseAmountMinor,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        amountMinor,
        currencyCode,
        categoryId,
        accountId,
        toAccountId,
        date,
        title,
        note,
        exchangeRate,
        baseAmountMinor,
        recurringRuleId,
        createdAt,
        updatedAt,
      ];
}
