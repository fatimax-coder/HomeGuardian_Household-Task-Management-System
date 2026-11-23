import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_constants.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

/// Result wrapper for registration attempts
class SignUpResult {
  final UserProfile? profile;
  final bool requiresEmailConfirmation;
  final String? message;

  SignUpResult({
    this.profile,
    required this.requiresEmailConfirmation,
    this.message,
  });
}

abstract class IAuthRepository {
  Future<UserProfile?> getCurrentProfile();
  Future<UserProfile> signIn({required String email, required String password});
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> signOut();
  bool get isAuthenticated;
  User? get currentUser;
  Session? get currentSession;
  Stream<AuthState>? get authStateChanges;
}

/// Repository Pattern Implementation for Authentication & Profile management
class AuthRepository implements IAuthRepository {
  final SupabaseService _service;

  AuthRepository([SupabaseService? service])
      : _service = service ?? SupabaseService.instance;

  Future<void> _ensureInitialized() async {
    if (!_service.isInitialized) {
      await _service.initialize(
        url: AppConstants.supabaseUrl,
        publishableKey: AppConstants.supabasePublishableKey,
      );
    }
  }

  @override
  bool get isAuthenticated {
    if (!_service.isInitialized) return false;
    return _service.client.auth.currentSession != null;
  }

  @override
  User? get currentUser {
    if (!_service.isInitialized) return null;
    return _service.client.auth.currentUser;
  }

  @override
  Session? get currentSession {
    if (!_service.isInitialized) return null;
    return _service.client.auth.currentSession;
  }

  @override
  Stream<AuthState>? get authStateChanges {
    if (!_service.isInitialized) return null;
    return _service.client.auth.onAuthStateChange;
  }

  @override
  Future<UserProfile?> getCurrentProfile() async {
    await _ensureInitialized();
    if (!isAuthenticated) return null;
    final user = _service.client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _service.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        return UserProfile.fromJson(response);
      }

      // Fallback if trigger was delayed or profile row not yet read
      final metadataName = user.userMetadata?['full_name'] as String? ?? 'Member';
      return UserProfile(
        id: user.id,
        email: user.email ?? '',
        fullName: metadataName,
        createdAt: DateTime.now(),
      );
    } catch (_) {
      // In case of network retry or policy delay, return user metadata
      return UserProfile(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String? ?? 'Member',
      );
    }
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    await _ensureInitialized();
    if (!_service.isInitialized) {
      throw const AuthException(
        'Supabase connection is not initialized. Please verify your credentials and network.',
      );
    }
    try {
      final response = await _service.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Invalid login credentials. Please try again.');
      }

      final profile = await getCurrentProfile();
      return profile ??
          UserProfile(
            id: user.id,
            email: user.email ?? email,
            fullName: user.userMetadata?['full_name'] as String? ?? 'Member',
          );
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _ensureInitialized();
    if (!_service.isInitialized) {
      throw const AuthException(
        'Supabase connection is not initialized. Please verify your credentials and network.',
      );
    }
    try {
      final response = await _service.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Registration failed. Please try again.');
      }

      // If session is null, Supabase requires email confirmation before login
      if (response.session == null) {
        return SignUpResult(
          profile: UserProfile(
            id: user.id,
            email: user.email ?? email,
            fullName: fullName.trim(),
            createdAt: DateTime.now(),
          ),
          requiresEmailConfirmation: true,
          message: 'Account created! Please check your email to confirm your account before logging in.',
        );
      }

      // Active session: Fetch database trigger created profile
      final profile = await getCurrentProfile();
      return SignUpResult(
        profile: profile ??
            UserProfile(
              id: user.id,
              email: user.email ?? email,
              fullName: fullName.trim(),
              createdAt: DateTime.now(),
            ),
        requiresEmailConfirmation: false,
        message: 'Registration successful! Welcome to HomeGuardian.',
      );
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    if (isAuthenticated) {
      try {
        await _service.client.auth.signOut();
      } catch (_) {
        // Fallback cleanup
      }
    }
  }
}
