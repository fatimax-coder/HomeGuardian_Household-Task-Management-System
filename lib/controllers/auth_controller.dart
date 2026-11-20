import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import 'base_controller.dart';

/// MVC Controller for Authentication Flow
class AuthController extends BaseController {
  final IAuthRepository _repository;
  UserProfile? _currentProfile;

  AuthController([IAuthRepository? repository])
      : _repository = repository ?? AuthRepository();

  UserProfile? get currentProfile => _currentProfile;
  bool get isAuthenticated => _repository.isAuthenticated;

  Future<void> checkAuthStatus() async {
    setLoading(true);
    try {
      _currentProfile = await _repository.getCurrentProfile();
      clearError();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    setLoading(true);
    try {
      _currentProfile = await _repository.signIn(email: email, password: password);
      clearError();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    setLoading(true);
    try {
      _currentProfile = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      clearError();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
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
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}

