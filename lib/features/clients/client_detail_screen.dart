import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/client_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/client.dart';
import '../../shared/widgets/client_avatar.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/amount_text.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/currency_extension.dart';
import '../../core/extensions/date_extension.dart';

class ClientDetailScreen extends ConsumerWidget {
  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = ref.watch(clientDetailProvider(clientId));

    return clientAsync.when(
      data: (client) {
        if (client == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Client not found')),
          );
        }
        return _ClientDetailBody(client: client);
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

class _ClientDetailBody extends ConsumerWidget {
  final Client client;

  const _ClientDetailBody({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.go('/clients/${client.id}/edit'),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _parseColor(client.avatarColor).withAlpha(40),
                        theme.colorScheme.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          ClientAvatar(
                            initials: client.initials,
                            color: client.avatarColor,
                            size: 64,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.displayName,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (client.businessName != null)
                                  Text(
                                    client.businessName!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withAlpha(150),
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    StatusBadge(status: client.status),
                                    const SizedBox(width: 8),
                                    TierBadge(tier: client.tier),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Transactions'),
                  Tab(text: 'Notes'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _OverviewTab(client: client),
              _TransactionsTab(clientId: client.id),
              _NotesTab(client: client),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _OverviewTab extends StatelessWidget {
  final Client client;

  const _OverviewTab({required this.client});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Contact
        if (client.email != null || client.phone != null || client.website != null)
          _Section(
            title: 'Contact',
            children: [
              if (client.email != null)
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: client.email!,
                  onTap: () => launchUrl(Uri.parse('mailto:${client.email}')),
                ),
              if (client.phone != null)
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: client.phone!,
                  onTap: () => launchUrl(Uri.parse('tel:${client.phone}')),
                ),
              if (client.website != null)
                _InfoRow(
                  icon: Icons.language_outlined,
                  label: 'Website',
                  value: client.website!,
                  onTap: () => launchUrl(Uri.parse(client.website!)),
                ),
            ],
          ),

        // Business Info
        _Section(
          title: 'Business Info',
          children: [
            if (client.industry != null)
              _InfoRow(icon: Icons.business_outlined, label: 'Industry', value: client.industry!),
            if (client.businessType != null)
              _InfoRow(icon: Icons.apartment_outlined, label: 'Type', value: client.businessType!),
            _InfoRow(icon: Icons.payment_outlined, label: 'Payment Terms', value: client.paymentTerms),
            _InfoRow(icon: Icons.currency_exchange_outlined, label: 'Currency', value: client.currency),
            if (client.taxId != null)
              _InfoRow(icon: Icons.receipt_long_outlined, label: 'Tax ID', value: client.taxId!),
            if (client.clientSince != null)
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Client Since',
                value: client.clientSince!.formatDate(),
              ),
          ],
        ),

        // Address
        if (_hasAddress)
          _Section(
            title: 'Address',
            children: [
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: _formattedAddress,
              ),
            ],
          ),

        // Tags
        if (client.tags.isNotEmpty)
          _Section(
            title: 'Tags',
            children: [
              Wrap(
                spacing: 8,
                children: client.tags
                    .map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 12)),
                          padding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            ],
          ),
      ],
    );
  }

  bool get _hasAddress =>
      client.addressLine1 != null ||
      client.city != null ||
      client.country != null;

  String get _formattedAddress {
    final parts = [
      client.addressLine1,
      client.addressLine2,
      client.city,
      client.state,
      client.postalCode,
      client.country,
    ].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(', ');
  }
}

class _TransactionsTab extends ConsumerWidget {
  final String clientId;

  const _TransactionsTab({required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnsAsync = ref.watch(transactionsByPeriodProvider('year'));

    return txnsAsync.when(
      data: (all) {
        final txns = all.where((t) => t.clientId == clientId).toList();
        if (txns.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('💳', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 8),
                  Text('No transactions for this client'),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: txns.length,
          itemBuilder: (_, i) {
            final t = txns[i];
            final color = AppColors.transactionTypeColor(t.type);
            return Card(
              child: ListTile(
                leading: Icon(
                  t.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: color,
                ),
                title: Text(t.description),
                subtitle: Text(t.transactionDate.formatDate()),
                trailing: AmountText(
                  amount: t.amount,
                  currency: t.currency,
                  type: t.type,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text('Could not load transactions')),
    );
  }
}

class _NotesTab extends StatelessWidget {
  final Client client;

  const _NotesTab({required this.client});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: client.notes?.isNotEmpty == true
          ? Text(client.notes!)
          : const Center(
              child: Text('No notes for this client.',
                  style: TextStyle(color: Colors.grey)),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: theme.colorScheme.onSurface.withAlpha(120)),
            const SizedBox(width: 10),
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: onTap != null ? theme.colorScheme.primary : null,
                  decoration:
                      onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
