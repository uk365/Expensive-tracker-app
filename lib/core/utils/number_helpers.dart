import 'package:intl/intl.dart';

class NumberHelpers {
  NumberHelpers._();

  static String formatCurrency(
    double amount, {
    String currency = 'USD',
    bool compact = false,
  }) {
    if (compact) {
      if (amount.abs() >= 1000000) {
        return '\$${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount.abs() >= 1000) {
        return '\$${(amount / 1000).toStringAsFixed(1)}K';
      }
    }
    return NumberFormat.currency(
      symbol: _symbol(currency),
      decimalDigits: 2,
    ).format(amount);
  }

  static String formatPercent(double value, {int decimals = 1}) {
    return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(decimals)}%';
  }

  static double computeMRR(List<Map<String, dynamic>> nodes) {
    double mrr = 0;
    for (final node in nodes) {
      if (node['status'] != 'active') continue;
      final amount = (node['amount'] as num?)?.toDouble() ?? 0;
      final cycle = node['billing_cycle'] as String? ?? '';
      switch (cycle) {
        case 'monthly':
          mrr += amount;
          break;
        case 'yearly':
          mrr += amount / 12;
          break;
        case 'quarterly':
          mrr += amount / 3;
          break;
        case 'weekly':
          mrr += amount * 4.33;
          break;
        case 'daily':
          mrr += amount * 30;
          break;
      }
    }
    return mrr;
  }

  static String _symbol(String currency) {
    const symbols = {
      'USD': '\$', 'EUR': '€', 'GBP': '£',
      'CAD': 'CA\$', 'AUD': 'A\$', 'JPY': '¥',
      'INR': '₹', 'BRL': 'R\$',
    };
    return symbols[currency] ?? currency;
  }
}
