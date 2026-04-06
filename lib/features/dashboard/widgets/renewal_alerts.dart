import 'package:flutter/material.dart';
import '../../../data/models/node.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/extensions/date_extension.dart';

class RenewalAlertsWidget extends StatelessWidget {
  final List<Node> renewals;

  const RenewalAlertsWidget({super.key, required this.renewals});

  @override
  Widget build(BuildContext context) {
    if (renewals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🔔', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'Upcoming Renewals',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.pending.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${renewals.length}',
                    style: TextStyle(
                      color: AppColors.pending,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...renewals.take(5).map((node) => _RenewalItem(node: node)),
          ],
        ),
      ),
    );
  }
}

class _RenewalItem extends StatelessWidget {
  final Node node;

  const _RenewalItem({required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysUntil = node.renewalDate!.daysUntil;
    final isUrgent = daysUntil <= 3;
    final color = isUrgent ? AppColors.expense : AppColors.pending;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(node.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.name,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Renews ${node.renewalDate!.formatShort()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (node.amount != null)
                Text(
                  node.amount!.toCurrencyString(currency: node.currency),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              Text(
                daysUntil == 0
                    ? 'Today!'
                    : daysUntil == 1
                        ? 'Tomorrow'
                        : 'in $daysUntil days',
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
