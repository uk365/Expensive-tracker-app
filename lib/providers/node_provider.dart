import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/node.dart';
import '../data/repositories/node_repository.dart';
import 'supabase_provider.dart';

final nodeRepositoryProvider = Provider<NodeRepository>((ref) {
  return NodeRepository(ref.watch(supabaseClientProvider));
});

final nodesStreamProvider = StreamProvider<List<Node>>((ref) {
  return ref.watch(nodeRepositoryProvider).watchNodes();
});

final nodesProvider = FutureProvider<List<Node>>((ref) {
  return ref.watch(nodeRepositoryProvider).getNodes();
});

final worktreeProvider = FutureProvider<List<Node>>((ref) async {
  final nodes = await ref.watch(nodeRepositoryProvider).getNodes();
  return ref.watch(nodeRepositoryProvider).buildTree(nodes);
});

final upcomingRenewalsProvider = FutureProvider<List<Node>>((ref) {
  return ref.watch(nodeRepositoryProvider).getUpcomingRenewals(days: 30);
});

final mrrProvider = FutureProvider<double>((ref) async {
  final nodes = await ref.watch(nodesProvider.future);
  final activeNodes = nodes.where((n) => n.status == 'active' && n.amount != null).toList();
  double mrr = 0;
  for (final node in activeNodes) {
    final amount = node.amount ?? 0;
    switch (node.billingCycle) {
      case 'monthly':
        mrr += amount;
        break;
      case 'yearly':
        mrr += amount / 12;
        break;
      case 'quarterly':
        mrr += amount / 3;
        break;
      case 'weekly':
        mrr += amount * 4.33;
        break;
      case 'daily':
        mrr += amount * 30;
        break;
    }
  }
  return mrr;
});
