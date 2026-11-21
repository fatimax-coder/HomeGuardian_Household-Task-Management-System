/// Application Constants for HomeGuardian
class AppConstants {
  AppConstants._();

  static const String appName = 'HomeGuardian';
  static const String appTagline = 'Smart Household Management & Maintenance System';

  // Supabase Configuration via Environment Definitions (--dart-define / --dart-define-from-file)
  // Security rule: Never expose the Supabase service-role key. Only public/publishable keys are accepted.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co',
  );

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'YOUR_SUPABASE_PUBLISHABLE_KEY',
    ),
  );

  /// Helper check verifying whether actual credentials have been injected
  static bool get isSupabaseConfigured =>
      !supabaseUrl.contains('YOUR_SUPABASE') &&
      !supabasePublishableKey.contains('YOUR_SUPABASE');

  // Navigation Keys & Labels
  static const String householdIdKey = 'current_household_id';
  static const String sessionKey = 'user_session';
}
