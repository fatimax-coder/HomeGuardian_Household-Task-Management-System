import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import 'base_controller.dart';

/// MVC Controller for Authentication Flow
class AuthController extends BaseController {
  final IAuthRepository _repository;
  UserProfile? _currentProfile;
  StreamSubscription<AuthState>? _authSubscription;
  String? _infoMessage;

  AuthController([IAuthRepository? repository])
      : _repository = repository ?? AuthRepository() {
    _initAuthListener();
  }

  UserProfile? get currentProfile => _currentProfile;
  bool get isAuthenticated => _repository.isAuthenticated;
  User? get currentUser => _repository.currentUser;
  String? get currentUserEmail => _repository.currentUser?.email;
  String? get infoMessage => _infoMessage;

  void _initAuthListener() {
    final stream = _repository.authStateChanges;
    if (stream != null) {
      _authSubscription = stream.listen((data) {
        final AuthChangeEvent event = data.event;
        if (event == AuthChangeEvent.signedIn) {
          checkAuthStatus();
        } else if (event == AuthChangeEvent.signedOut) {
          _currentProfile = null;
          notifyListeners();
        }
      });
    }
  }

  void setInfoMessage(String? message) {
    _infoMessage = message;
    notifyListeners();
  }

  void clearInfoMessage() {
    _infoMessage = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    setLoading(true);
    try {
      if (_repository.isAuthenticated) {
        _currentProfile = await _repository.getCurrentProfile();
      } else {
        _currentProfile = null;
      }
      clearError();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    setLoading(true);
    clearError();
    clearInfoMessage();
    try {
      _currentProfile = await _repository.signIn(email: email, password: password);
      clearError();
      return true;
    } on AuthException catch (e) {
      setError(e.message);
      return false;
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<SignUpResult?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    setLoading(true);
    clearError();
    clearInfoMessage();
    try {
      final result = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (!result.requiresEmailConfirmation && result.profile != null) {
        _currentProfile = result.profile;
      }

      if (result.message != null) {
        setInfoMessage(result.message);
      }

      clearError();
      return result;
    } on AuthException catch (e) {
      setError(e.message);
      return null;
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut() async {
    setLoading(true);
    try {
      await _repository.signOut();
      _currentProfile = null;
      clearError();
      clearInfoMessage();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
