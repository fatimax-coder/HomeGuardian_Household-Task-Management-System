import '../models/user_profile.dart';
import '../services/supabase_service.dart';

abstract class IAuthRepository {
  Future<UserProfile?> getCurrentProfile();
  Future<UserProfile> signIn({required String email, required String password});
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> signOut();
  bool get isAuthenticated;
}

/// Repository Pattern Implementation for Authentication & Profile management
class AuthRepository implements IAuthRepository {
  final SupabaseService _service;

  AuthRepository([SupabaseService? service])
      : _service = service ?? SupabaseService.instance;

  @override
  bool get isAuthenticated {
    if (!_service.isInitialized) return false;
    return _service.client.auth.currentSession != null;
  }

  @override
  Future<UserProfile?> getCurrentProfile() async {
    if (!isAuthenticated) return null;
    final user = _service.client.auth.currentUser;
    if (user == null) return null;

    final response = await _service.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      return UserProfile(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String? ?? 'Member',
      );
    }
    return UserProfile.fromJson(response);
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _service.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception('Authentication failed');

    final profile = await getCurrentProfile();
    return profile ??
        UserProfile(
          id: user.id,
          email: user.email ?? email,
          fullName: 'Member',
        );
  }

  @override
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _service.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    final user = response.user;
    if (user == null) throw Exception('Registration failed');

    return UserProfile(
      id: user.id,
      email: user.email ?? email,
      fullName: fullName,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> signOut() async {
    if (isAuthenticated) {
      await _service.client.auth.signOut();
    }
  }
}
