import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_provider.dart';
import '../../shared/widgets/amount_text.dart';
import '../../shared/widgets/status_badge.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/date_extension.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnAsync = ref.watch(transactionDetailProvider(transactionId));

    return txnAsync.when(
      data: (t) {
        if (t == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Transaction not found')),
          );
        }

        final color = AppColors.transactionTypeColor(t.type);
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Transaction Details'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          t.isIncome
                              ? Icons.arrow_downward
                              : t.isExpense
                                  ? Icons.arrow_upward
                                  : Icons.volunteer_activism,
                          color: color,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AmountText(
                        amount: t.amount,
                        currency: t.currency,
                        type: t.type,
                        size: AmountSize.display,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.description,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      StatusBadge(status: t.status),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _Row(label: 'Type', value: t.type[0].toUpperCase() + t.type.substring(1)),
                      _Row(label: 'Date', value: t.transactionDate.formatDate()),
                      _Row(label: 'Payment Method', value: t.paymentMethod.replaceAll('_', ' ')),
                      if (t.clientName != null)
                        _Row(label: 'Client', value: t.clientName!),
                      if (t.referenceNo != null)
                        _Row(label: 'Reference', value: t.referenceNo!),
                      if (t.category != null)
                        _Row(label: 'Category', value: t.category!),
                      if (t.dueDate != null)
                        _Row(label: 'Due Date', value: t.dueDate!.formatDate()),
                      if (t.paidDate != null)
                        _Row(label: 'Paid Date', value: t.paidDate!.formatDate()),
                      if (t.isTaxable) ...[
                        _Row(label: 'Tax Rate', value: '${t.taxRate}%'),
                        _Row(label: 'Tax Amount', value: '\$${t.taxAmount}'),
                      ],
                    ],
                  ),
                ),
              ),

              if (t.notes != null && t.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(t.notes!),
                      ],
                    ),
                  ),
                ),
              ],

              if (t.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      children: t.tags
                          .map((tag) => Chip(
                                label: Text(tag, style: const TextStyle(fontSize: 12)),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
