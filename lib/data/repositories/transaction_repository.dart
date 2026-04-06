import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final SupabaseClient _client;

  TransactionRepository(this._client);

  String get _userId => _client.auth.currentUser!.id;

  Stream<List<Transaction>> watchTransactions({int limit = 50}) {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('transaction_date', ascending: false)
        .limit(limit)
        .map((data) => data.map(Transaction.fromJson).toList());
  }

  Future<List<Transaction>> getTransactions({
    DateTime? from,
    DateTime? to,
    String? type,
    String? clientId,
    String? status,
    String? paymentMethod,
    int limit = 100,
  }) async {
    var query = _client
        .from('transactions')
        .select()
        .eq('user_id', _userId);

    if (from != null) {
      query = query.gte(
          'transaction_date', from.toIso8601String().substring(0, 10));
    }
    if (to != null) {
      query = query.lte(
          'transaction_date', to.toIso8601String().substring(0, 10));
    }
    if (type != null) query = query.eq('type', type);
    if (clientId != null) query = query.eq('client_id', clientId);
    if (status != null) query = query.eq('status', status);
    if (paymentMethod != null) {
      query = query.eq('payment_method', paymentMethod);
    }

    final data = await query
        .order('transaction_date', ascending: false)
        .limit(limit);
    return data.map(Transaction.fromJson).toList();
  }

  Future<Transaction?> getTransaction(String id) async {
    final data = await _client
        .from('transactions')
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .maybeSingle();
    return data != null ? Transaction.fromJson(data) : null;
  }

  Future<String> recordIncome({
    required String nodeId,
    required String? clientId,
    required double amount,
    required String currency,
    required String description,
    required DateTime date,
    required String paymentMethod,
    String? referenceNo,
    String? notes,
  }) async {
    try {
      final result = await _client.rpc('record_income', params: {
        'p_user_id': _userId,
        'p_node_id': nodeId,
        'p_client_id': clientId,
        'p_amount': amount,
        'p_currency': currency,
        'p_description': description,
        'p_date': date.toIso8601String().substring(0, 10),
        'p_payment_method': paymentMethod,
      });
      return result as String;
    } catch (e) {
      // Fallback: direct insert if RPC not set up
      final result = await _client
          .from('transactions')
          .insert({
            'user_id': _userId,
            'node_id': nodeId,
            'client_id': clientId,
            'type': 'income',
            'amount': amount,
            'currency': currency,
            'description': description,
            'transaction_date': date.toIso8601String().substring(0, 10),
            'payment_method': paymentMethod,
            'reference_no': referenceNo,
            'notes': notes,
            'status': 'completed',
          })
          .select('id')
          .single();
      return result['id'] as String;
    }
  }

  Future<String> addTransaction(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    data['updated_at'] = DateTime.now().toIso8601String();
    final result = await _client
        .from('transactions')
        .insert(data)
        .select('id')
        .single();
    return result['id'] as String;
  }

  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    await _client
        .from('transactions')
        .update(data)
        .eq('id', id)
        .eq('user_id', _userId);
  }

  Future<void> archiveTransaction(String id) async {
    await _client
        .from('transactions')
        .update({'status': 'cancelled', 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .eq('user_id', _userId);
  }

  Future<Map<String, double>> getSummary({
    DateTime? from,
    DateTime? to,
  }) async {
    final transactions = await getTransactions(from: from, to: to);
    double income = 0;
    double expenses = 0;
    double donations = 0;

    for (final t in transactions) {
      if (t.type == 'income') income += t.amount;
      if (t.type == 'expense') expenses += t.amount;
      if (t.type == 'donation') donations += t.amount;
    }
    return {
      'income': income,
      'expenses': expenses,
      'donations': donations,
      'net': income + donations - expenses,
    };
  }

  Future<List<Transaction>> getRecentTransactions({int limit = 5}) async {
    final data = await _client
        .from('transactions')
        .select()
        .eq('user_id', _userId)
        .order('transaction_date', ascending: false)
        .limit(limit);
    return data.map(Transaction.fromJson).toList();
  }
}
