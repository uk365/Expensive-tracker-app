import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/currency_extension.dart';

class NetBalanceCard extends StatelessWidget {
  final double income;
  final double expenses;
  final double donations;
  final String currency;
  final String period;
  final Function(String) onPeriodChanged;

  const NetBalanceCard({
    super.key,
    required this.income,
    required this.expenses,
    required this.donations,
    this.currency = 'USD',
    required this.period,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final net = income + donations - expenses;
    final isPositive = net >= 0;
    final netColor = isPositive ? AppColors.income : AppColors.expense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Balance',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                _PeriodChip(current: period, onChanged: onPeriodChanged),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              net.toCurrencyString(currency: currency),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: netColor,
              ),
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: income + donations > 0
                    ? expenses / (income + donations)
                    : 0,
                backgroundColor: AppColors.income.withAlpha(40),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.expense),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _LegendDot(color: AppColors.income, label: 'Income'),
                const SizedBox(width: 16),
                _LegendDot(color: AppColors.expense, label: 'Expenses'),
                if (donations > 0) ...[
                  const SizedBox(width: 16),
                  _LegendDot(color: AppColors.donation, label: 'Donations'),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String current;
  final Function(String) onChanged;

  const _PeriodChip({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const periods = ['Day', 'Week', 'Month', 'Year'];
    return PopupMenuButton<String>(
      initialValue: current,
      onSelected: onChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.outline.withAlpha(80)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 14),
          ],
        ),
      ),
      itemBuilder: (_) => periods
          .map((p) => PopupMenuItem(value: p, child: Text(p)))
          .toList(),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
          ),
        ),
      ],
    );
  }
}
