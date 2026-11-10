import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/categories/data/models/category_model.dart';
import '../../features/accounts/data/models/account_model.dart';
import '../../features/budgets/data/models/budget_model.dart';
import '../../features/recurring/data/models/recurring_rule_model.dart';

/// Service managing Hive database initialization, adapter registration,
/// box opening, and schema migrations.
class HiveService {
  HiveService._();

  static const int currentSchemaVersion = 2;

  // Box names
  static const String transactionsBoxName = 'transactions_v2';
  static const String categoriesBoxName = 'categories';
  static const String accountsBoxName = 'accounts';
  static const String budgetsBoxName = 'budgets';
  static const String recurringBoxName = 'recurring_rules';
  static const String settingsBoxName = 'app_settings';
  static const String appPrefsBoxName = 'app_prefs';

  // Seed default IDs
  static const String defaultAccountId = 'account_cash_default';
  static const String defaultCategoryIdOther = 'cat_other';

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    // Register all adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TransactionTypeHiveAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(CategoryModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(AccountModelAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(BudgetModelAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(RecurringRuleModelAdapter());

    // Open boxes
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(appPrefsBoxName);
    await Hive.openBox<TransactionModel>(transactionsBoxName);
    await Hive.openBox<CategoryModel>(categoriesBoxName);
    await Hive.openBox<AccountModel>(accountsBoxName);
    await Hive.openBox<BudgetModel>(budgetsBoxName);
    await Hive.openBox<RecurringRuleModel>(recurringBoxName);

    // Run schema migrations and seeds
    await _runMigrationsAndSeeds();
  }

  static Box get settingsBox => Hive.box(settingsBoxName);
  static Box get appPrefsBox => Hive.box(appPrefsBoxName);
  static Box<TransactionModel> get transactionsBox => Hive.box<TransactionModel>(transactionsBoxName);
  static Box<CategoryModel> get categoriesBox => Hive.box<CategoryModel>(categoriesBoxName);
  static Box<AccountModel> get accountsBox => Hive.box<AccountModel>(accountsBoxName);
  static Box<BudgetModel> get budgetsBox => Hive.box<BudgetModel>(budgetsBoxName);
  static Box<RecurringRuleModel> get recurringBox => Hive.box<RecurringRuleModel>(recurringBoxName);

  static Future<void> _runMigrationsAndSeeds() async {
    final storedVersion = settingsBox.get('schema_version', defaultValue: 0) as int;

    // Seed default account if empty
    if (accountsBox.isEmpty) {
      final cashAccount = AccountModel()
        ..id = defaultAccountId
        ..name = 'Cash'
        ..type = 'cash'
        ..currencyCode = 'USD'
        ..initialBalanceMinor = 0
        ..colorValue = Colors.green.toARGB32()
        ..iconKey = 'wallet'
        ..isArchived = false;
      await accountsBox.put(cashAccount.id, cashAccount);
    }

    // Seed default categories if empty
    if (categoriesBox.isEmpty) {
      await _seedDefaultCategories();
    }

    // If migrating from v0 or v1 to v2:
    if (storedVersion < currentSchemaVersion) {
      // Check if legacy 'transactions' box exists from v1
      if (await Hive.boxExists('transactions')) {
        try {
          final legacyBox = await Hive.openBox('transactions');
          for (final key in legacyBox.keys) {
            final old = legacyBox.get(key);
            if (old != null) {
              // Map legacy transaction if any
              final newId = 'legacy_$key';
              final double amountDouble = (old.amount is num) ? (old.amount as num).toDouble() : 0.0;
              final String typeStr = old.type?.toString() ?? 'expense';
              final typeHive = typeStr.contains('income')
                  ? TransactionTypeHive.income
                  : TransactionTypeHive.expense;

              final model = TransactionModel()
                ..id = newId
                ..type = typeHive
                ..amountMinor = (amountDouble * 100).round()
                ..currencyCode = 'USD'
                ..categoryId = _mapLegacyCategory(old.category?.toString() ?? 'Other')
                ..accountId = defaultAccountId
                ..date = old.date is DateTime ? old.date as DateTime : DateTime.now()
                ..title = old.title?.toString() ?? 'Transaction'
                ..note = old.note?.toString()
                ..createdAt = DateTime.now()
                ..updatedAt = DateTime.now();

              await transactionsBox.put(model.id, model);
            }
          }
          await legacyBox.close();
        } catch (_) {}
      }

      await settingsBox.put('schema_version', currentSchemaVersion);
    }
  }

  static String _mapLegacyCategory(String legacyName) {
    for (final cat in categoriesBox.values) {
      if (cat.name.toLowerCase() == legacyName.toLowerCase()) {
        return cat.id;
      }
    }
    return defaultCategoryIdOther;
  }

  static Future<void> _seedDefaultCategories() async {
    final defaults = [
      // Expense
      CategoryModel()..id = 'cat_food'..name = 'Food & Dining'..iconKey = 'restaurant'..colorValue = Colors.orange.toARGB32()..type = 'expense'..sortOrder = 0,
      CategoryModel()..id = 'cat_transport'..name = 'Transport'..iconKey = 'directions_car'..colorValue = Colors.blue.toARGB32()..type = 'expense'..sortOrder = 1,
      CategoryModel()..id = 'cat_shopping'..name = 'Shopping'..iconKey = 'shopping_bag'..colorValue = Colors.purple.toARGB32()..type = 'expense'..sortOrder = 2,
      CategoryModel()..id = 'cat_bills'..name = 'Bills & Utilities'..iconKey = 'receipt_long'..colorValue = Colors.indigo.toARGB32()..type = 'expense'..sortOrder = 3,
      CategoryModel()..id = 'cat_entertainment'..name = 'Entertainment'..iconKey = 'sports_esports'..colorValue = Colors.pink.toARGB32()..type = 'expense'..sortOrder = 4,
      CategoryModel()..id = 'cat_health'..name = 'Health'..iconKey = 'medical_services'..colorValue = Colors.teal.toARGB32()..type = 'expense'..sortOrder = 5,
      CategoryModel()..id = defaultCategoryIdOther..name = 'Other'..iconKey = 'category'..colorValue = Colors.blueGrey.toARGB32()..type = 'both'..sortOrder = 6,

      // Income
      CategoryModel()..id = 'cat_salary'..name = 'Salary'..iconKey = 'payments'..colorValue = Colors.green.toARGB32()..type = 'income'..sortOrder = 7,
      CategoryModel()..id = 'cat_freelance'..name = 'Freelance'..iconKey = 'work'..colorValue = Colors.cyan.toARGB32()..type = 'income'..sortOrder = 8,
      CategoryModel()..id = 'cat_investment'..name = 'Investment'..iconKey = 'trending_up'..colorValue = Colors.deepPurple.toARGB32()..type = 'income'..sortOrder = 9,
    ];

    for (final c in defaults) {
      await categoriesBox.put(c.id, c);
    }
  }

  static Future<void> closeAll() async => Hive.close();
}
