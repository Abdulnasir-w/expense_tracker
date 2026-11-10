import 'dart:math' as math;
import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:expense_tracker/shared/widgets/hero_state_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_category_icons.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/category_badge.dart';
import '../../../../shared/widgets/screen_header.dart';
import '../../../categories/presentation/controllers/categories_controller.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';

enum AnalyticsTimeRange { week, month, year, all }

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  AnalyticsTimeRange _timeRange = AnalyticsTimeRange.month;
  bool _isExpenseMode = true; // true = Expenses, false = Income
  String? _selectedCategoryId;

  DateTime _startDateFor(AnalyticsTimeRange range, DateTime now) {
    switch (range) {
      case AnalyticsTimeRange.week:
        return now.subtract(const Duration(days: 7));
      case AnalyticsTimeRange.month:
        return DateTime(now.year, now.month, 1);
      case AnalyticsTimeRange.year:
        return DateTime(now.year, 1, 1);
      case AnalyticsTimeRange.all:
        return DateTime(2000);
    }
  }

  int _daysInCurrentRange(AnalyticsTimeRange range, DateTime now) {
    switch (range) {
      case AnalyticsTimeRange.week:
        return 7;
      case AnalyticsTimeRange.month:
        return now.day;
      case AnalyticsTimeRange.year:
        return now.difference(DateTime(now.year, 1, 1)).inDays + 1;
      case AnalyticsTimeRange.all:
        return 30;
    }
  }

  /// The comparable window just before the current one (same elapsed length).
  (DateTime, DateTime)? _previousRange(AnalyticsTimeRange range, DateTime now) {
    switch (range) {
      case AnalyticsTimeRange.week:
        return (
          now.subtract(const Duration(days: 14)),
          now.subtract(const Duration(days: 7)),
        );
      case AnalyticsTimeRange.month:
        final ps = DateTime(now.year, now.month - 1, 1);
        final dim = DateUtils.getDaysInMonth(ps.year, ps.month);
        return (ps, DateTime(ps.year, ps.month, math.min(now.day, dim) + 1));
      case AnalyticsTimeRange.year:
        return (
          DateTime(now.year - 1, 1, 1),
          DateTime(now.year - 1, now.month, now.day + 1),
        );
      case AnalyticsTimeRange.all:
        return null;
    }
  }

  String _previousLabel(AnalyticsTimeRange range) => switch (range) {
        AnalyticsTimeRange.week => 'last week',
        AnalyticsTimeRange.month => 'last month',
        AnalyticsTimeRange.year => 'last year',
        AnalyticsTimeRange.all => '',
      };

  String _rangeTitle(AnalyticsTimeRange range, DateTime now) => switch (range) {
        AnalyticsTimeRange.week => 'Last 7 days',
        AnalyticsTimeRange.month => DateFormat('MMMM yyyy').format(now),
        AnalyticsTimeRange.year => '${now.year}',
        AnalyticsTimeRange.all => 'All time',
      };

  String _activitySubtitle(AnalyticsTimeRange range) => switch (range) {
        AnalyticsTimeRange.week => 'Daily totals, last 7 days',
        AnalyticsTimeRange.month => 'Weekly totals this month',
        AnalyticsTimeRange.year => 'Monthly totals, last 6 months',
        AnalyticsTimeRange.all => 'Monthly totals, last 6 months',
      };

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionControllerProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final categoryMap = {for (var c in categories) c.id: c};
    final now = DateTime.now();

    return AppStatusBar(
      child: Scaffold(
        body: transactionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (allTransactions) {
            final startDate = _startDateFor(_timeRange, now);

            final rangeTransactions = allTransactions
                .where((t) => t.date
                    .isAfter(startDate.subtract(const Duration(seconds: 1))))
                .toList();

            final incomeTransactions =
                rangeTransactions.where((t) => t.isIncome).toList();
            final expenseTransactions =
                rangeTransactions.where((t) => t.isExpense).toList();

            final totalIncomePeriod =
                incomeTransactions.fold<int>(0, (s, t) => s + t.amountMinor);
            final totalExpensePeriod =
                expenseTransactions.fold<int>(0, (s, t) => s + t.amountMinor);
            final netPeriod = totalIncomePeriod - totalExpensePeriod;
            final savingsRate = totalIncomePeriod > 0
                ? ((netPeriod / totalIncomePeriod) * 100).clamp(0.0, 100.0)
                : 0.0;

            final activeTransactions =
                _isExpenseMode ? expenseTransactions : incomeTransactions;
            final activeTotalMinor =
                _isExpenseMode ? totalExpensePeriod : totalIncomePeriod;

            // Change vs previous comparable period
            int? deltaPct;
            final prev = _previousRange(_timeRange, now);
            if (prev != null) {
              final prevTotal = allTransactions
                  .where((t) =>
                      (_isExpenseMode ? t.isExpense : t.isIncome) &&
                      !t.date.isBefore(prev.$1) &&
                      t.date.isBefore(prev.$2))
                  .fold<int>(0, (s, t) => s + t.amountMinor);
              if (prevTotal > 0) {
                deltaPct = (((activeTotalMinor - prevTotal) / prevTotal) * 100)
                    .round();
              }
            }

            final Map<String, int> categoryTotals = {};
            final Map<String, int> categoryCounts = {};
            for (final t in activeTransactions) {
              categoryTotals[t.categoryId] =
                  (categoryTotals[t.categoryId] ?? 0) + t.amountMinor;
              categoryCounts[t.categoryId] =
                  (categoryCounts[t.categoryId] ?? 0) + 1;
            }
            final sortedCategories = categoryTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final daysInRange =
                math.max(1, _daysInCurrentRange(_timeRange, now));
            final avgPerDayMinor = (activeTotalMinor / daysInRange).round();
            TransactionEntity? maxTxn;
            if (activeTransactions.isNotEmpty) {
              maxTxn = activeTransactions.reduce((curr, next) =>
                  curr.amountMinor > next.amountMinor ? curr : next);
            }
            final topEntry =
                sortedCategories.isNotEmpty ? sortedCategories.first : null;
            final topCategoryName = topEntry != null
                ? (categoryMap[topEntry.key]?.name ?? 'Uncategorized')
                : 'None';
            final topCategoryPct = (activeTotalMinor > 0 && topEntry != null)
                ? (topEntry.value / activeTotalMinor * 100).round()
                : 0;

            return RefreshIndicator(
              edgeOffset: MediaQuery.paddingOf(context).top + 8,
              onRefresh: () async =>
                  ref.invalidate(transactionControllerProvider),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 150),
                children: [
                  ScreenHeader(
                    title: 'Analytics',
                    subtitle: _rangeTitle(_timeRange, now),
                  ),
                  _TimeRangeSelector(
                    selected: _timeRange,
                    onChanged: (range) => setState(() {
                      _timeRange = range;
                      _selectedCategoryId = null;
                    }),
                  ),
                  _SummaryHero(
                    incomeMinor: totalIncomePeriod,
                    expenseMinor: totalExpensePeriod,
                    netMinor: netPeriod,
                    savingsRate: savingsRate,
                  ),
                  _ModeToggle(
                    isExpense: _isExpenseMode,
                    expenseCount: expenseTransactions.length,
                    incomeCount: incomeTransactions.length,
                    onChanged: (isExp) => setState(() {
                      _isExpenseMode = isExp;
                      _selectedCategoryId = null;
                    }),
                  ),
                  if (activeTransactions.isEmpty)
                    _EmptyState(isExpense: _isExpenseMode)
                  else ...[
                    _ChartCard(
                      title: _isExpenseMode
                          ? 'Where your money went'
                          : 'Where your income came from',
                      subtitle: 'Tap a segment to see details',
                      trailing: deltaPct != null && deltaPct != 0
                          ? _DeltaPill(
                              pct: deltaPct,
                              // for expenses, an increase is bad; for income, good
                              goodWhenUp: !_isExpenseMode,
                              caption: 'vs ${_previousLabel(_timeRange)}',
                            )
                          : null,
                      child: _DonutChartWidget(
                        key: ValueKey('$_timeRange$_isExpenseMode'),
                        entries: sortedCategories,
                        totalMinor: activeTotalMinor,
                        categoryMap: categoryMap,
                        selectedId: _selectedCategoryId,
                        onSelect: (id) => setState(() {
                          _selectedCategoryId =
                              _selectedCategoryId == id ? null : id;
                        }),
                      ),
                    ),
                    _ChartCard(
                      title: _isExpenseMode
                          ? 'Spending activity'
                          : 'Income activity',
                      subtitle: _activitySubtitle(_timeRange),
                      child: _ActivityBarChart(
                        transactions: activeTransactions,
                        timeRange: _timeRange,
                        now: now,
                      ),
                    ),
                    _SectionLabel(title: 'Highlights'),
                    _InsightsGrid(
                      avgPerDayMinor: avgPerDayMinor,
                      savingsRate: savingsRate,
                      topCategoryName: topCategoryName,
                      topCategoryPct: topCategoryPct,
                      maxTxn: maxTxn,
                    ),
                    _SectionLabel(
                      title: _isExpenseMode
                          ? 'Category breakdown'
                          : 'Income sources',
                      trailing: '${sortedCategories.length} categories',
                    ),
                    ...sortedCategories.map((entry) {
                      final cat = categoryMap[entry.key];
                      final count = categoryCounts[entry.key] ?? 1;
                      return _CategoryBreakdownTile(
                        key: ValueKey(entry.key),
                        name: cat?.name ?? 'Other',
                        iconKey: cat?.iconKey ?? 'category',
                        color: cat != null
                            ? Color(cat.colorValue)
                            : Colors.blueGrey,
                        totalMinor: entry.value,
                        count: count,
                        percentage: activeTotalMinor > 0
                            ? entry.value / activeTotalMinor
                            : 0.0,
                        avgTxnMinor: (entry.value / count).round(),
                        isSelected: _selectedCategoryId == entry.key,
                        onTap: () => setState(() {
                          _selectedCategoryId = _selectedCategoryId == entry.key
                              ? null
                              : entry.key;
                        }),
                      );
                    }),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selectors
// ─────────────────────────────────────────────────────────────────────────────

class _TimeRangeSelector extends StatelessWidget {
  final AnalyticsTimeRange selected;
  final ValueChanged<AnalyticsTimeRange> onChanged;

  const _TimeRangeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = cs.brightness == Brightness.dark;
    const ranges = [
      (AnalyticsTimeRange.week, 'Week'),
      (AnalyticsTimeRange.month, 'Month'),
      (AnalyticsTimeRange.year, 'Year'),
      (AnalyticsTimeRange.all, 'All'),
    ];
    final index = ranges.indexWhere((r) => r.$1 == selected);

    return Container(
      height: 46,
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark ? cs.surfaceContainerLow : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment(-1 + (2 * index / (ranges.length - 1)), 0),
            child: FractionallySizedBox(
              widthFactor: 1 / ranges.length,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: dark
                      ? cs.surfaceContainerHighest
                      : cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: dark ? 0.25 : 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final r in ranges)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(r.$1),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: r.$1 == selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: r.$1 == selected
                              ? cs.primary
                              : cs.onSurfaceVariant,
                        ),
                        child: Text(r.$2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool isExpense;
  final int expenseCount;
  final int incomeCount;
  final ValueChanged<bool> onChanged;

  const _ModeToggle({
    required this.isExpense,
    required this.expenseCount,
    required this.incomeCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pal = context.palette;
    final dark = cs.brightness == Brightness.dark;

    Widget pill({
      required bool active,
      required String label,
      required IconData icon,
      required Color fg,
      required Color bg,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: active ? bg : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: active ? fg : cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    color: active ? fg : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark ? cs.surfaceContainerLow : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          pill(
            active: isExpense,
            label: 'Expenses ($expenseCount)',
            icon: Icons.north_east_rounded,
            fg: pal.expense,
            bg: pal.expenseContainer,
            onTap: () => onChanged(true),
          ),
          pill(
            active: !isExpense,
            label: 'Income ($incomeCount)',
            icon: Icons.south_west_rounded,
            fg: pal.income,
            bg: pal.incomeContainer,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary hero
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryHero extends StatelessWidget {
  final int incomeMinor;
  final int expenseMinor;
  final int netMinor;
  final double savingsRate;

  const _SummaryHero({
    required this.incomeMinor,
    required this.expenseMinor,
    required this.netMinor,
    required this.savingsRate,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final tt = Theme.of(context).textTheme;
    final surplus = netMinor >= 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pal.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: pal.heroGradient.last.withValues(alpha: 0.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Net cash flow',
                style: tt.labelLarge
                    ?.copyWith(color: pal.onHero.withValues(alpha: 0.8)),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: pal.onHero.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      surplus
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: pal.onHero,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${savingsRate.toStringAsFixed(0)}% saved',
                      style: tt.labelMedium?.copyWith(
                        color: pal.onHero,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${surplus ? '' : '-'}${CurrencyFormatter.format(netMinor.abs())}',
              style: tt.headlineMedium?.copyWith(
                color: pal.onHero,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: HeroStatTile(
                  label: 'Inflow',
                  value: CurrencyFormatter.formatCompact(incomeMinor),
                  icon: Icons.south_west_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HeroStatTile(
                  label: 'Outflow',
                  value: CurrencyFormatter.formatCompact(expenseMinor),
                  icon: Icons.north_east_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cards & small pieces
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final String? trailing;
  const _SectionLabel({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
          if (trailing != null)
            Text(trailing!,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  final int pct;
  final bool goodWhenUp;
  final String caption;
  const _DeltaPill({
    required this.pct,
    required this.goodWhenUp,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final up = pct > 0;
    final good = up == goodWhenUp;
    final color = good ? pal.income : pal.expense;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 13,
                color: color,
              ),
              const SizedBox(width: 2),
              Text(
                '${pct.abs()}%',
                style: tt.labelMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(caption,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Donut chart (no dependencies)
// ─────────────────────────────────────────────────────────────────────────────

class _DonutSlice {
  final String id;
  final Color color;
  final double proportion;
  final bool isSelected;

  const _DonutSlice({
    required this.id,
    required this.color,
    required this.proportion,
    required this.isSelected,
  });
}

class _DonutChartWidget extends StatelessWidget {
  final List<MapEntry<String, int>> entries;
  final int totalMinor;
  final Map<String, dynamic> categoryMap;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _DonutChartWidget({
    super.key,
    required this.entries,
    required this.totalMinor,
    required this.categoryMap,
    required this.selectedId,
    required this.onSelect,
  });

  static const double _size = 220;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    String centerTitle = 'Total';
    int centerAmount = totalMinor;
    Color centerColor = cs.onSurfaceVariant;

    if (selectedId != null) {
      final selectedEntry = entries.firstWhere(
        (e) => e.key == selectedId,
        orElse: () => MapEntry(selectedId!, 0),
      );
      final cat = categoryMap[selectedId];
      centerTitle = cat?.name ?? 'Selected';
      centerAmount = selectedEntry.value;
      if (cat != null) centerColor = Color(cat.colorValue);
    }

    final slices = entries.map((e) {
      final cat = categoryMap[e.key];
      return _DonutSlice(
        id: e.key,
        color: cat != null ? Color(cat.colorValue) : Colors.blueGrey,
        proportion: totalMinor > 0 ? e.value / totalMinor : 0.0,
        isSelected: selectedId == e.key,
      );
    }).toList();

    void handleTap(Offset p) {
      const c = Offset(_size / 2, _size / 2);
      final d = p - c;
      final dist = d.distance;
      if (dist < _size / 2 - 48 || dist > _size / 2) return;
      var angle = math.atan2(d.dy, d.dx) + math.pi / 2;
      if (angle < 0) angle += 2 * math.pi;
      var acc = 0.0;
      for (final s in slices) {
        acc += s.proportion * 2 * math.pi;
        if (angle <= acc) {
          onSelect(s.id);
          return;
        }
      }
    }

    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTapUp: (d) => handleTap(d.localPosition),
            child: SizedBox(
              width: _size,
              height: _size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, progress, __) => CustomPaint(
                      size: const Size(_size, _size),
                      painter: _DonutChartPainter(
                        slices: slices,
                        progress: progress,
                        track: cs.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.all(46),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            centerTitle,
                            style: tt.labelMedium?.copyWith(
                              color: centerColor,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              CurrencyFormatter.format(centerAmount),
                              style: tt.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          if (totalMinor > 0 && selectedId != null)
                            Text(
                              '${((centerAmount / totalMinor) * 100).toStringAsFixed(1)}%',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: entries.take(6).map((e) {
            final cat = categoryMap[e.key];
            final color = cat != null ? Color(cat.colorValue) : Colors.blueGrey;
            final isSel = selectedId == e.key;

            return GestureDetector(
              onTap: () => onSelect(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSel
                      ? color.withValues(alpha: 0.16)
                      : cs.surfaceContainerHigh.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSel ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat?.name ?? 'Other',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<_DonutSlice> slices;
  final double progress;
  final Color track;

  const _DonutChartPainter({
    required this.slices,
    required this.progress,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const stroke = 24.0;
    final radius = size.width / 2 - 18;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // faint track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track.withValues(alpha: 0.5),
    );

    final visible = slices.where((s) => s.proportion > 0).toList();
    if (visible.isEmpty) return;

    // single slice: draw a full ring without a gap
    if (visible.length == 1) {
      final s = visible.first;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s.isSelected ? stroke + 6 : stroke
          ..color = s.color,
      );
      return;
    }

    const gap = 0.045;
    var start = -math.pi / 2;
    for (final s in visible) {
      final full = s.proportion * 2 * math.pi * progress;
      final sweep = full - gap;
      if (sweep > 0) {
        canvas.drawArc(
          rect,
          start + gap / 2,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = s.isSelected ? stroke + 6 : stroke
            ..strokeCap = StrokeCap.butt
            ..color = s.color,
        );
      }
      start += full;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter old) =>
      old.progress != progress ||
      old.track != track ||
      old.slices.length != slices.length ||
      !_sameSlices(old.slices, slices);

  bool _sameSlices(List<_DonutSlice> a, List<_DonutSlice> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].proportion != b[i].proportion ||
          a[i].isSelected != b[i].isSelected) {
        return false;
      }
    }
    return true;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity bar chart
// ─────────────────────────────────────────────────────────────────────────────

class _BarData {
  final String label;
  final int amountMinor;
  const _BarData({required this.label, required this.amountMinor});
}

class _ActivityBarChart extends StatefulWidget {
  final List<TransactionEntity> transactions;
  final AnalyticsTimeRange timeRange;
  final DateTime now;

  const _ActivityBarChart({
    required this.transactions,
    required this.timeRange,
    required this.now,
  });

  @override
  State<_ActivityBarChart> createState() => _ActivityBarChartState();
}

class _ActivityBarChartState extends State<_ActivityBarChart> {
  int? _selected;

  @override
  void didUpdateWidget(covariant _ActivityBarChart old) {
    super.didUpdateWidget(old);
    if (old.timeRange != widget.timeRange) _selected = null;
  }

  int _sum(Iterable<TransactionEntity> it) =>
      it.fold<int>(0, (s, t) => s + t.amountMinor);

  List<_BarData> _computeBars() {
    final tx = widget.transactions;
    final now = widget.now;
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const mn = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    switch (widget.timeRange) {
      case AnalyticsTimeRange.week:
        return [
          for (var i = 6; i >= 0; i--)
            () {
              final target = now.subtract(Duration(days: i));
              return _BarData(
                label: wd[(target.weekday - 1) % 7],
                amountMinor: _sum(tx.where((t) =>
                    t.date.year == target.year &&
                    t.date.month == target.month &&
                    t.date.day == target.day)),
              );
            }(),
        ];

      case AnalyticsTimeRange.month:
        return [
          _BarData(
              label: '1–7',
              amountMinor: _sum(tx.where((t) => t.date.day <= 7))),
          _BarData(
              label: '8–14',
              amountMinor:
                  _sum(tx.where((t) => t.date.day >= 8 && t.date.day <= 14))),
          _BarData(
              label: '15–21',
              amountMinor:
                  _sum(tx.where((t) => t.date.day >= 15 && t.date.day <= 21))),
          _BarData(
              label: '22+',
              amountMinor: _sum(tx.where((t) => t.date.day >= 22))),
        ];

      case AnalyticsTimeRange.year:
      case AnalyticsTimeRange.all:
        return [
          for (var i = 5; i >= 0; i--)
            () {
              final m = DateTime(now.year, now.month - i, 1);
              return _BarData(
                label: mn[(m.month - 1) % 12],
                amountMinor: _sum(tx.where(
                    (t) => t.date.year == m.year && t.date.month == m.month)),
              );
            }(),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bars = _computeBars();
    final maxVal = bars.fold<int>(0, (m, b) => math.max(m, b.amountMinor));
    final maxIndex = bars.indexWhere((b) => b.amountMinor == maxVal);
    final active = (_selected != null && _selected! < bars.length)
        ? _selected!
        : (maxVal > 0 ? maxIndex : -1);

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(bars.length, (i) {
              final b = bars[i];
              final ratio =
                  maxVal > 0 ? (b.amountMinor / maxVal).clamp(0.05, 1.0) : 0.05;
              final isActive = i == active;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selected = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              heightFactor: ratio,
                              widthFactor: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? cs.primary
                                      : cs.primary.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isActive ? FontWeight.w800 : FontWeight.w500,
                            color: isActive ? cs.primary : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        if (maxVal > 0 && active >= 0) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insights_rounded, size: 15, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  '${bars[active].label}: ${CurrencyFormatter.format(bars[active].amountMinor)}',
                  style: tt.labelLarge?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Highlights grid
// ─────────────────────────────────────────────────────────────────────────────

class _InsightsGrid extends StatelessWidget {
  final int avgPerDayMinor;
  final double savingsRate;
  final String topCategoryName;
  final int topCategoryPct;
  final TransactionEntity? maxTxn;

  const _InsightsGrid({
    required this.avgPerDayMinor,
    required this.savingsRate,
    required this.topCategoryName,
    required this.topCategoryPct,
    required this.maxTxn,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pal = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _MetricCard(
            icon: Icons.calendar_today_rounded,
            color: cs.primary,
            label: 'Daily average',
            value: CurrencyFormatter.format(avgPerDayMinor),
            subtext: 'per day',
          ),
          _MetricCard(
            icon: Icons.pie_chart_rounded,
            color: pal.warning,
            label: 'Top category',
            value: topCategoryName,
            subtext: '$topCategoryPct% of total',
          ),
          _MetricCard(
            icon: Icons.savings_rounded,
            color: pal.income,
            label: 'Savings rate',
            value: '${savingsRate.toStringAsFixed(0)}%',
            subtext: 'of income kept',
          ),
          _MetricCard(
            icon: Icons.local_fire_department_rounded,
            color: pal.expense,
            label: 'Largest entry',
            value: maxTxn != null
                ? CurrencyFormatter.format(maxTxn!.amountMinor)
                : 'N/A',
            subtext: maxTxn != null ? maxTxn!.title : 'No record',
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String subtext;

  const _MetricCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dark = cs.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CategoryBadge(icon: icon, color: color, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodySmall
                ?.copyWith(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category list
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryBreakdownTile extends StatelessWidget {
  final String name;
  final String iconKey;
  final Color color;
  final int totalMinor;
  final int count;
  final double percentage;
  final int avgTxnMinor;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryBreakdownTile({
    super.key,
    required this.name,
    required this.iconKey,
    required this.color,
    required this.totalMinor,
    required this.count,
    required this.percentage,
    required this.avgTxnMinor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dark = cs.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? color : cs.outlineVariant,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    CategoryBadge(
                      icon: AppCategoryIcons.getIcon(iconKey),
                      color: color,
                      size: 42,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: tt.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          Text(
                            '$count ${count == 1 ? 'transaction' : 'transactions'} · avg ${CurrencyFormatter.formatCompact(avgTxnMinor)}',
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(CurrencyFormatter.format(totalMinor),
                            style: tt.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        Text(
                          '${(percentage * 100).toStringAsFixed(1)}%',
                          style: tt.labelMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: percentage,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isExpense;
  const _EmptyState({required this.isExpense});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.insights_rounded, size: 40, color: cs.primary),
          ),
          const SizedBox(height: 18),
          Text(
            isExpense
                ? 'No expenses in this period'
                : 'No income in this period',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Try another time range above, or log a new transaction.',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
