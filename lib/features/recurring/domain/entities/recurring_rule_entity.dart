import 'package:equatable/equatable.dart';

enum RecurringFrequency { daily, weekly, monthly, yearly }

class RecurringRuleEntity extends Equatable {
  final String id;
  final String type; // 'income' | 'expense' | 'transfer'
  final int amountMinor;
  final String currencyCode;
  final String categoryId;
  final String accountId;
  final String? toAccountId;
  final String title;
  final String? note;
  final RecurringFrequency frequency;
  final int interval; // every N
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextDueDate;
  final bool isActive;
  final bool autoAdd; // auto-add vs remind

  const RecurringRuleEntity({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.currencyCode,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    required this.title,
    this.note,
    required this.frequency,
    this.interval = 1,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    this.isActive = true,
    this.autoAdd = true,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        amountMinor,
        currencyCode,
        categoryId,
        accountId,
        toAccountId,
        title,
        note,
        frequency,
        interval,
        startDate,
        endDate,
        nextDueDate,
        isActive,
        autoAdd,
      ];
}

