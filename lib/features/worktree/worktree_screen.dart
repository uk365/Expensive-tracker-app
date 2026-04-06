import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/node_provider.dart';
import '../../data/models/node.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/currency_extension.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_skeleton.dart';
import 'add_node_sheet.dart';

class WorktreeScreen extends ConsumerStatefulWidget {
  const WorktreeScreen({super.key});

  @override
  ConsumerState<WorktreeScreen> createState() => _WorktreeScreenState();
}

class _WorktreeScreenState extends ConsumerState<WorktreeScreen> {
  final _expanded = <String>{};

  @override
  Widget build(BuildContext context) {
    final worktree = ref.watch(worktreeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worktree'),
        actions: [
          IconButton(
            icon: const Icon(Icons.unfold_more),
            onPressed: () {
              worktree.whenData((nodes) {
                final allIds = _collectAllIds(nodes);
                setState(() => _expanded.addAll(allIds));
              });
            },
            tooltip: 'Expand all',
          ),
          IconButton(
            icon: const Icon(Icons.unfold_less),
            onPressed: () => setState(() => _expanded.clear()),
            tooltip: 'Collapse all',
          ),
        ],
      ),
      body: worktree.when(
        data: (nodes) {
          if (nodes.isEmpty) {
            return EmptyState(
              emoji: '🌳',
              title: 'Empty Worktree',
              subtitle: 'Start by adding your income sources and expenses',
              actionLabel: 'Add Node',
              onAction: () => _showAddSheet(context),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: nodes.length,
            itemBuilder: (_, i) => NodeCard(
              node: nodes[i],
              depth: 0,
              expanded: _expanded,
              onToggle: (id) => setState(() {
                if (_expanded.contains(id)) {
                  _expanded.remove(id);
                } else {
                  _expanded.add(id);
                }
              }),
              onAddChild: (parent) => _showAddSheet(context, parent: parent),
            ),
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
                const SizedBox(height: 16),
                Text(
                  'Connect Supabase to use the Worktree.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'See SUPABASE_SETUP.md for configuration.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Node'),
      ),
    );
  }

  void _showAddSheet(BuildContext context, {Node? parent}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddNodeSheet(parentNode: parent),
    );
  }

  List<String> _collectAllIds(List<Node> nodes) {
    final ids = <String>[];
    for (final node in nodes) {
      if (node.children.isNotEmpty) {
        ids.add(node.id);
        ids.addAll(_collectAllIds(node.children));
      }
    }
    return ids;
  }
}

class NodeCard extends StatelessWidget {
  final Node node;
  final int depth;
  final Set<String> expanded;
  final Function(String) onToggle;
  final Function(Node) onAddChild;

  const NodeCard({
    super.key,
    required this.node,
    required this.depth,
    required this.expanded,
    required this.onToggle,
    required this.onAddChild,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpanded = expanded.contains(node.id);
    final hasChildren = node.children.isNotEmpty;
    final color = AppColors.nodeTypeColor(node.nodeType);
    final displayAmount = node.aggregatedAmount ?? node.amount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: hasChildren ? () => onToggle(node.id) : null,
          onLongPress: () => _showContextMenu(context),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0 + depth * 20.0,
              right: 16,
              top: 4,
              bottom: 4,
            ),
            child: Row(
              children: [
                // Expand arrow
                SizedBox(
                  width: 20,
                  child: hasChildren
                      ? AnimatedRotation(
                          turns: isExpanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                        )
                      : const SizedBox(),
                ),
                const SizedBox(width: 4),
                // Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(node.icon, style: const TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                // Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: depth == 0
                              ? FontWeight.w700
                              : depth == 1
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                        ),
                      ),
                      if (node.billingCycle != null)
                        Text(
                          node.billingCycleLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(130),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                // Amount
                if (displayAmount != null && displayAmount > 0)
                  Text(
                    displayAmount.toCurrencyString(
                        currency: node.currency, compact: true),
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                const SizedBox(width: 8),
                // Add child button
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: () => onAddChild(node),
                    tooltip: 'Add child',
                  ),
                ),
              ],
            ),
          ),
        ),
        // Children
        if (isExpanded && hasChildren)
          ...node.children.map((child) => NodeCard(
                node: child,
                depth: depth + 1,
                expanded: expanded,
                onToggle: onToggle,
                onAddChild: onAddChild,
              )),
      ],
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add_outlined),
              title: const Text('Add child node'),
              onTap: () {
                Navigator.pop(context);
                onAddChild(node);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
