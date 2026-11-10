class CurrencyOption {
  const CurrencyOption(this.code, this.name);
  final String code;
  final String name;
}

/// Starter list. Replace with a full ISO 4217 picker when you build
/// the multi-currency feature.
const kCurrencies = <CurrencyOption>[
  CurrencyOption('PKR', 'Pakistani Rupee'),
  CurrencyOption('USD', 'US Dollar'),
  CurrencyOption('EUR', 'Euro'),
  CurrencyOption('GBP', 'British Pound'),
  CurrencyOption('AED', 'UAE Dirham'),
  CurrencyOption('SAR', 'Saudi Riyal'),
  CurrencyOption('INR', 'Indian Rupee'),
  CurrencyOption('BDT', 'Bangladeshi Taka'),
  CurrencyOption('CAD', 'Canadian Dollar'),
  CurrencyOption('AUD', 'Australian Dollar'),
  CurrencyOption('TRY', 'Turkish Lira'),
  CurrencyOption('CNY', 'Chinese Yuan'),
];

CurrencyOption currencyByCode(String code) => kCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => kCurrencies.first,
    );

/// Picks a sensible default currency from the device region.
String currencyForCountry(String? countryCode) {
  switch (countryCode) {
    case 'PK':
      return 'PKR';
    case 'GB':
      return 'GBP';
    case 'AE':
      return 'AED';
    case 'SA':
      return 'SAR';
    case 'IN':
      return 'INR';
    case 'BD':
      return 'BDT';
    case 'CA':
      return 'CAD';
    case 'AU':
      return 'AUD';
    case 'TR':
      return 'TRY';
    case 'CN':
      return 'CNY';
    case 'DE':
    case 'FR':
    case 'IT':
    case 'ES':
    case 'NL':
      return 'EUR';
    default:
      return 'USD';
  }
}
