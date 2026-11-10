import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/recurring_rule_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';

class RecurringController extends AsyncNotifier<List<RecurringRuleEntity>> {
  @override
  Future<List<RecurringRuleEntity>> build() async {
    return ref.read(recurringRepositoryProvider).getRules();
  }

  Future<void> addRule(RecurringRuleEntity rule) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(recurringRepositoryProvider).addRule(rule);
      return ref.read(recurringRepositoryProvider).getRules();
    });
  }

  Future<void> updateRule(RecurringRuleEntity rule) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(recurringRepositoryProvider).updateRule(rule);
      return ref.read(recurringRepositoryProvider).getRules();
    });
  }

  Future<void> toggleRuleActive(RecurringRuleEntity rule) async {
    final updated = RecurringRuleEntity(
      id: rule.id,
      type: rule.type,
      amountMinor: rule.amountMinor,
      currencyCode: rule.currencyCode,
      categoryId: rule.categoryId,
      accountId: rule.accountId,
      toAccountId: rule.toAccountId,
      title: rule.title,
      note: rule.note,
      frequency: rule.frequency,
      interval: rule.interval,
      startDate: rule.startDate,
      endDate: rule.endDate,
      nextDueDate: rule.nextDueDate,
      isActive: !rule.isActive,
      autoAdd: rule.autoAdd,
    );
    await updateRule(updated);
  }

  Future<void> deleteRule(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(recurringRepositoryProvider).deleteRule(id);
      return ref.read(recurringRepositoryProvider).getRules();
    });
  }

  /// Evaluates and generates transactions for due recurring rules!
  Future<int> processDueRules() async {
    final rules = await ref.read(recurringRepositoryProvider).getRules();
    final now = DateTime.now();
    int createdCount = 0;

    for (final rule in rules) {
      if (!rule.isActive) continue;
      if (rule.endDate != null && now.isAfter(rule.endDate!)) continue;

      DateTime currentDue = rule.nextDueDate;
      bool modified = false;

      while (currentDue.isBefore(now) || currentDue.isAtSameMomentAs(now)) {
        // Create the actual transaction
        final typeEnum = switch (rule.type) {
          'income' => TransactionType.income,
          'transfer' => TransactionType.transfer,
          _ => TransactionType.expense,
        };

        final transaction = TransactionEntity(
          id: const Uuid().v4(),
          type: typeEnum,
          amountMinor: rule.amountMinor,
          currencyCode: rule.currencyCode,
          categoryId: rule.categoryId,
          accountId: rule.accountId,
          toAccountId: rule.toAccountId,
          date: currentDue,
          title: rule.title,
          note: rule.note != null ? '${rule.note} (Recurring)' : 'Recurring bill',
          recurringRuleId: rule.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await ref.read(transactionControllerProvider.notifier).addTransaction(transaction);
        createdCount++;
        modified = true;

        // Advance to next due date
        currentDue = _advanceDueDate(currentDue, rule.frequency, rule.interval);
      }

      if (modified) {
        final updatedRule = RecurringRuleEntity(
          id: rule.id,
          type: rule.type,
          amountMinor: rule.amountMinor,
          currencyCode: rule.currencyCode,
          categoryId: rule.categoryId,
          accountId: rule.accountId,
          toAccountId: rule.toAccountId,
          title: rule.title,
          note: rule.note,
          frequency: rule.frequency,
          interval: rule.interval,
          startDate: rule.startDate,
          endDate: rule.endDate,
          nextDueDate: currentDue,
          isActive: rule.isActive,
          autoAdd: rule.autoAdd,
        );
        await ref.read(recurringRepositoryProvider).updateRule(updatedRule);
      }
    }

    if (createdCount > 0) {
      ref.invalidate(recurringProvider);
    }
    return createdCount;
  }

  DateTime _advanceDueDate(DateTime date, RecurringFrequency frequency, int interval) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return date.add(Duration(days: interval));
      case RecurringFrequency.weekly:
        return date.add(Duration(days: 7 * interval));
      case RecurringFrequency.monthly:
        return DateTime(date.year, date.month + interval, date.day);
      case RecurringFrequency.yearly:
        return DateTime(date.year + interval, date.month, date.day);
    }
  }
}

final recurringProvider =
    AsyncNotifierProvider<RecurringController, List<RecurringRuleEntity>>(
  RecurringController.new,
);

