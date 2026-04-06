import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/currency_extension.dart';

class QuickStatsRow extends StatelessWidget {
  final double mrr;
  final int activeClients;
  final int upcomingRenewals;
  final String currency;

  const QuickStatsRow({
    super.key,
    required this.mrr,
    required this.activeClients,
    this.upcomingRenewals = 0,
    this.currency = 'USD',
  });

  @override
  Widget build(BuildContext context) {
    final arr = mrr * 12;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                label: 'MRR',
                value: mrr.toCurrencyString(currency: currency, compact: true),
                color: AppColors.income,
                icon: '📈',
              ),
            ),
            _Divider(),
            Expanded(
              child: _StatItem(
                label: 'ARR',
                value: arr.toCurrencyString(currency: currency, compact: true),
                color: AppColors.primary,
                icon: '📊',
              ),
            ),
            _Divider(),
            Expanded(
              child: _StatItem(
                label: 'Clients',
                value: activeClients.toString(),
                color: AppColors.secondary,
                icon: '👥',
              ),
            ),
            _Divider(),
            Expanded(
              child: _StatItem(
                label: 'Renewals',
                value: upcomingRenewals.toString(),
                color: upcomingRenewals > 0 ? AppColors.pending : AppColors.textSecondary,
                icon: '🔔',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).dividerColor,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(130),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
