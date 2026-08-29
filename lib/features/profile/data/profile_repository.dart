import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gaza_build/shared/services/supabase_service.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/profile/models/profile_models.dart';

class ProfileRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  SupabaseClient get _client {
    final client = _supabase.client;
    if (client == null) {
      throw Exception('تعذر الاتصال بقاعدة بيانات Supabase.');
    }
    return client;
  }

  Future<BaseProfile> completeProfile({
    required BaseProfile baseProfile,
    EngineerProfile? engineerProfile,
    ClientProfile? clientProfile,
    StudentProfile? studentProfile,
    SyndicateProfile? syndicateProfile,
  }) async {
    final updatedBase = baseProfile.copyWith(
      isProfileComplete: true,
      verificationStatus: baseProfile.role == UserRole.client
          ? VerificationStatus.approved
          : VerificationStatus.pending,
      updatedAt: DateTime.now(),
    );

    // 1. Upsert into base profiles table
    await _client.from('profiles').upsert(updatedBase.toJson());

    // 2. Upsert into role-specific table
    if (engineerProfile != null) {
      await _client
          .from('engineer_profiles')
          .upsert(engineerProfile.toJson());
    } else if (clientProfile != null) {
      await _client
          .from('client_profiles')
          .upsert(clientProfile.toJson());
    } else if (studentProfile != null) {
      await _client
          .from('student_profiles')
          .upsert(studentProfile.toJson());
    } else if (syndicateProfile != null) {
      await _client
          .from('syndicate_profiles')
          .upsert(syndicateProfile.toJson());
    }

    return updatedBase;
  }

  Future<dynamic> getRoleProfile(String userId, UserRole role) async {
    switch (role) {
      case UserRole.engineer:
        final data = await _client
            .from('engineer_profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        if (data == null) return null;
        return EngineerProfile.fromJson(data);

      case UserRole.client:
        final data = await _client
            .from('client_profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        if (data == null) return null;
        return ClientProfile.fromJson(data);

      case UserRole.student:
        final data = await _client
            .from('student_profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        if (data == null) return null;
        return StudentProfile.fromJson(data);

      case UserRole.syndicate:
        final data = await _client
            .from('syndicate_profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        if (data == null) return null;
        return SyndicateProfile.fromJson(data);
    }
  }
}
