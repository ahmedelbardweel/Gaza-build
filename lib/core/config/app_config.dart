import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConfig {
  static const String defaultSupabaseUrl = 'https://sdqyhboeudiphjmynlzj.supabase.co';
  static const String defaultSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkcXloYm9ldWRpcGhqbXlubHpqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc5MTgwODYsImV4cCI6MjEwMzQ5NDA4Nn0.UAYXLCU-LmV2vWrw2TVAE2wku6JuGxw9jwxXi1QyqDQ';

  static String supabaseUrl = defaultSupabaseUrl;
  static String supabaseAnonKey = defaultSupabaseAnonKey;

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
      supabaseUrl = dotenv.get('SUPABASE_URL', fallback: defaultSupabaseUrl);
      supabaseAnonKey = dotenv.get('SUPABASE_ANON_KEY', fallback: defaultSupabaseAnonKey);
    } catch (_) {
      supabaseUrl = defaultSupabaseUrl;
      supabaseAnonKey = defaultSupabaseAnonKey;
    }
  }

  static bool get isSupabaseConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('your-project') &&
        !supabaseUrl.contains('placeholder');
  }
}
