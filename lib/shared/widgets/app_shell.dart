import 'package:expense_tracker/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

/// Navigation destinations for the bottom nav bar.
const _destinations = [
  _NavItem(
      label: 'Home',
      icon: FluentIcons.home_24_regular,
      activeIcon: FluentIcons.home_24_filled,
      route: AppRoutes.home),
  _NavItem(
      label: 'Transactions',
      icon: FluentIcons.call_transfer_24_regular,
      activeIcon: FluentIcons.call_transfer_24_filled,
      route: AppRoutes.transactions),
  _NavItem(
      label: 'Statistics',
      icon: FluentIcons.data_pie_24_regular,
      activeIcon: FluentIcons.data_pie_24_filled,
      route: AppRoutes.statistics),
  _NavItem(
      label: 'Settings',
      icon: FluentIcons.settings_24_regular,
      activeIcon: FluentIcons.settings_24_filled,
      route: AppRoutes.settings),
];

/// Shell widget that wraps all tab screens.
/// Provides a persistent [NavigationBar] (Material 3) at the bottom
/// and a floating [SpeedDial] FAB for adding income/expense.
class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.transactions)) return 1;
    if (location.startsWith(AppRoutes.statistics)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _locationToIndex(location);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _AddFab(colorScheme: colorScheme),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (int i = 0; i < _destinations.length; i++) ...[
              if (i == 2) const SizedBox(width: 72), // FAB gap
              _NavBarButton(
                item: _destinations[i],
                isSelected: selectedIndex == i,
                onTap: () => context.go(_destinations[i].route),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavBarButton extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(
          isSelected ? item.activeIcon : item.icon,
          color: color,
          size: 26,
        ),
      ),
    );
  }
}

class _AddFab extends StatefulWidget {
  final ColorScheme colorScheme;
  const _AddFab({required this.colorScheme});

  @override
  State<_AddFab> createState() => _AddFabState();
}

class _AddFabState extends State<_AddFab> with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _controller;
  late final Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _rotateAnim = Tween<double>(begin: 0, end: 0.375).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _controller.forward() : _controller.reverse();
  }

  void _openScreen(String route) {
    _toggle();
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_open) ...[
          _MiniActionButton(
            icon: FluentIcons.arrow_down_24_regular,
            label: 'Income',
            color: Colors.green,
            onTap: () => _openScreen(AppRoutes.addIncome),
          ),
          const SizedBox(height: 8),
          _MiniActionButton(
            icon: FluentIcons.arrow_up_24_regular,
            label: 'Expense',
            color: Colors.red,
            onTap: () => _openScreen(AppRoutes.addExpense),
          ),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: widget.colorScheme.primary,
          foregroundColor: Colors.white,
          child: RotationTransition(
            turns: _rotateAnim,
            child: const Icon(Icons.add, size: 28),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MiniActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onTap,
      backgroundColor: color,
      foregroundColor: Colors.white,
      heroTag: label,
      icon: Icon(icon, size: 20),
      label: Text(label),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}
