import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton Pattern Implementation: SupabaseService
/// Ensures only one authenticated SupabaseClient exists throughout the app lifecycle.
class SupabaseService {
  SupabaseService._internal();

  static final SupabaseService instance = SupabaseService._internal();

  SupabaseClient? _client;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Returns the active Supabase client.
  SupabaseClient get client {
    if (_client != null) return _client!;

    // Return the global Supabase client if initialized
    try {
      _client = Supabase.instance.client;
      return _client!;
    } catch (_) {
      throw StateError(
        'SupabaseService has not been initialized. Call initialize() before accessing client.',
      );
    }
  }

  /// Initialize the Supabase connection safely.
  Future<void> initialize({
    required String url,
    required String publishableKey,
  }) async {
    if (_isInitialized) return;

    // Guard against unconfigured placeholder credentials during local dev / test
    if (url.contains('YOUR_SUPABASE') || publishableKey.contains('YOUR_SUPABASE')) {
      _isInitialized = false;
      debugPrint('[SupabaseService] Awaiting active credentials. Running in local test mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        publishableKey: publishableKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('[SupabaseService] Connected successfully to $url');
    } catch (e) {
      debugPrint('[SupabaseService] Initialization error: $e');
      _isInitialized = false;
    }
  }

  /// Sets client manually (primarily used for Mockito / Unit Tests)
  void setClientForTesting(SupabaseClient testClient) {
    _client = testClient;
    _isInitialized = true;
  }
}
