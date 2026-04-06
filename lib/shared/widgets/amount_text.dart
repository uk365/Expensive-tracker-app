import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/currency_extension.dart';

enum AmountSize { small, medium, large, display }

class AmountText extends StatelessWidget {
  final double amount;
  final String currency;
  final String? type;
  final AmountSize size;
  final bool showSign;
  final bool compact;
  final Color? color;

  const AmountText({
    super.key,
    required this.amount,
    this.currency = 'USD',
    this.type,
    this.size = AmountSize.medium,
    this.showSign = false,
    this.compact = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? _colorForType;
    final text = _formattedAmount;

    return Text(
      showSign && amount > 0 ? '+$text' : text,
      style: GoogleFonts.jetBrainsMono(
        fontSize: _fontSize,
        fontWeight: _fontWeight,
        color: effectiveColor,
      ),
    );
  }

  Color get _colorForType {
    if (type == null) return AppColors.textPrimary;
    switch (type!) {
      case 'income':
        return AppColors.income;
      case 'expense':
        return AppColors.expense;
      case 'donation':
        return AppColors.donation;
      default:
        return AppColors.textPrimary;
    }
  }

  double get _fontSize {
    switch (size) {
      case AmountSize.small:
        return 12;
      case AmountSize.medium:
        return 14;
      case AmountSize.large:
        return 18;
      case AmountSize.display:
        return 32;
    }
  }

  FontWeight get _fontWeight {
    switch (size) {
      case AmountSize.small:
        return FontWeight.w500;
      case AmountSize.medium:
        return FontWeight.w500;
      case AmountSize.large:
        return FontWeight.w600;
      case AmountSize.display:
        return FontWeight.w700;
    }
  }

  String get _formattedAmount {
    if (compact) return amount.toCurrencyString(currency: currency, compact: true);
    return amount.toCurrencyString(currency: currency);
  }
}
