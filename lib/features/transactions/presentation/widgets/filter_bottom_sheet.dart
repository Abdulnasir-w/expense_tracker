import 'package:expense_tracker/features/accounts/presentation/controllers/accounts_controller.dart';
import 'package:expense_tracker/features/categories/presentation/controllers/categories_controller.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/presentation/controllers/filtered_transactions_controller.dart'
    show transactionFilterProvider, filteredTransactionsProvider;
import 'package:expense_tracker/features/transactions/presentation/controllers/transaction_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterProvider);
    final categories = ref.watch(activeCategoriesProvider);
    final accounts = ref.watch(activeAccountsProvider);
    final resultCount = ref.watch(filteredTransactionsProvider).length;
    final tt = Theme.of(context).textTheme;

    Widget section(String title) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(title,
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
        );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter & sort',
                          style: tt.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      TextButton(
                        onPressed: () => ref
                            .read(transactionFilterProvider.notifier)
                            .reset(),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  section('Sort by'),
                  SegmentedButton<SortOption>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                          value: SortOption.newest, label: Text('Newest')),
                      ButtonSegment(
                          value: SortOption.oldest, label: Text('Oldest')),
                      ButtonSegment(
                          value: SortOption.highest, label: Text('Highest')),
                      ButtonSegment(
                          value: SortOption.lowest, label: Text('Lowest')),
                    ],
                    selected: {filter.sort},
                    onSelectionChanged: (val) {
                      ref
                          .read(transactionFilterProvider.notifier)
                          .setFilter(filter.copyWith(sort: val.first));
                    },
                  ),
                  section('Type'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TransactionType.values.map((type) {
                      return FilterChip(
                        label: Text(type.name[0].toUpperCase() +
                            type.name.substring(1)),
                        selected: filter.types.contains(type),
                        onSelected: (_) => ref
                            .read(transactionFilterProvider.notifier)
                            .toggleType(type),
                      );
                    }).toList(),
                  ),
                  section('Categories'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      return FilterChip(
                        label: Text(cat.name),
                        selected: filter.categoryIds.contains(cat.id),
                        onSelected: (_) => ref
                            .read(transactionFilterProvider.notifier)
                            .toggleCategory(cat.id),
                      );
                    }).toList(),
                  ),
                  section('Accounts'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: accounts.map((acc) {
                      return FilterChip(
                        label: Text(acc.name),
                        selected: filter.accountIds.contains(acc.id),
                        onSelected: (_) => ref
                            .read(transactionFilterProvider.notifier)
                            .toggleAccount(acc.id),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Show $resultCount results'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
