import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';
import '../data/repositories/transaction_repository.dart';
import '../core/utils/date_helpers.dart';
import 'supabase_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(supabaseClientProvider));
});

final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchTransactions();
});

final recentTransactionsProvider = FutureProvider<List<Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).getRecentTransactions();
});

final transactionsByPeriodProvider =
    FutureProvider.family<List<Transaction>, String>((ref, period) {
  final range = DateHelpers.periodRange(period);
  return ref
      .watch(transactionRepositoryProvider)
      .getTransactions(from: range.start, to: range.end);
});

final dashboardSummaryProvider =
    FutureProvider.family<Map<String, double>, String>((ref, period) {
  final range = DateHelpers.periodRange(period);
  return ref
      .watch(transactionRepositoryProvider)
      .getSummary(from: range.start, to: range.end);
});

final transactionDetailProvider =
    FutureProvider.family<Transaction?, String>((ref, id) {
  return ref.watch(transactionRepositoryProvider).getTransaction(id);
});
