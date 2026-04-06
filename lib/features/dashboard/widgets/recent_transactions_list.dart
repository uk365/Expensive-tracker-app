import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/transaction.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/extensions/date_extension.dart';
import '../../../shared/widgets/status_badge.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;

  const RecentTransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                const Text('💳', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  'No transactions yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(150),
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: transactions
            .map((t) => _TransactionTile(transaction: t))
            .toList(),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.transactionTypeColor(transaction.type);

    return InkWell(
      onTap: () => context.go('/transactions/${transaction.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconForType, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.clientName ?? transaction.transactionDate.formatShort(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isExpense ? '-' : '+'}${transaction.amount.toCurrencyString(currency: transaction.currency)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                StatusBadge(status: transaction.status, small: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData get _iconForType {
    switch (transaction.type) {
      case 'income':
        return Icons.arrow_downward_rounded;
      case 'expense':
        return Icons.arrow_upward_rounded;
      case 'donation':
        return Icons.volunteer_activism;
      default:
        return Icons.swap_horiz;
    }
  }
}
