import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:expense_tracker/core/router/app_routes.dart';
import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:expense_tracker/shared/widgets/app_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class _NavSpec {
  const _NavSpec(this.label, this.icon, this.activeIcon, this.route);
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
}

const _tabs = [
  _NavSpec('Home', FluentIcons.home_24_regular, FluentIcons.home_24_filled,
      AppRoutes.home),
  _NavSpec('Activity', FluentIcons.receipt_20_regular,
      FluentIcons.receipt_24_filled, AppRoutes.transactions),
  _NavSpec('Analytics', FluentIcons.data_pie_24_regular,
      FluentIcons.data_pie_24_filled, AppRoutes.statistics),
  _NavSpec('Settings', FluentIcons.settings_24_regular,
      FluentIcons.settings_24_filled, AppRoutes.settings),
];

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _menu = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
    reverseDuration: const Duration(milliseconds: 200),
  );
  bool _open = false;

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _open = !_open);
    _open ? _menu.forward() : _menu.reverse();
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    _menu.reverse();
  }

  void _openRoute(String route) {
    _close();
    context.push(route);
  }

  int _indexFor(String location) {
    if (location.startsWith(AppRoutes.transactions)) return 1;
    if (location.startsWith(AppRoutes.statistics)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selected = _indexFor(location);
    final keys = ref.watch(tourKeysProvider);
    final cs = Theme.of(context).colorScheme;
    final pal = context.palette;
    final inset = MediaQuery.paddingOf(context).bottom;
    final navBottom = inset + 10;

    final actions = <_MenuAction>[
      _MenuAction(
        title: 'Add income',
        subtitle: 'Money coming in',
        icon: FluentIcons.arrow_down_24_regular,
        fg: pal.income,
        bg: pal.incomeContainer,
        route: AppRoutes.addIncome,
      ),
      _MenuAction(
        title: 'Add expense',
        subtitle: 'Money going out',
        icon: FluentIcons.arrow_up_24_regular,
        fg: pal.expense,
        bg: pal.expenseContainer,
        route: AppRoutes.addExpense,
      ),
      _MenuAction(
        title: 'Transfer',
        subtitle: 'Between your accounts',
        icon: Icons.swap_horiz_rounded,
        fg: cs.primary,
        bg: cs.primaryContainer,
        route: AppRoutes.addTransfer,
      ),
    ];

    return TourHost(
      child: PopScope(
        canPop: !_open,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _close();
        },
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: widget.child),

              // Scrim + action menu
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _menu,
                  builder: (context, _) {
                    if (_menu.isDismissed) return const SizedBox.shrink();
                    final t = _menu.value.clamp(0.0, 1.0);

                    double stagger(int order) {
                      final begin = 0.06 * order;
                      return Interval(
                        begin,
                        math.min(1.0, begin + 0.6),
                        curve: Curves.easeOutCubic,
                      ).transform(_menu.value);
                    }

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _close,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: 5 * t, sigmaY: 5 * t),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.4 * t),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: navBottom + 92 + 10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = actions.length - 1; i >= 0; i--)
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: i == actions.length - 1 ? 0 : 10),
                                  child: Opacity(
                                    opacity: stagger(i).clamp(0.0, 1.0),
                                    child: Transform.translate(
                                      offset: Offset(0, (1 - stagger(i)) * 18),
                                      child: _MenuTile(
                                        action: actions[i],
                                        onTap: () =>
                                            _openRoute(actions[i].route),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Floating navigation bar
              Positioned(
                left: 16,
                right: 16,
                bottom: navBottom,
                child: _FloatingNavBar(
                  selectedIndex: selected,
                  keys: keys,
                  menu: _menu,
                  onAdd: _toggle,
                  onSelect: (i) {
                    _close();
                    if (i != selected) context.go(_tabs[i].route);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── nav bar ─────────────────────────

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.selectedIndex,
    required this.onSelect,
    required this.onAdd,
    required this.menu,
    required this.keys,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  final Animation<double> menu;
  final TourKeys keys;

  GlobalKey? _keyFor(int i) => switch (i) {
        1 => keys.navTransactions,
        2 => keys.navStatistics,
        3 => keys.navSettings,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = cs.brightness == Brightness.dark;
    final barColor = dark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest;

    return SizedBox(
      height: 92,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 68,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: dark ? 0.6 : 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: dark ? 0.45 : 0.10),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++) ...[
                    if (i == 2) const SizedBox(width: 84),
                    Expanded(
                      child: _NavItem(
                        key: _keyFor(i),
                        spec: _tabs[i],
                        selected: selectedIndex == i,
                        onTap: () => onSelect(i),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _AddButton(
                key: keys.addButton,
                menu: menu,
                onTap: onAdd,
                ringColor: barColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 68,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 52,
                height: 30,
                decoration: BoxDecoration(
                  color: selected ? cs.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  selected ? spec.activeIcon : spec.icon,
                  size: 22,
                  color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                spec.label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    super.key,
    required this.menu,
    required this.onTap,
    required this.ringColor,
  });

  final Animation<double> menu;
  final VoidCallback onTap;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Semantics(
      button: true,
      label: 'Add transaction',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 68,
          height: 68,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ringColor,
            boxShadow: [
              BoxShadow(
                color: pal.heroGradient.last.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: pal.heroGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: menu,
                builder: (_, __) => Transform.rotate(
                  angle:
                      Curves.easeOutBack.transform(menu.value.clamp(0.0, 1.0)) *
                          (math.pi / 4),
                  child: Icon(Icons.add_rounded, size: 32, color: pal.onHero),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── action menu ─────────────────────────

class _MenuAction {
  const _MenuAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.fg,
    required this.bg,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color fg;
  final Color bg;
  final String route;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.action, required this.onTap});

  final _MenuAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dark = cs.brightness == Brightness.dark;

    return SizedBox(
      width: 272,
      child: Material(
        color: dark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: action.bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(action.icon, color: action.fg, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        action.subtitle,
                        style:
                            tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
