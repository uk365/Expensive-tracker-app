import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/client.dart';
import '../data/repositories/client_repository.dart';
import 'supabase_provider.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(ref.watch(supabaseClientProvider));
});

final clientsStreamProvider = StreamProvider<List<Client>>((ref) {
  return ref.watch(clientRepositoryProvider).watchClients();
});

final clientsProvider = FutureProvider<List<Client>>((ref) {
  return ref.watch(clientRepositoryProvider).getClients();
});

final clientDetailProvider = FutureProvider.family<Client?, String>((ref, id) {
  return ref.watch(clientRepositoryProvider).getClient(id);
});

final activeClientCountProvider = FutureProvider<int>((ref) {
  return ref.watch(clientRepositoryProvider).getActiveCount();
});
