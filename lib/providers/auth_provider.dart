import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/profile.dart';
import 'supabase_provider.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseAuthProvider).onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(supabaseClientProvider).auth.currentUser;
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final client = ref.watch(supabaseClientProvider);
  try {
    final data = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    return Profile.fromJson(data);
  } catch (_) {
    return null;
  }
});

final profileStreamProvider = StreamProvider<Profile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  final client = ref.watch(supabaseClientProvider);
  return client
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', user.id)
      .map((data) => data.isEmpty ? null : Profile.fromJson(data.first));
});
