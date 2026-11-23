import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_guardian/config/app_constants.dart';
import 'package:home_guardian/repositories/auth_repository.dart';
import 'package:home_guardian/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Live Supabase Auth & Initialization Verification', () {
    test('Credentials loaded correctly and isSupabaseConfigured is true', () {
      expect(AppConstants.supabaseUrl, isNotEmpty);
      expect(AppConstants.supabaseUrl.contains('YOUR_SUPABASE'), isFalse);
      expect(AppConstants.supabasePublishableKey, isNotEmpty);
      expect(AppConstants.supabasePublishableKey.contains('YOUR_SUPABASE'), isFalse);
      expect(AppConstants.isSupabaseConfigured, isTrue);
    });

    test('SupabaseService initializes cleanly before accessing client', () async {
      await SupabaseService.instance.initialize(
        url: AppConstants.supabaseUrl,
        publishableKey: AppConstants.supabasePublishableKey,
      );

      expect(SupabaseService.instance.isInitialized, isTrue);
      expect(SupabaseService.instance.client, isNotNull);
      expect(SupabaseService.instance.client.auth, isNotNull);
    });

    test('Avoids duplicate initialization gracefully', () async {
      // Second call to initialize should be safe and idempotent
      await SupabaseService.instance.initialize(
        url: AppConstants.supabaseUrl,
        publishableKey: AppConstants.supabasePublishableKey,
      );

      expect(SupabaseService.instance.isInitialized, isTrue);
      expect(SupabaseService.instance.client, isNotNull);
    });

    test('AuthRepository accesses initialized Supabase client and methods work', () async {
      final authRepo = AuthRepository();
      expect(authRepo.isAuthenticated, isFalse);

      // Verify signing out when unauthenticated completes cleanly
      await authRepo.signOut();
      expect(authRepo.isAuthenticated, isFalse);
    });
  });
}

