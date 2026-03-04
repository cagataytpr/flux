library;

/// Extension to get the appropriate symbol for a currency code.
extension CurrencySymbolExt on String {
  String get currencySymbol {
    switch (toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'TRY':
      default:
        return '₺';
    }
  }
}
