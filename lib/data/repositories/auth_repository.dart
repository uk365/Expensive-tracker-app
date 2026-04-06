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
    if (response.user != null) {
      await _createProfile(
        userId: response.user!.id,
        email: email,
        fullName: fullName,
        businessName: businessName,
      );
    }
    return response;
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> _createProfile({
    required String userId,
    required String email,
    required String fullName,
    String? businessName,
  }) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'email': email,
      'full_name': fullName,
      'business_name': businessName,
      'currency': 'USD',
      'timezone': 'UTC',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateProfile(Profile profile) async {
    await _client.from('profiles').update(profile.toJson()).eq('id', profile.id);
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
