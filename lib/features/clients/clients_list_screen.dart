import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/client_provider.dart';
import '../../data/models/client.dart';
import '../../shared/widgets/client_avatar.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../core/constants/app_colors.dart';

class ClientsListScreen extends ConsumerStatefulWidget {
  const ClientsListScreen({super.key});

  @override
  ConsumerState<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends ConsumerState<ClientsListScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String? _statusFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/clients/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                null, 'active', 'inactive', 'lead', 'churned',
              ].map((status) {
                final label = status == null ? 'All' : status[0].toUpperCase() + status.substring(1);
                final selected = _statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _statusFilter = selected ? null : status),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: clients.when(
              data: (list) {
                var filtered = list.where((c) {
                  if (_statusFilter != null && c.status != _statusFilter) return false;
                  if (_search.isNotEmpty) {
                    return c.displayName.toLowerCase().contains(_search) ||
                        (c.email?.toLowerCase().contains(_search) ?? false) ||
                        (c.businessName?.toLowerCase().contains(_search) ?? false);
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    emoji: '👥',
                    title: _search.isNotEmpty ? 'No results' : 'No clients yet',
                    subtitle: _search.isNotEmpty
                        ? 'Try a different search'
                        : 'Add your first client to get started',
                    actionLabel: _search.isEmpty ? 'Add Client' : null,
                    onAction: () => context.go('/clients/add'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (_, i) => _ClientTile(client: filtered[i]),
                );
              },
              loading: () => const ListSkeleton(),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔌', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        'Connect Supabase to load clients.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/clients/add'),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Client'),
      ),
    );
  }
}

class _ClientTile extends StatelessWidget {
  final Client client;

  const _ClientTile({required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.go('/clients/${client.id}'),
        leading: ClientAvatar(
          initials: client.initials,
          color: client.avatarColor,
        ),
        title: Text(
          client.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          client.businessName ?? client.email ?? client.industry ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StatusBadge(status: client.status, small: true),
            const SizedBox(height: 4),
            TierBadge(tier: client.tier),
          ],
        ),
      ),
    );
  }
}
