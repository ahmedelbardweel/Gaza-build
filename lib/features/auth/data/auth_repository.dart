import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gaza_build/shared/services/supabase_service.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';

class AuthRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  SupabaseClient get _client {
    final client = _supabase.client;
    if (client == null) {
      throw Exception('تعذر الاتصال بقاعدة بيانات Supabase. يرجى التحقق من اتصال الإنترنت.');
    }
    return client;
  }

  Future<BaseProfile?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final cleanEmail = (user.email ?? '').trim().toLowerCase();

      // 1. Check Supabase profiles table by ID or email
      var data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null && cleanEmail.isNotEmpty) {
        data = await _client
            .from('profiles')
            .select()
            .eq('email', cleanEmail)
            .maybeSingle();
      }

      if (data != null) {
        return BaseProfile.fromJson(data);
      }

      // 2. Resolve role from metadata or email
      UserRole role = UserRole.client;
      final roleStr = user.userMetadata?['role'] as String?;
      if (roleStr != null) {
        role = UserRole.fromString(roleStr);
      } else if (cleanEmail.contains('engineer')) {
        role = UserRole.engineer;
      } else if (cleanEmail.contains('student')) {
        role = UserRole.student;
      } else if (cleanEmail.contains('syndicate')) {
        role = UserRole.syndicate;
      }

      final fallbackProfile = BaseProfile(
        id: user.id,
        email: cleanEmail,
        role: role,
        isProfileComplete: false,
        verificationStatus: role == UserRole.client
            ? VerificationStatus.approved
            : VerificationStatus.unsubmitted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _client.from('profiles').upsert(fallbackProfile.toJson());
      return fallbackProfile;
    } catch (e) {
      debugPrint('[AuthRepository] getCurrentUser error: $e');
      return null;
    }
  }

  Future<BaseProfile> signInWithEmailPassword({
    required String email,
    required String password,
    UserRole? preferredRole,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    try {
      final response = await _client.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('فشل تسجيل الدخول. لم يتم العثور على بيانات المستخدم.');
      }

      return await _getOrCreateProfile(user, cleanEmail, preferredRole);
    } on AuthException catch (e) {
      debugPrint('[AuthRepository] signInWithPassword auth exception: ${e.message}');
      if (e.message.contains('Invalid login credentials')) {
        throw Exception('البريد أو كلمة المرور غير صحيحة. يرجى التبديل لتبويب "إنشاء حساب جديد" للتسجيل.');
      }
      throw Exception(e.message);
    } catch (e) {
      debugPrint('[AuthRepository] General signIn error: $e');
      throw Exception('تعذر تسجيل الدخول: $e');
    }
  }

  Future<BaseProfile> signUpWithEmailPassword({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    try {
      final response = await _client.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {'role': role.name},
      );

      final user = response.user;
      if (user == null) {
        throw Exception('فشل إنشاء الحساب. لم يتم استلام استجابة من الخادم.');
      }

      return await _getOrCreateProfile(user, cleanEmail, role);
    } on AuthException catch (e) {
      debugPrint('[AuthRepository] signUp auth exception: ${e.message}');
      // If user already exists, try signing in with that password
      if (e.message.contains('User already registered') || e.statusCode == '422') {
        return await signInWithEmailPassword(
          email: cleanEmail,
          password: password,
          preferredRole: role,
        );
      }
      throw Exception(e.message);
    } catch (e) {
      debugPrint('[AuthRepository] signUp error: $e');
      throw Exception('تعذر إنشاء الحساب: $e');
    }
  }

  Future<BaseProfile> _getOrCreateProfile(
    User user,
    String cleanEmail,
    UserRole? preferredRole,
  ) async {
    // 1. Try finding profile by user.id
    var data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    // 2. If not found by id, check if a pre-seeded profile exists with this email
    if (data == null) {
      final emailData = await _client
          .from('profiles')
          .select()
          .eq('email', cleanEmail)
          .maybeSingle();

      if (emailData != null) {
        // Return existing seeded profile
        return BaseProfile.fromJson(emailData);
      }
    }

    if (data != null) {
      return BaseProfile.fromJson(data);
    }

    // 3. Create fresh profile
    final roleStr = user.userMetadata?['role'] as String?;
    final role = roleStr != null
        ? UserRole.fromString(roleStr)
        : (preferredRole ?? UserRole.client);

    final newProfile = BaseProfile(
      id: user.id,
      email: cleanEmail,
      role: role,
      isProfileComplete: false,
      verificationStatus: role == UserRole.client
          ? VerificationStatus.approved
          : VerificationStatus.unsubmitted,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _client.from('profiles').upsert(newProfile.toJson());
    return newProfile;
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('[AuthRepository] signOut error: $e');
    }
  }
}
