import 'package:flutter/material.dart';
import '../../domain/entities/transaction_entity.dart';

enum SortOption { newest, oldest, highest, lowest }

/// Immutable value object representing current transaction search and filter parameters.
class TransactionFilter {
  final String query;
  final Set<TransactionType> types;
  final Set<String> categoryIds;
  final Set<String> accountIds;
  final DateTimeRange? dateRange;
  final int? minAmountMinor;
  final int? maxAmountMinor;
  final SortOption sort;

  const TransactionFilter({
    this.query = '',
    this.types = const {},
    this.categoryIds = const {},
    this.accountIds = const {},
    this.dateRange,
    this.minAmountMinor,
    this.maxAmountMinor,
    this.sort = SortOption.newest,
  });

  bool get isEmpty =>
      query.isEmpty &&
      types.isEmpty &&
      categoryIds.isEmpty &&
      accountIds.isEmpty &&
      dateRange == null &&
      minAmountMinor == null &&
      maxAmountMinor == null &&
      sort == SortOption.newest;

  int get activeCount {
    int count = 0;
    if (query.isNotEmpty) count++;
    if (types.isNotEmpty) count += types.length;
    if (categoryIds.isNotEmpty) count += categoryIds.length;
    if (accountIds.isNotEmpty) count += accountIds.length;
    if (dateRange != null) count++;
    if (minAmountMinor != null || maxAmountMinor != null) count++;
    if (sort != SortOption.newest) count++;
    return count;
  }

  TransactionFilter copyWith({
    String? query,
    Set<TransactionType>? types,
    Set<String>? categoryIds,
    Set<String>? accountIds,
    DateTimeRange? Function()? dateRange,
    int? Function()? minAmountMinor,
    int? Function()? maxAmountMinor,
    SortOption? sort,
  }) {
    return TransactionFilter(
      query: query ?? this.query,
      types: types ?? this.types,
      categoryIds: categoryIds ?? this.categoryIds,
      accountIds: accountIds ?? this.accountIds,
      dateRange: dateRange != null ? dateRange() : this.dateRange,
      minAmountMinor: minAmountMinor != null ? minAmountMinor() : this.minAmountMinor,
      maxAmountMinor: maxAmountMinor != null ? maxAmountMinor() : this.maxAmountMinor,
      sort: sort ?? this.sort,
    );
  }
}

