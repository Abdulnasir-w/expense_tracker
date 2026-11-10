import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/day_header_row.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/filter_bottom_sheet.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/summary_strip.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/swipe_background.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_tile.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/type_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/screen_header.dart';
import '../../../categories/presentation/controllers/categories_controller.dart';
import '../../../accounts/presentation/controllers/accounts_controller.dart';
import '../../domain/entities/transaction_entity.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/transaction_filter.dart';
import '../controllers/filtered_transactions_controller.dart';
import 'transaction_form_screen.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _DayHeader {
  const _DayHeader(this.day, this.netMinor);
  final DateTime day;
  final int netMinor;
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => const FilterBottomSheet(),
    );
  }

  void _openEditTransaction(TransactionEntity transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(initialTransaction: transaction),
      ),
    );
  }

  void _deleteWithUndo(TransactionEntity transaction) {
    ref
        .read(transactionControllerProvider.notifier)
        .deleteTransaction(transaction.id);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${transaction.title}"'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            ref
                .read(transactionControllerProvider.notifier)
                .addTransaction(transaction);
          },
        ),
      ),
    );
  }

  /// Quick type filter: null = All, otherwise only that type.
  void _selectType(TransactionType? type) {
    final notifier = ref.read(transactionFilterProvider.notifier);
    final current = ref.read(transactionFilterProvider).types;
    for (final t in current.toList()) {
      if (t != type) notifier.toggleType(t);
    }
    if (type != null && !current.contains(type)) notifier.toggleType(type);
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';
    return DateFormat(d.year == now.year ? 'EEEE, d MMM' : 'd MMM yyyy')
        .format(d);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = ref.watch(filteredTransactionsProvider);
    final filter = ref.watch(transactionFilterProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
    final categoryMap = {for (var c in categories) c.id: c};
    final accountMap = {for (var a in accounts) a.id: a};
    final cs = Theme.of(context).colorScheme;

    // Totals for the current result set
    var income = 0;
    var expense = 0;
    final dayNet = <DateTime, int>{};
    for (final t in filtered) {
      final k = DateTime(t.date.year, t.date.month, t.date.day);
      if (t.isIncome) {
        income += t.amountMinor;
        dayNet[k] = (dayNet[k] ?? 0) + t.amountMinor;
      } else if (t.isExpense) {
        expense += t.amountMinor;
        dayNet[k] = (dayNet[k] ?? 0) - t.amountMinor;
      }
    }

    // Flat list with day headers (only when sorted by date)
    final grouped =
        filter.sort == SortOption.newest || filter.sort == SortOption.oldest;
    final items = <Object>[];
    DateTime? lastDay;
    for (final t in filtered) {
      final k = DateTime(t.date.year, t.date.month, t.date.day);
      if (grouped && k != lastDay) {
        items.add(_DayHeader(k, dayNet[k] ?? 0));
        lastDay = k;
      }
      items.add(t);
    }

    final hasChipFilters =
        filter.categoryIds.isNotEmpty || filter.accountIds.isNotEmpty;

    return AppStatusBar(
      child: Scaffold(
        body: Column(
          children: [
            ScreenHeader(
              title: 'Transactions',
              subtitle: filter.isEmpty
                  ? '${filtered.length} in total'
                  : '${filtered.length} matching',
              actions: [
                HeaderAction(
                  icon: _isSearchExpanded
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  tooltip: 'Search',
                  active: _isSearchExpanded,
                  onTap: () {
                    setState(() {
                      _isSearchExpanded = !_isSearchExpanded;
                      if (!_isSearchExpanded) {
                        _searchController.clear();
                        ref
                            .read(transactionFilterProvider.notifier)
                            .setQuery('');
                      }
                    });
                  },
                ),
                const SizedBox(width: 10),
                HeaderAction(
                  icon: Icons.tune_rounded,
                  tooltip: 'Filter and sort',
                  badgeCount: filter.activeCount,
                  active: filter.activeCount > 0,
                  onTap: _openFilterSheet,
                ),
              ],
            ),

            // Search field
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: _isSearchExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search title, note or category',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                        .read(
                                            transactionFilterProvider.notifier)
                                        .setQuery('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (val) => ref
                            .read(transactionFilterProvider.notifier)
                            .setQuery(val),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),

            // Summary strip
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: SummaryStrip(
                income: income,
                expense: expense,
              ),
            ),

            // Quick type chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  TypeChip(
                    label: 'All',
                    selected: filter.types.isEmpty,
                    onTap: () => _selectType(null),
                  ),
                  TypeChip(
                    label: 'Income',
                    icon: Icons.south_west_rounded,
                    selected: filter.types.contains(TransactionType.income),
                    color: context.palette.income,
                    container: context.palette.incomeContainer,
                    onTap: () => _selectType(TransactionType.income),
                  ),
                  TypeChip(
                    label: 'Expense',
                    icon: Icons.north_east_rounded,
                    selected: filter.types.contains(TransactionType.expense),
                    color: context.palette.expense,
                    container: context.palette.expenseContainer,
                    onTap: () => _selectType(TransactionType.expense),
                  ),
                  TypeChip(
                    label: 'Transfer',
                    icon: Icons.swap_horiz_rounded,
                    selected: filter.types.contains(TransactionType.transfer),
                    color: cs.primary,
                    container: cs.primaryContainer,
                    onTap: () => _selectType(TransactionType.transfer),
                  ),
                ],
              ),
            ),

            // Active category/account filters
            if (hasChipFilters)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.clear_all_rounded, size: 16),
                        label: const Text('Clear'),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(transactionFilterProvider.notifier).reset();
                        },
                      ),
                      ...filter.categoryIds.map((cid) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InputChip(
                              label: Text(categoryMap[cid]?.name ?? 'Category'),
                              onDeleted: () => ref
                                  .read(transactionFilterProvider.notifier)
                                  .toggleCategory(cid),
                            ),
                          )),
                      ...filter.accountIds.map((aid) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InputChip(
                              label: Text(accountMap[aid]?.name ?? 'Account'),
                              onDeleted: () => ref
                                  .read(transactionFilterProvider.notifier)
                                  .toggleAccount(aid),
                            ),
                          )),
                    ],
                  ),
                ),
              ),

            // List
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(
                      filtered: !filter.isEmpty,
                      onAdd: () => context.push(AppRoutes.addExpense),
                      onClear: () {
                        _searchController.clear();
                        ref.read(transactionFilterProvider.notifier).reset();
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 150),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        if (item is _DayHeader) {
                          return DayHeaderRow(
                            label: _dayLabel(item.day),
                            netMinor: item.netMinor,
                          );
                        }

                        final t = item as TransactionEntity;
                        final cat = categoryMap[t.categoryId];
                        final acc = accountMap[t.accountId];
                        final toAcc = t.toAccountId != null
                            ? accountMap[t.toAccountId]
                            : null;

                        return Dismissible(
                          key: ValueKey(t.id),
                          background: const SwipeBackground(
                            alignment: Alignment.centerLeft,
                            icon: Icons.edit_rounded,
                            label: 'Edit',
                            isDelete: false,
                          ),
                          secondaryBackground: const SwipeBackground(
                            alignment: Alignment.centerRight,
                            icon: Icons.delete_outline_rounded,
                            label: 'Delete',
                            isDelete: true,
                          ),
                          confirmDismiss: (dir) async {
                            if (dir == DismissDirection.startToEnd) {
                              _openEditTransaction(t);
                              return false;
                            }
                            return true;
                          },
                          onDismissed: (_) => _deleteWithUndo(t),
                          child: TxnTile(
                            transaction: t,
                            categoryName: cat?.name ?? 'Category',
                            categoryColor: cat?.colorValue,
                            categoryIconKey: cat?.iconKey,
                            accountLabel: t.isTransfer
                                ? '${acc?.name ?? 'Cash'} → ${toAcc?.name ?? 'Account'}'
                                : (acc?.name ?? 'Cash'),
                            onTap: () => _openEditTransaction(t),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── summary & chips ─────────────────────────

// ───────────────────────── list pieces ─────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.filtered,
    required this.onAdd,
    required this.onClear,
  });

  final bool filtered;
  final VoidCallback onAdd;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100, left: 32, right: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                filtered
                    ? Icons.search_off_rounded
                    : Icons.receipt_long_rounded,
                size: 44,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              filtered ? 'No matching transactions' : 'No transactions yet',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              filtered
                  ? 'Try a different search or clear your filters.'
                  : 'Add your first expense or income to start tracking.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            if (filtered)
              FilledButton.tonal(
                  onPressed: onClear, child: const Text('Clear filters'))
            else
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add transaction'),
              ),
          ],
        ),
      ),
    );
  }
}
