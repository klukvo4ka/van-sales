class AppConstants {
  AppConstants._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static const bool kPushEnabled = false;

  static const bool kGpsEnabled = true;
}
