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
      _isInitialized = true;
      return _client!;
    } catch (_) {
      throw StateError(
        'SupabaseService has not been initialized. Call initialize() before accessing client.',
      );
    }
  }

  /// Initialize the Supabase connection safely, preventing duplicate initializations.
  Future<void> initialize({
    required String url,
    required String publishableKey,
  }) async {
    // 1. If this service instance already has an active client, avoid duplicate initialization
    if (_isInitialized && _client != null) {
      debugPrint('[SupabaseService] Already initialized with active client.');
      return;
    }

    // 2. Check if global Supabase.instance is already initialized (e.g. across hot restarts)
    try {
      final existingClient = Supabase.instance.client;
      _client = existingClient;
      _isInitialized = true;
      debugPrint('[SupabaseService] Attached to existing global Supabase client.');
      return;
    } catch (_) {
      // Global Supabase.instance is not yet initialized; proceed with initialization
    }

    // Guard against unconfigured placeholder credentials during local dev / test
    if (url.isEmpty ||
        publishableKey.isEmpty ||
        url.contains('YOUR_SUPABASE') ||
        publishableKey.contains('YOUR_SUPABASE')) {
      _isInitialized = false;
      debugPrint('[SupabaseService] Awaiting active credentials. Running in local test mode.');
      return;
    }

    // Clean URL: strip trailing /rest/v1 or slashes to ensure standard Supabase root endpoint
    String cleanUrl = url.trim();
    if (cleanUrl.endsWith('/rest/v1/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 9);
    } else if (cleanUrl.endsWith('/rest/v1')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 8);
    }
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }

    try {
      await Supabase.initialize(
        url: cleanUrl,
        publishableKey: publishableKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('[SupabaseService] Connected successfully to $cleanUrl');
    } catch (e) {
      // Recover client if another concurrent call or hot restart already initialized it
      try {
        _client = Supabase.instance.client;
        _isInitialized = true;
        debugPrint('[SupabaseService] Recovered existing Supabase client after: $e');
      } catch (_) {
        debugPrint('[SupabaseService] Initialization error: $e');
        _isInitialized = false;
      }
    }
  }

  /// Sets client manually (primarily used for Mockito / Unit Tests)
  void setClientForTesting(SupabaseClient testClient) {
    _client = testClient;
    _isInitialized = true;
  }
}
