/// Application Constants for HomeGuardian
class AppConstants {
  AppConstants._();

  static const String appName = 'HomeGuardian';
  static const String appTagline = 'Smart Household Management & Maintenance System';

  // Supabase Configuration via Environment Definitions (--dart-define / --dart-define-from-file)
  // Default values loaded from env.json
  // Security rule: Never expose the Supabase service-role key. Only public/publishable keys are accepted.
  static const String _defaultSupabaseUrl =
      'https://oqpxnvkfjpyjoboghyhs.supabase.co';
  static const String _defaultPublishableKey =
      'sb_publishable_aRXVdcjhXjQ0d7_Hi3ziOg_gjNNuzH4';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultSupabaseUrl,
  );

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: _defaultPublishableKey,
    ),
  );

  /// Helper check verifying whether actual credentials have been injected
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty &&
      !supabaseUrl.contains('YOUR_SUPABASE') &&
      supabasePublishableKey.isNotEmpty &&
      !supabasePublishableKey.contains('YOUR_SUPABASE');

  // Navigation Keys & Labels
  static const String householdIdKey = 'current_household_id';
  static const String sessionKey = 'user_session';
}
