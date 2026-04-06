import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/amount_text.dart';

class IncomeExpenseSummaryRow extends StatelessWidget {
  final double income;
  final double expenses;
  final String currency;

  const IncomeExpenseSummaryRow({
    super.key,
    required this.income,
    required this.expenses,
    this.currency = 'USD',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Income',
            amount: income,
            currency: currency,
            color: AppColors.income,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Expenses',
            amount: expenses,
            currency: currency,
            color: AppColors.expense,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withAlpha(170),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AmountText(
              amount: amount,
              currency: currency,
              type: label == 'Income' ? 'income' : 'expense',
              size: AmountSize.large,
            ),
          ],
        ),
      ),
    );
  }
}
