import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client.dart';

class ClientRepository {
  final SupabaseClient _client;

  ClientRepository(this._client);

  String get _userId => _client.auth.currentUser!.id;

  Stream<List<Client>> watchClients({bool includeArchived = false}) {
    var query = _client
        .from('clients')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('display_name');
    return query.map((data) {
      final clients = data.map(Client.fromJson).toList();
      if (!includeArchived) {
        return clients.where((c) => !c.isArchived).toList();
      }
      return clients;
    });
  }

  Future<List<Client>> getClients({bool includeArchived = false}) async {
    dynamic query = _client
        .from('clients')
        .select()
        .eq('user_id', _userId);
    if (!includeArchived) {
      query = query.eq('is_archived', false);
    }
    final data = await (query as dynamic).order('display_name');
    return (data as List).map((e) => Client.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Client?> getClient(String id) async {
    final data = await _client
        .from('clients')
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .maybeSingle();
    return data != null ? Client.fromJson(data) : null;
  }

  Future<Client> createClient(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    data['updated_at'] = DateTime.now().toIso8601String();
    final result = await _client
        .from('clients')
        .insert(data)
        .select()
        .single();
    return Client.fromJson(result);
  }

  Future<Client> updateClient(String id, Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    final result = await _client
        .from('clients')
        .update(data)
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();
    return Client.fromJson(result);
  }

  Future<void> archiveClient(String id) async {
    await _client
        .from('clients')
        .update({'is_archived': true, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .eq('user_id', _userId);
  }

  Future<int> getActiveCount() async {
    final data = await _client
        .from('clients')
        .select('id')
        .eq('user_id', _userId)
        .eq('status', 'active')
        .eq('is_archived', false);
    return data.length;
  }
}
