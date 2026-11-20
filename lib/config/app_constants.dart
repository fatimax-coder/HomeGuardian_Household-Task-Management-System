/// Application Constants for HomeGuardian
class AppConstants {
  AppConstants._();

  static const String appName = 'HomeGuardian';
  static const String appTagline = 'Smart Household Management & Maintenance System';

  // Supabase Configuration
  // Note: These are public anon credentials for client access with RLS enabled.
  // Service-role keys must NEVER be placed in the client application.
  static const String supabaseUrl = 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Navigation Keys & Labels
  static const String householdIdKey = 'current_household_id';
  static const String sessionKey = 'user_session';
}
