import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_controller.dart';
import 'transaction_filter.dart';
import '../../../categories/presentation/controllers/categories_controller.dart';

class TransactionFilterNotifier extends StateNotifier<TransactionFilter> {
  TransactionFilterNotifier() : super(const TransactionFilter());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void toggleType(TransactionType type) {
    final types = Set<TransactionType>.from(state.types);
    if (types.contains(type)) {
      types.remove(type);
    } else {
      types.add(type);
    }
    state = state.copyWith(types: types);
  }

  void toggleCategory(String categoryId) {
    final catIds = Set<String>.from(state.categoryIds);
    if (catIds.contains(categoryId)) {
      catIds.remove(categoryId);
    } else {
      catIds.add(categoryId);
    }
    state = state.copyWith(categoryIds: catIds);
  }

  void toggleAccount(String accountId) {
    final accIds = Set<String>.from(state.accountIds);
    if (accIds.contains(accountId)) {
      accIds.remove(accountId);
    } else {
      accIds.add(accountId);
    }
    state = state.copyWith(accountIds: accIds);
  }

  void setFilter(TransactionFilter filter) {
    state = filter;
  }

  void reset() {
    state = const TransactionFilter();
  }
}

final transactionFilterProvider =
    StateNotifierProvider<TransactionFilterNotifier, TransactionFilter>((ref) {
  return TransactionFilterNotifier();
});

/// Watches the transactions list and current filter to return matching & sorted records.
final filteredTransactionsProvider = Provider<List<TransactionEntity>>((ref) {
  final all = ref.watch(transactionControllerProvider).valueOrNull ?? [];
  final filter = ref.watch(transactionFilterProvider);
  final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

  // Map category IDs to names for search query matching
  final catNameMap = {for (var c in categories) c.id: c.name.toLowerCase()};

  var filtered = all.where((t) {
    // 1. Text Query (title, note, category name)
    if (filter.query.isNotEmpty) {
      final q = filter.query.toLowerCase();
      final titleMatch = t.title.toLowerCase().contains(q);
      final noteMatch = t.note?.toLowerCase().contains(q) ?? false;
      final catMatch = catNameMap[t.categoryId]?.contains(q) ?? false;
      if (!titleMatch && !noteMatch && !catMatch) return false;
    }

    // 2. Types
    if (filter.types.isNotEmpty && !filter.types.contains(t.type)) {
      return false;
    }

    // 3. Category IDs
    if (filter.categoryIds.isNotEmpty && !filter.categoryIds.contains(t.categoryId)) {
      return false;
    }

    // 4. Account IDs
    if (filter.accountIds.isNotEmpty &&
        !filter.accountIds.contains(t.accountId) &&
        (t.toAccountId == null || !filter.accountIds.contains(t.toAccountId))) {
      return false;
    }

    // 5. Date Range (inclusive to end of selected day)
    if (filter.dateRange != null) {
      final start = filter.dateRange!.start;
      final end = DateTime(
        filter.dateRange!.end.year,
        filter.dateRange!.end.month,
        filter.dateRange!.end.day,
        23,
        59,
        59,
        999,
      );
      if (t.date.isBefore(start) || t.date.isAfter(end)) return false;
    }

    // 6. Min/Max Amount
    if (filter.minAmountMinor != null && t.amountMinor < filter.minAmountMinor!) {
      return false;
    }
    if (filter.maxAmountMinor != null && t.amountMinor > filter.maxAmountMinor!) {
      return false;
    }

    return true;
  }).toList();

  // 7. Sorting
  switch (filter.sort) {
    case SortOption.newest:
      filtered.sort((a, b) => b.date.compareTo(a.date));
      break;
    case SortOption.oldest:
      filtered.sort((a, b) => a.date.compareTo(b.date));
      break;
    case SortOption.highest:
      filtered.sort((a, b) => b.amountMinor.compareTo(a.amountMinor));
      break;
    case SortOption.lowest:
      filtered.sort((a, b) => a.amountMinor.compareTo(b.amountMinor));
      break;
  }

  return filtered;
});

