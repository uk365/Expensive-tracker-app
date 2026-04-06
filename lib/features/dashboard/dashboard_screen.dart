import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/node_provider.dart';
import '../../providers/client_provider.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/loading_skeleton.dart';
import 'widgets/net_balance_card.dart';
import 'widgets/income_expense_summary.dart';
import 'widgets/mrr_badge.dart';
import 'widgets/income_expense_chart.dart';
import 'widgets/recent_transactions_list.dart';
import 'widgets/renewal_alerts.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _period = 'Month';

  String get _periodKey => _period.toLowerCase();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileStreamProvider);
    final summary = ref.watch(dashboardSummaryProvider(_periodKey));
    final recentTxns = ref.watch(recentTransactionsProvider);
    final renewals = ref.watch(upcomingRenewalsProvider);
    final mrr = ref.watch(mrrProvider);
    final activeClients = ref.watch(activeClientCountProvider);

    final greeting = _greeting;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardSummaryProvider);
            ref.invalidate(recentTransactionsProvider);
            ref.invalidate(upcomingRenewalsProvider);
            ref.invalidate(mrrProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: theme.colorScheme.surface,
                elevation: 0,
                title: profile.when(
                  data: (p) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, ${p?.fullName.split(' ').first ?? 'there'} 👋',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (p?.businessName != null)
                        Text(
                          p!.businessName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                    ],
                  ),
                  loading: () => const SizedBox(height: 40, width: 180, child: LoadingSkeleton()),
                  error: (_, __) => const Text('Finance Tracker'),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => context.go('/transactions/add'),
                    tooltip: 'Add Transaction',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.go('/settings'),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Net Balance Card
                    summary.when(
                      data: (data) => NetBalanceCard(
                        income: data['income'] ?? 0,
                        expenses: data['expenses'] ?? 0,
                        donations: data['donations'] ?? 0,
                        currency: profile.value?.currency ?? 'USD',
                        period: _period,
                        onPeriodChanged: (p) => setState(() => _period = p),
                      ),
                      loading: () => const CardSkeleton(),
                      error: (e, _) => _ErrorCard(error: e.toString()),
                    ),
                    const SizedBox(height: 12),

                    // Income / Expense Summary
                    summary.when(
                      data: (data) => IncomeExpenseSummaryRow(
                        income: data['income'] ?? 0,
                        expenses: data['expenses'] ?? 0,
                        currency: profile.value?.currency ?? 'USD',
                      ),
                      loading: () => Row(
                        children: const [
                          Expanded(child: CardSkeleton()),
                          SizedBox(width: 12),
                          Expanded(child: CardSkeleton()),
                        ],
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 12),

                    // Quick Stats
                    mrr.when(
                      data: (m) => activeClients.when(
                        data: (count) => renewals.when(
                          data: (r) => QuickStatsRow(
                            mrr: m,
                            activeClients: count,
                            upcomingRenewals: r.length,
                            currency: profile.value?.currency ?? 'USD',
                          ),
                          loading: () => const CardSkeleton(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        loading: () => const CardSkeleton(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      loading: () => const CardSkeleton(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 12),

                    // Bar Chart
                    IncomeExpenseBarChart(monthlyData: const {}),
                    const SizedBox(height: 12),

                    // Upcoming Renewals
                    renewals.when(
                      data: (r) => r.isEmpty
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RenewalAlertsWidget(renewals: r),
                                const SizedBox(height: 12),
                              ],
                            ),
                      loading: () => const CardSkeleton(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    // Recent Transactions
                    SectionHeader(
                      title: 'Recent Transactions',
                      actionLabel: 'See all',
                      onAction: () => context.go('/transactions'),
                    ),
                    const SizedBox(height: 8),
                    recentTxns.when(
                      data: (txns) => RecentTransactionsList(transactions: txns),
                      loading: () => const ListSkeleton(count: 4),
                      error: (e, _) => _ErrorCard(error: e.toString()),
                    ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/transactions/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.contains('supabase') || error.contains('Supabase')
                    ? 'Connect Supabase to load data. See setup instructions.'
                    : error,
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
