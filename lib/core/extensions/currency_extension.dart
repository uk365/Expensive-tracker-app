import 'package:intl/intl.dart';

extension CurrencyExtension on num {
  String toCurrencyString({String currency = 'USD', bool compact = false}) {
    if (compact) {
      if (abs() >= 1000000) {
        return '${currency == 'USD' ? '\$' : currency}${(this / 1000000).toStringAsFixed(1)}M';
      } else if (abs() >= 1000) {
        return '${currency == 'USD' ? '\$' : currency}${(this / 1000).toStringAsFixed(1)}K';
      }
    }
    final format = NumberFormat.currency(
      symbol: _currencySymbol(currency),
      decimalDigits: 2,
    );
    return format.format(this);
  }

  String formatCurrency({String currency = 'USD'}) =>
      toCurrencyString(currency: currency);

  String get formatCompact => toCurrencyString(compact: true);
}

String _currencySymbol(String currency) {
  const symbols = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'CAD': 'CA\$',
    'AUD': 'A\$',
    'JPY': '¥',
    'CHF': 'Fr',
    'SGD': 'S\$',
    'BRL': 'R\$',
  };
  return symbols[currency] ?? currency;
}
