import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/node.dart';

class NodeRepository {
  final SupabaseClient _client;

  NodeRepository(this._client);

  String get _userId => _client.auth.currentUser!.id;

  Stream<List<Node>> watchNodes() {
    return _client
        .from('nodes')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('sort_order')
        .map((data) => data.map(Node.fromJson).toList());
  }

  Future<List<Node>> getNodes({bool includeArchived = false}) async {
    dynamic query = _client
        .from('nodes')
        .select()
        .eq('user_id', _userId);
    if (!includeArchived) {
      query = query.eq('is_archived', false);
    }
    final data = await (query as dynamic).order('sort_order');
    return (data as List).map((e) => Node.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Node?> getNode(String id) async {
    final data = await _client
        .from('nodes')
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .maybeSingle();
    return data != null ? Node.fromJson(data) : null;
  }

  Future<List<Node>> getChildren(String parentId) async {
    final data = await _client
        .from('nodes')
        .select()
        .eq('parent_id', parentId)
        .eq('user_id', _userId)
        .eq('is_archived', false)
        .order('sort_order');
    return data.map(Node.fromJson).toList();
  }

  Future<Node> createNode(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    data['updated_at'] = DateTime.now().toIso8601String();
    final result = await _client
        .from('nodes')
        .insert(data)
        .select()
        .single();
    return Node.fromJson(result);
  }

  Future<Node> updateNode(String id, Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    final result = await _client
        .from('nodes')
        .update(data)
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();
    return Node.fromJson(result);
  }

  Future<void> archiveNode(String id) async {
    await _client
        .from('nodes')
        .update({'is_archived': true, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .eq('user_id', _userId);
  }

  Future<void> reorderNodes(List<String> ids) async {
    for (int i = 0; i < ids.length; i++) {
      await _client
          .from('nodes')
          .update({'sort_order': i})
          .eq('id', ids[i])
          .eq('user_id', _userId);
    }
  }

  Future<List<Node>> getUpcomingRenewals({int days = 30}) async {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    final data = await _client
        .from('nodes')
        .select()
        .eq('user_id', _userId)
        .eq('status', 'active')
        .eq('is_archived', false)
        .gte('renewal_date', now.toIso8601String().substring(0, 10))
        .lte('renewal_date', future.toIso8601String().substring(0, 10))
        .order('renewal_date');
    return data.map(Node.fromJson).toList();
  }

  List<Node> buildTree(List<Node> flatNodes) {
    final map = <String, Node>{};
    for (final node in flatNodes) {
      map[node.id] = Node(
        id: node.id,
        userId: node.userId,
        parentId: node.parentId,
        clientId: node.clientId,
        name: node.name,
        nodeType: node.nodeType,
        icon: node.icon,
        color: node.color,
        sortOrder: node.sortOrder,
        amount: node.amount,
        currency: node.currency,
        billingCycle: node.billingCycle,
        startDate: node.startDate,
        renewalDate: node.renewalDate,
        endDate: node.endDate,
        status: node.status,
        notes: node.notes,
        tags: node.tags,
        isArchived: node.isArchived,
        depth: node.depth,
        createdAt: node.createdAt,
        updatedAt: node.updatedAt,
        children: [],
      );
    }

    final roots = <Node>[];
    for (final node in map.values) {
      if (node.parentId == null) {
        roots.add(node);
      } else {
        map[node.parentId]?.children.add(node);
      }
    }

    for (final node in map.values) {
      node.children.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      node.aggregatedAmount = _computeTotal(node);
    }

    roots.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return roots;
  }

  double _computeTotal(Node node) {
    if (node.children.isEmpty) return node.amount ?? 0;
    return node.children.fold(0, (sum, child) => sum + _computeTotal(child));
  }
}
