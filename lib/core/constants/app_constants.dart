/// App-wide constants used across all features.
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Expense Tracker';
  static const String appVersion = '1.0.0';

  // Isar database
  static const String isarDbName = 'expense_tracker_db';

  // Date formats
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String displayMonthFormat = 'MMM yyyy';
  static const String storageDateFormat = 'yyyy-MM-dd';

  // Transaction types
  static const String income = 'income';
  static const String expense = 'expense';

  // Categories
  static const List<String> expenseCategories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Entertainment',
    'Health',
    'Bills & Utilities',
    'Education',
    'Other',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Other',
  ];

  // Default currency
  static const String defaultCurrencySymbol = '\$';
  static const String defaultCurrencyCode = 'USD';
}

