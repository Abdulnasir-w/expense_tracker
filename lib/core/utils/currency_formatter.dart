import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility helpers for formatting currency amounts.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    symbol: AppConstants.defaultCurrencySymbol,
    decimalDigits: 2,
  );

  /// Formats a double as a currency string, e.g. `\$1,234.56`.
  static String format(double amount) => _formatter.format(amount);

  /// Formats without symbol, e.g. `1,234.56`.
  static String formatNoSymbol(double amount) =>
      NumberFormat('#,##0.00').format(amount);

  /// Compact format for large numbers, e.g. `\$1.2K`, `\$3.4M`.
  static String formatCompact(double amount) =>
      NumberFormat.compactCurrency(symbol: AppConstants.defaultCurrencySymbol)
          .format(amount);
}

