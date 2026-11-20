import 'package:flutter_test/flutter_test.dart';
import 'package:home_guardian/controllers/auth_controller.dart';
import 'package:home_guardian/models/user_profile.dart';
import 'package:home_guardian/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthRepository implements IAuthRepository {
  UserProfile? _mockProfile;
  bool _authenticated = false;
  bool shouldFail = false;

  @override
  bool get isAuthenticated => _authenticated;

  @override
  User? get currentUser => null;

  @override
  Session? get currentSession => null;

  @override
  Stream<AuthState>? get authStateChanges => null;

  @override
  Future<UserProfile?> getCurrentProfile() async {
    if (shouldFail) throw Exception('Network error');
    return _mockProfile;
  }

  @override
  Future<UserProfile> signIn({required String email, required String password}) async {
    if (shouldFail) throw const AuthException('Invalid login credentials');
    _authenticated = true;
    _mockProfile = UserProfile(id: 'u-123', email: email, fullName: 'Test User');
    return _mockProfile!;
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (shouldFail) throw const AuthException('User already registered');
    _mockProfile = UserProfile(id: 'u-123', email: email, fullName: fullName);
    return SignUpResult(
      profile: _mockProfile,
      requiresEmailConfirmation: true,
      message: 'Account created! Please check your email.',
    );
  }

  @override
  Future<void> signOut() async {
    _authenticated = false;
    _mockProfile = null;
  }
}

void main() {
  group('Auth Architecture & Flow Tests', () {
    late MockAuthRepository mockRepo;
    late AuthController authController;

    setUp(() {
      mockRepo = MockAuthRepository();
      authController = AuthController(mockRepo);
    });

    test('AuthController initializes with unauthenticated state', () {
      expect(authController.isAuthenticated, isFalse);
      expect(authController.currentProfile, isNull);
      expect(authController.isLoading, isFalse);
      expect(authController.hasError, isFalse);
    });

    test('AuthController signIn succeeds and sets profile', () async {
      final success = await authController.signIn('user@example.com', 'password123');

      expect(success, isTrue);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.currentProfile?.fullName, 'Test User');
      expect(authController.hasError, isFalse);
    });

    test('AuthController signIn handles AuthException gracefully', () async {
      mockRepo.shouldFail = true;
      final success = await authController.signIn('wrong@example.com', 'wrong');

      expect(success, isFalse);
      expect(authController.hasError, isTrue);
      expect(authController.errorMessage, contains('Invalid login credentials'));
    });

    test('AuthController signUp handles email confirmation result', () async {
      final result = await authController.signUp(
        email: 'newuser@example.com',
        password: 'password123',
        fullName: 'New Member',
      );

      expect(result, isNotNull);
      expect(result!.requiresEmailConfirmation, isTrue);
      expect(authController.infoMessage, contains('Please check your email'));
      expect(authController.hasError, isFalse);
    });

    test('AuthController signOut clears user session', () async {
      await authController.signIn('user@example.com', 'password123');
      expect(authController.isAuthenticated, isTrue);

      await authController.signOut();
      expect(authController.isAuthenticated, isFalse);
      expect(authController.currentProfile, isNull);
    });
  });
}
