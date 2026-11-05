import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/transactions/presentation/screens/transaction_list_screen.dart';
import '../../features/transactions/presentation/screens/add_expense_screen.dart';
import '../../features/transactions/presentation/screens/add_income_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../shared/widgets/app_shell.dart';

/// Named route constants — use these instead of raw strings.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String transactions = '/transactions';
  static const String addExpense = '/add-expense';
  static const String addIncome = '/add-income';
  static const String settings = '/settings';
  static const String statistics = '/statistics';
}

/// Global GoRouter provider.
///
/// Inject via [ref.watch(appRouterProvider)] in [App.build].
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // Shell wraps tabs with a persistent BottomNavigationBar
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (c, s) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.transactions,
            name: 'transactions',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: TransactionListScreen()),
          ),
          GoRoute(
            path: AppRoutes.statistics,
            name: 'statistics',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: StatisticsScreen()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),

      // Modal routes (slide up, not shell children)
      GoRoute(
        path: AppRoutes.addExpense,
        name: 'add-expense',
        pageBuilder: (c, s) => CustomTransitionPage(
          child: const AddExpenseScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.addIncome,
        name: 'add-income',
        pageBuilder: (c, s) => CustomTransitionPage(
          child: const AddIncomeScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
    ],
  );
});

/// Slide-up transition used for modal/form screens.
Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: animation.drive(
      Tween(begin: const Offset(0, 1), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOut)),
    ),
    child: child,
  );
}

