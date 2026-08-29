import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (!AppConfig.isSupabaseConfigured) {
      debugPrint('[SupabaseService] Supabase not configured with live credentials. Running in local offline-first mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: AppConfig.supabaseAnonKey,
      );
      _initialized = true;
      debugPrint('[SupabaseService] Supabase initialized successfully.');
    } catch (e) {
      debugPrint('[SupabaseService] Failed to initialize Supabase: $e');
    }
  }

  bool get isReady => _initialized;

  SupabaseClient? get client {
    if (!_initialized) return null;
    return Supabase.instance.client;
  }
}
