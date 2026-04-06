import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/node_provider.dart';
import '../../data/models/transaction.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/currency_extension.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/client_avatar.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txns = ref.watch(transactionsByPeriodProvider('year'));
    final clients = ref.watch(clientsProvider);
    final mrr = ref.watch(mrrProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: txns.when(
        data: (transactions) {
          final income = transactions.where((t) => t.type == 'income').toList();
          final expenses = transactions.where((t) => t.type == 'expense').toList();
          final donations = transactions.where((t) => t.type == 'donation').toList();

          final totalIncome = income.fold(0.0, (s, t) => s + t.amount);
          final totalExpenses = expenses.fold(0.0, (s, t) => s + t.amount);
          final totalDonations = donations.fold(0.0, (s, t) => s + t.amount);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(transactionsByPeriodProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Annual Overview
                _SectionTitle('Annual Overview (This Year)'),
                Row(
                  children: [
                    _KPICard(label: 'Income', value: totalIncome.toCurrencyString(compact: true), color: AppColors.income),
                    const SizedBox(width: 10),
                    _KPICard(label: 'Expenses', value: totalExpenses.toCurrencyString(compact: true), color: AppColors.expense),
                    const SizedBox(width: 10),
                    _KPICard(label: 'Net', value: (totalIncome - totalExpenses).toCurrencyString(compact: true),
                        color: totalIncome >= totalExpenses ? AppColors.income : AppColors.expense),
                  ],
                ),
                const SizedBox(height: 16),

                // MRR
                mrr.when(
                  data: (m) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text('📈', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Monthly Recurring Revenue',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withAlpha(150),
                                  )),
                              Text(
                                m.toCurrencyString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.income,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Text(
                                'ARR: ${(m * 12).toCurrencyString()}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  loading: () => const CardSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // Income by Client (donut)
                if (income.isNotEmpty) ...[
                  _SectionTitle('Income by Client'),
                  _IncomeByClientChart(transactions: income),
                  const SizedBox(height: 16),
                ],

                // Expense Breakdown
                if (expenses.isNotEmpty) ...[
                  _SectionTitle('Expense Breakdown'),
                  _ExpenseBreakdownChart(transactions: expenses),
                  const SizedBox(height: 16),
                ],

                // Top Clients
                clients.when(
                  data: (clientList) {
                    if (clientList.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle('Top Clients by Revenue'),
                        ..._topClients(clientList, income)
                            .take(5)
                            .map((entry) => _TopClientTile(
                              displayName: entry.key,
                              amount: entry.value,
                              color: '#6366F1',
                            )),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Donations
                if (donations.isNotEmpty) ...[
                  _SectionTitle('Donations Summary'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Donations'),
                              Text(
                                totalDonations.toCurrencyString(),
                                style: TextStyle(
                                  color: AppColors.donation,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Transactions'),
                              Text('${donations.length}',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('🔌', style: TextStyle(fontSize: 48)),
                SizedBox(height: 12),
                Text('Connect Supabase to view reports.', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<MapEntry<String, double>> _topClients(
      List clients, List<Transaction> income) {
    final map = <String, double>{};
    for (final t in income) {
      final name = t.clientName ?? t.clientId ?? 'Unknown';
      map[name] = (map[name] ?? 0) + t.amount;
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KPICard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomeByClientChart extends StatefulWidget {
  final List<Transaction> transactions;

  const _IncomeByClientChart({required this.transactions});

  @override
  State<_IncomeByClientChart> createState() => _IncomeByClientChartState();
}

class _IncomeByClientChartState extends State<_IncomeByClientChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final data = <String, double>{};
    for (final t in widget.transactions) {
      final key = t.clientName ?? 'Other';
      data[key] = (data[key] ?? 0) + t.amount;
    }

    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      AppColors.primary, AppColors.income, AppColors.secondary,
      AppColors.donation, AppColors.pending, const Color(0xFF0EA5E9),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              height: 160,
              width: 160,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (_, r) => setState(() {
                      _touched = r?.touchedSection?.touchedSectionIndex ?? -1;
                    }),
                  ),
                  sections: List.generate(entries.length, (i) {
                    final isTouched = i == _touched;
                    final total = entries.fold(0.0, (s, e) => s + e.value);
                    return PieChartSectionData(
                      value: entries[i].value,
                      color: colors[i % colors.length],
                      title: '${(entries[i].value / total * 100).toStringAsFixed(0)}%',
                      radius: isTouched ? 70 : 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    );
                  }),
                  sectionsSpace: 2,
                  centerSpaceRadius: 32,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(entries.take(5).length, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entries[i].key,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        entries[i].value.toCurrencyString(compact: true),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseBreakdownChart extends StatelessWidget {
  final List<Transaction> transactions;

  const _ExpenseBreakdownChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final data = <String, double>{};
    for (final t in transactions) {
      final key = t.category ?? t.paymentMethod;
      data[key] = (data[key] ?? 0) + t.amount;
    }

    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: entries.take(8).map((e) {
            final total = entries.fold(0.0, (s, x) => s + x.value);
            final pct = e.value / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(fontSize: 13)),
                      Text(
                        e.value.toCurrencyString(compact: true),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppColors.expense.withAlpha(20),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.expense),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TopClientTile extends StatelessWidget {
  final String displayName;
  final double amount;
  final String color;

  const _TopClientTile({
    required this.displayName,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        leading: ClientAvatar(initials: initials, color: color, size: 36),
        title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          amount.toCurrencyString(),
          style: TextStyle(
            color: AppColors.income,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
