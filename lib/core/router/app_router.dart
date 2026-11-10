import 'package:expense_tracker/core/router/app_routes.dart';
import 'package:expense_tracker/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:expense_tracker/features/onboarding/presentation/screens/profile_setup_screen.dart';
import 'package:expense_tracker/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:expense_tracker/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:expense_tracker/features/profile/presentation/screens/profile_screen.dart';
import 'package:expense_tracker/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/transactions/presentation/screens/transaction_list_screen.dart';
import '../../features/transactions/presentation/screens/transaction_form_screen.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/accounts/presentation/screens/accounts_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/budgets/presentation/screens/budgets_screen.dart';
import '../../features/recurring/presentation/screens/recurring_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/app_tour.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Splash decides: Welcome for new users, Home for returning ones.
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      // ── Launch flow (fade transitions, no back stack) ──
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (c, s) => CustomTransitionPage(
          child: const SplashScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        pageBuilder: (c, s) => CustomTransitionPage(
          child: const WelcomeScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (c, s) => CustomTransitionPage(
          child: const OnboardingScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        name: 'profile-setup',
        pageBuilder: (c, s) => CustomTransitionPage(
          child: const ProfileSetupScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ── Main app (tabs) ──
      ShellRoute(
        builder: (context, state, child) =>
            TourHost(child: AppShell(child: child)),
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

      // ── Profile (full-screen, outside the shell) ──
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (c, s) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit', // resolves to /profile/edit
            name: 'edit-profile',
            builder: (c, s) => const EditProfileScreen(),
          ),
        ],
      ),

      // ── Management & Planning (full-screen) ──
      GoRoute(
        path: AppRoutes.accounts,
        name: 'accounts',
        builder: (c, s) => const AccountsScreen(),
      ),
      GoRoute(
        path: AppRoutes.categories,
        name: 'categories',
        builder: (c, s) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.budgets,
        name: 'budgets',
        builder: (c, s) => const BudgetsScreen(),
      ),
      GoRoute(
        path: AppRoutes.recurring,
        name: 'recurring',
        builder: (c, s) => const RecurringScreen(),
      ),

      // ── Modal routes using unified TransactionFormScreen ──
      GoRoute(
        path: AppRoutes.addExpense,
        name: 'add-expense',
        pageBuilder: (c, s) => CustomTransitionPage(
          child:
              const TransactionFormScreen(defaultType: TransactionType.expense),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.addIncome,
        name: 'add-income',
        pageBuilder: (c, s) => CustomTransitionPage(
          child:
              const TransactionFormScreen(defaultType: TransactionType.income),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.addTransfer,
        name: 'add-transfer',
        pageBuilder: (c, s) => CustomTransitionPage(
          child: const TransactionFormScreen(
              defaultType: TransactionType.transfer),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
    ],
  );
});

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: child,
  );
}

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
