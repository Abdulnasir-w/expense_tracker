import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Currency metadata representing minor units (decimals), symbol, and name.
class CurrencyMeta {
  final String code;
  final String symbol;
  final String name;
  final int minorDigits;

  const CurrencyMeta({
    required this.code,
    required this.symbol,
    required this.name,
    this.minorDigits = 2,
  });

  /// 10^minorDigits factor
  int get factor {
    int f = 1;
    for (int i = 0; i < minorDigits; i++) {
      f *= 10;
    }
    return f;
  }
}

/// Utility helpers for formatting integer minor amounts (e.g. 1250 cents = $12.50).
class CurrencyFormatter {
  CurrencyFormatter._();

  static const Map<String, CurrencyMeta> supportedCurrencies = {
    'USD': CurrencyMeta(code: 'USD', symbol: '\$', name: 'US Dollar', minorDigits: 2),
    'PKR': CurrencyMeta(code: 'PKR', symbol: 'Rs', name: 'Pakistani Rupee', minorDigits: 2),
    'EUR': CurrencyMeta(code: 'EUR', symbol: 'â‚¬', name: 'Euro', minorDigits: 2),
    'GBP': CurrencyMeta(code: 'GBP', symbol: 'Â£', name: 'British Pound', minorDigits: 2),
    'JPY': CurrencyMeta(code: 'JPY', symbol: 'Â¥', name: 'Japanese Yen', minorDigits: 0),
    'KWD': CurrencyMeta(code: 'KWD', symbol: 'KD', name: 'Kuwaiti Dinar', minorDigits: 3),
    'INR': CurrencyMeta(code: 'INR', symbol: 'â‚¹', name: 'Indian Rupee', minorDigits: 2),
    'AED': CurrencyMeta(code: 'AED', symbol: 'AED', name: 'UAE Dirham', minorDigits: 2),
    'SAR': CurrencyMeta(code: 'SAR', symbol: 'SAR', name: 'Saudi Riyal', minorDigits: 2),
  };

  static CurrencyMeta getMeta(String? currencyCode) {
    if (currencyCode == null) {
      return supportedCurrencies[AppConstants.defaultCurrencyCode]!;
    }
    return supportedCurrencies[currencyCode.toUpperCase()] ??
        CurrencyMeta(code: currencyCode, symbol: currencyCode, name: currencyCode, minorDigits: 2);
  }

  /// Converts an integer minor amount to double (e.g. 1250 -> 12.50)
  static double toMajor(int amountMinor, [String? currencyCode]) {
    final meta = getMeta(currencyCode);
    return amountMinor / meta.factor;
  }

  /// Converts user input major double to integer minor (e.g. 12.50 -> 1250)
  static int toMinor(double amountMajor, [String? currencyCode]) {
    final meta = getMeta(currencyCode);
    return (amountMajor * meta.factor).round();
  }

  /// Formats an integer minor amount (e.g. 1250 -> "$12.50")
  static String format(int amountMinor, [String? currencyCode]) {
    final meta = getMeta(currencyCode);
    final major = toMajor(amountMinor, currencyCode);
    final formatter = NumberFormat.currency(
      symbol: meta.symbol,
      decimalDigits: meta.minorDigits,
    );
    return formatter.format(major);
  }

  /// Compact format for large numbers (e.g. 1250000 -> "$12.5K")
  static String formatCompact(int amountMinor, [String? currencyCode]) {
    final meta = getMeta(currencyCode);
    final major = toMajor(amountMinor, currencyCode);
    return NumberFormat.compactCurrency(symbol: meta.symbol).format(major);
  }
}
