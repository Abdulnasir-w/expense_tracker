import 'dart:math' as math;

import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:expense_tracker/shared/widgets/hero_state_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_category_icons.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_tour.dart';
import '../../../../shared/widgets/category_badge.dart';
import '../../../../shared/widgets/screen_header.dart';
import '../../../accounts/presentation/controllers/accounts_controller.dart';
import '../../../categories/presentation/controllers/categories_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/widgets/profile_form_widget.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';
import '../../../transactions/presentation/screens/transaction_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final balanceMinor = ref.watch(balanceProvider);
    final transactionsAsync = ref.watch(transactionControllerProvider);
    final accounts = ref.watch(activeAccountsProvider);
    final accountBalances = ref.watch(accountBalancesProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final categoryMap = {for (var c in categories) c.id: c};
    final profile = ref.watch(profileControllerProvider);
    final tourKeys = ref.watch(tourKeysProvider);

    final now = DateTime.now();
    final txs = transactionsAsync.valueOrNull ?? const <TransactionEntity>[];
    final stats = _HomeStats.from(txs, now);
    final budgetMinor = profile?.monthlyBudgetMinor ?? 0;

    return AppStatusBar(
      child: Scaffold(
        body: RefreshIndicator(
          edgeOffset: MediaQuery.paddingOf(context).top + 8,
          onRefresh: () async => ref.invalidate(transactionControllerProvider),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 150),
            children: [
              _HomeHeader(
                fullName: profile?.name ?? '',
                displayName: profile?.displayName ?? 'Guest',
                avatarPath: profile?.avatarPath,
                onProfile: () => context.push(AppRoutes.profile),
              ),
              _BalanceHero(
                key: tourKeys.balanceCard,
                balanceMinor: balanceMinor,
                monthIncome: stats.monthIncome,
                monthExpense: stats.monthExpense,
                hidden: _hidden,
                onToggle: () => setState(() => _hidden = !_hidden),
              ),
              const _QuickActions(),
              if (budgetMinor > 0)
                _BudgetCard(
                  budgetMinor: budgetMinor,
                  spentMinor: stats.monthExpense,
                  hidden: _hidden,
                )
              else
                _BudgetPrompt(onTap: () => context.push(AppRoutes.profile)),
              _WeekCard(
                days: stats.last7,
                total: stats.last7Total,
                prevTotal: stats.prev7Total,
                hidden: _hidden,
              ),
              if (accounts.isNotEmpty) ...[
                _SectionHeader(
                    title: 'Accounts', trailing: '${accounts.length}'),
                SizedBox(
                  height: 122,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final acc = accounts[index];
                      final balance =
                          accountBalances[acc.id] ?? acc.initialBalanceMinor;
                      return _AccountCard(
                        name: acc.name,
                        icon: AppCategoryIcons.getIcon(acc.iconKey),
                        accent: Color(acc.colorValue),
                        balanceText: _hidden
                            ? '••••••'
                            : CurrencyFormatter.format(
                                balance, acc.currencyCode),
                        negative: balance < 0,
                      );
                    },
                  ),
                ),
              ],
              _SectionHeader(
                title: 'Recent transactions',
                actionLabel: 'See all',
                onAction: () => context.go(AppRoutes.transactions),
              ),
              transactionsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: $e'),
                ),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return _EmptyRecent(
                      onAdd: () => context.push(AppRoutes.addExpense),
                    );
                  }
                  final recent = transactions.take(5).toList();
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < recent.length; i++) ...[
                          _RecentTile(
                            transaction: recent[i],
                            categoryName:
                                categoryMap[recent[i].categoryId]?.name ??
                                    'Category',
                            categoryColor:
                                categoryMap[recent[i].categoryId]?.colorValue,
                            categoryIcon:
                                categoryMap[recent[i].categoryId]?.iconKey,
                            hidden: _hidden,
                          ),
                          if (i < recent.length - 1)
                            Divider(
                              height: 1,
                              indent: 72,
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── derived stats ─────────────────────────

class _HomeStats {
  _HomeStats(this.monthIncome, this.monthExpense, this.last7, this.prev7Total);

  final int monthIncome;
  final int monthExpense;
  final List<int> last7; // index 6 = today
  final int prev7Total;

  int get last7Total => last7.fold(0, (a, b) => a + b);

  factory _HomeStats.from(List<TransactionEntity> txs, DateTime now) {
    final today = DateTime.utc(now.year, now.month, now.day);
    var income = 0;
    var expense = 0;
    var prev = 0;
    final days = List<int>.filled(7, 0);

    for (final t in txs) {
      if (t.date.year == now.year && t.date.month == now.month) {
        if (t.isIncome) {
          income += t.amountMinor;
        } else if (t.isExpense) {
          expense += t.amountMinor;
        }
      }
      if (t.isExpense) {
        final d = DateTime.utc(t.date.year, t.date.month, t.date.day);
        final diff = today.difference(d).inDays;
        if (diff >= 0 && diff < 7) {
          days[6 - diff] += t.amountMinor;
        } else if (diff >= 7 && diff < 14) {
          prev += t.amountMinor;
        }
      }
    }
    return _HomeStats(income, expense, days, prev);
  }
}

// ───────────────────────── header ─────────────────────────

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 5) return 'Good night';
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  if (h < 21) return 'Good evening';
  return 'Good night';
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.fullName,
    required this.displayName,
    required this.avatarPath,
    required this.onProfile,
  });

  final String fullName;
  final String displayName;
  final String? avatarPath;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final top = MediaQuery.paddingOf(context).top;
    final dark = cs.brightness == Brightness.dark;
    final first = displayName.trim().split(' ').first;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, top + 14, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onProfile,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: cs.primary.withValues(alpha: 0.45), width: 2),
              ),
              child: ProfileAvatar(
                name: fullName,
                path: avatarPath,
                radius: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                Text(
                  first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_month_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  DateFormat('MMM yyyy').format(DateTime.now()),
                  style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── balance hero ─────────────────────────

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({
    super.key,
    required this.balanceMinor,
    required this.monthIncome,
    required this.monthExpense,
    required this.hidden,
    required this.onToggle,
  });

  final int balanceMinor;
  final int monthIncome;
  final int monthExpense;
  final bool hidden;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final tt = Theme.of(context).textTheme;
    final net = monthIncome - monthExpense;
    final month = DateFormat('MMM').format(DateTime.now());
    String compact(int v) =>
        hidden ? '••••' : CurrencyFormatter.formatCompact(v);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pal.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: pal.heroGradient.last.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: _Orb(size: 170, color: pal.onHero.withValues(alpha: 0.08)),
            ),
            Positioned(
              left: -30,
              bottom: -60,
              child: _Orb(size: 150, color: pal.onHero.withValues(alpha: 0.06)),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total balance',
                        style: tt.labelLarge?.copyWith(
                          color: pal.onHero.withValues(alpha: 0.8),
                        ),
                      ),
                      const Spacer(),
                      Semantics(
                        button: true,
                        label: hidden ? 'Show balance' : 'Hide balance',
                        child: InkWell(
                          onTap: onToggle,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: pal.onHero.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              hidden
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 18,
                              color: pal.onHero,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: FittedBox(
                      key: ValueKey(hidden),
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        hidden
                            ? '••••••'
                            : CurrencyFormatter.format(balanceMinor),
                        style: tt.displaySmall?.copyWith(
                          color: pal.onHero,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                          net >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 15,
                          color: pal.onHero,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hidden
                              ? 'This month'
                              : '${net >= 0 ? '+' : '-'}${CurrencyFormatter.formatCompact(net.abs())} this month',
                          style: tt.labelMedium?.copyWith(
                            color: pal.onHero,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: HeroStatTile(
                          label: 'Income · $month',
                          value: compact(monthIncome),
                          icon: Icons.south_west_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: HeroStatTile(
                          label: 'Spent · $month',
                          value: compact(monthExpense),
                          icon: Icons.north_east_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ───────────────────────── quick actions ─────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final cs = Theme.of(context).colorScheme;

    final items = <_QA>[
      _QA('Income', Icons.south_west_rounded, pal.income, pal.incomeContainer,
          () => context.push(AppRoutes.addIncome)),
      _QA('Expense', Icons.north_east_rounded, pal.expense,
          pal.expenseContainer, () => context.push(AppRoutes.addExpense)),
      _QA('Transfer', Icons.swap_horiz_rounded, cs.primary, cs.primaryContainer,
          () => context.push(AppRoutes.addTransfer)),
      _QA('Reports', Icons.pie_chart_rounded, cs.secondary,
          cs.secondaryContainer, () => context.go(AppRoutes.statistics)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Material(
                    color: items[i].bg,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: items[i].onTap,
                      child: SizedBox(
                        height: 60,
                        width: double.infinity,
                        child:
                            Icon(items[i].icon, color: items[i].fg, size: 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[i].label,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QA {
  const _QA(this.label, this.icon, this.fg, this.bg, this.onTap);
  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;
  final VoidCallback onTap;
}

// ───────────────────────── budget ─────────────────────────

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budgetMinor,
    required this.spentMinor,
    required this.hidden,
  });

  final int budgetMinor;
  final int spentMinor;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;
    final now = DateTime.now();

    final used = spentMinor / budgetMinor;
    final remaining = budgetMinor - spentMinor;
    final color =
        used >= 1 ? cs.error : (used >= 0.75 ? pal.warning : cs.primary);
    final daysLeft =
        DateUtils.getDaysInMonth(now.year, now.month) - now.day + 1;
    final perDay = remaining > 0 ? (remaining / daysLeft).round() : 0;
    String fmt(int v) => hidden ? '••••' : CurrencyFormatter.format(v);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Monthly budget',
                    style:
                        tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(used * 100).round()}% used',
                    style: tt.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: used.clamp(0.0, 1.0),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              color: color,
              backgroundColor: cs.surfaceContainerHighest,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Spent ${fmt(spentMinor)}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                const Spacer(),
                Text(
                  remaining >= 0
                      ? '${fmt(remaining)} left'
                      : 'Over by ${fmt(-remaining)}',
                  style: tt.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w700, color: color),
                ),
              ],
            ),
            if (remaining > 0 && !hidden) ...[
              const SizedBox(height: 6),
              Text(
                'You can spend about ${CurrencyFormatter.formatCompact(perDay)} a day for the rest of the month',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BudgetPrompt extends StatelessWidget {
  const _BudgetPrompt({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CategoryBadge(icon: Icons.flag_rounded, color: cs.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set a monthly budget',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      'See how much you can still spend each month',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── last 7 days ─────────────────────────

class _WeekCard extends StatelessWidget {
  const _WeekCard({
    required this.days,
    required this.total,
    required this.prevTotal,
    required this.hidden,
  });

  final List<int> days;
  final int total;
  final int prevTotal;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;
    final maxV = days.fold<int>(0, math.max);
    final now = DateTime.now();

    final int? pct = prevTotal > 0
        ? (((total - prevTotal) / prevTotal) * 100).round()
        : null;
    final up = (pct ?? 0) > 0;
    final deltaColor = up ? pal.expense : pal.income;

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
                      Text('Spent in the last 7 days',
                          style: tt.labelLarge
                              ?.copyWith(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text(
                        hidden ? '••••••' : CurrencyFormatter.format(total),
                        style: tt.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                if (pct != null && pct != 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: deltaColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          up
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 13,
                          color: deltaColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${pct.abs()}% vs last week',
                          style: tt.labelSmall?.copyWith(
                            color: deltaColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 92,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final v = days[i];
                  final ratio = maxV > 0 ? v / maxV : 0.0;
                  final isToday = i == 6;
                  final date = now.subtract(Duration(days: 6 - i));
                  final label = DateFormat('E').format(date).substring(0, 1);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: math.max(ratio, 0.07),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? cs.primary
                                        : cs.primary.withValues(alpha: 0.28),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            style: tt.labelSmall?.copyWith(
                              fontWeight:
                                  isToday ? FontWeight.w800 : FontWeight.w500,
                              color: isToday ? cs.primary : cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── accounts ─────────────────────────

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.name,
    required this.icon,
    required this.accent,
    required this.balanceText,
    required this.negative,
  });

  final String name;
  final IconData icon;
  final Color accent;
  final String balanceText;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;
    final dark = cs.brightness == Brightness.dark;
    final base = dark ? cs.surfaceContainer : cs.surfaceContainerLowest;

    return Container(
      width: 176,
      margin: const EdgeInsets.only(right: 12, top: 2, bottom: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: base,
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.18),
            accent.withValues(alpha: 0.02)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryBadge(icon: icon, color: accent, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text('Balance',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              balanceText,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: negative ? pal.expense : cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── recent ─────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailing,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? trailing;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(trailing!,
                  style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
            ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({
    required this.transaction,
    required this.categoryName,
    required this.hidden,
    this.categoryColor,
    this.categoryIcon,
  });

  final TransactionEntity transaction;
  final String categoryName;
  final int? categoryColor;
  final String? categoryIcon;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;
    final t = transaction;

    final amountColor =
        t.isIncome ? pal.income : (t.isTransfer ? cs.primary : pal.expense);
    final sign = t.isIncome ? '+' : (t.isTransfer ? '' : '-');
    final badgeColor =
        categoryColor != null ? Color(categoryColor!) : amountColor;
    final amountText = hidden
        ? '••••'
        : '$sign${CurrencyFormatter.format(t.amountMinor, t.currencyCode)}';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionFormScreen(initialTransaction: t),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CategoryBadge(
              icon: AppCategoryIcons.getIcon(
                  categoryIcon ?? (t.isIncome ? 'payments' : 'category')),
              color: badgeColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$categoryName · ${DateFormatter.toRelative(t.date)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              amountText,
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.receipt_long_rounded, size: 34, color: cs.primary),
            ),
            const SizedBox(height: 16),
            Text('No transactions yet',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Log your first expense and it will show up here.',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add expense'),
            ),
          ],
        ),
      ),
    );
  }
}
