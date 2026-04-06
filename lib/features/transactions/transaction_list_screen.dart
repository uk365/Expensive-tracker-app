import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/transaction.dart';
import '../../shared/widgets/amount_text.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/currency_extension.dart';
import '../../core/extensions/date_extension.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['Day', 'Week', 'Month', 'Year'];
  String? _typeFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final period = _tabs[_tabController.index].toLowerCase();
    final summary = ref.watch(dashboardSummaryProvider(period));
    final txns = ref.watch(transactionsByPeriodProvider(period));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/transactions/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary bar
          summary.when(
            data: (data) => _SummaryBar(
              income: data['income'] ?? 0,
              expenses: data['expenses'] ?? 0,
              net: data['net'] ?? 0,
            ),
            loading: () => const SizedBox(height: 80, child: CardSkeleton()),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Type filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                null, 'income', 'expense', 'donation', 'transfer',
              ].map((type) {
                final label = type == null ? 'All' : type[0].toUpperCase() + type.substring(1);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: _typeFilter == type,
                    onSelected: (_) =>
                        setState(() => _typeFilter = _typeFilter == type ? null : type),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: txns.when(
              data: (list) {
                var filtered = _typeFilter != null
                    ? list.where((t) => t.type == _typeFilter).toList()
                    : list;

                if (filtered.isEmpty) {
                  return EmptyState(
                    emoji: '💳',
                    title: 'No transactions',
                    subtitle: 'Add your first transaction to get started',
                    actionLabel: 'Add Transaction',
                    onAction: () => context.go('/transactions/add'),
                  );
                }

                // Group by date
                final grouped = <String, List<Transaction>>{};
                for (final t in filtered) {
                  final key = t.transactionDate.formatDate(pattern: 'MMMM d, yyyy');
                  grouped.putIfAbsent(key, () => []).add(t);
                }

                final keys = grouped.keys.toList();
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: keys.length,
                  itemBuilder: (_, i) {
                    final group = grouped[keys[i]]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            keys[i],
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ...group.map((t) => _TransactionTile(transaction: t)),
                      ],
                    );
                  },
                );
              },
              loading: () => const ListSkeleton(),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔌', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      Text('Connect Supabase to load transactions.',
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/transactions/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final double income;
  final double expenses;
  final double net;

  const _SummaryBar({
    required this.income,
    required this.expenses,
    required this.net,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(60),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
                label: 'Income', amount: income, color: AppColors.income),
          ),
          Expanded(
            child: _SummaryItem(
                label: 'Expenses', amount: expenses, color: AppColors.expense),
          ),
          Expanded(
            child: _SummaryItem(
              label: 'Net',
              amount: net,
              color: net >= 0 ? AppColors.income : AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          amount.toCurrencyString(compact: true),
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.transactionTypeColor(transaction.type);
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: () => context.go('/transactions/${transaction.id}'),
        dense: true,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_icon, color: color, size: 16),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            if (transaction.clientName != null) transaction.clientName,
            transaction.paymentMethod.replaceAll('_', ' '),
          ].join(' • '),
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            StatusBadge(status: transaction.status, small: true),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    switch (transaction.type) {
      case 'income':
        return Icons.arrow_downward;
      case 'expense':
        return Icons.arrow_upward;
      case 'donation':
        return Icons.volunteer_activism;
      default:
        return Icons.swap_horiz;
    }
  }
}
