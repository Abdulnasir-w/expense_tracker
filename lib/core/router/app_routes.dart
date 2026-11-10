/// Single source of truth for route paths (merged with the existing ones).
class AppRoutes {
  AppRoutes._();

  // Launch flow
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String profileSetup = '/profile-setup';

  // Shell tabs
  static const String home = '/';
  static const String transactions = '/transactions';
  static const String statistics = '/statistics';
  static const String settings = '/settings';

  // Modal transaction forms
  static const String addExpense = '/add-expense';
  static const String addIncome = '/add-income';
  static const String addTransfer = '/add-transfer';

  // Profile (full-screen, outside the shell)
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  // Management & Planning
  static const String accounts = '/accounts';
  static const String categories = '/categories';
  static const String budgets = '/budgets';
  static const String recurring = '/recurring';
}
