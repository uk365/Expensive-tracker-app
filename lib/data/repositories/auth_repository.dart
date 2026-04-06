import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? businessName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'business_name': businessName,
      },
    );
    
    // Note: Profile creation is now handled automatically on the database
    // side via a Postgres Trigger on auth.users.
    
    return response;
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> updateProfile(Profile profile) async {
    await _client.from('profiles').update(profile.toJson()).eq('id', profile.id);
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
