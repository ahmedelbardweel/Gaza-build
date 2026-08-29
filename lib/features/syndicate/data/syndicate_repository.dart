import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gaza_build/shared/services/supabase_service.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/students/models/micro_task_model.dart';
import 'package:gaza_build/features/syndicate/models/syndicate_models.dart';

class SyndicateRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  SupabaseClient get _client {
    final client = _supabase.client;
    if (client == null) {
      throw Exception('تعذر الاتصال بقاعدة بيانات Supabase.');
    }
    return client;
  }

  Future<List<BaseProfile>> getPendingVerifications() async {
    final res = await _client
        .from('profiles')
        .select()
        .eq('verification_status', VerificationStatus.pending.name)
        .order('created_at', ascending: false);

    return (res as List<dynamic>)
        .map((json) => BaseProfile.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<BaseProfile> updateVerificationStatus({
    required String userId,
    required VerificationStatus status,
    String? rejectionReason,
  }) async {
    final updateData = <String, dynamic>{
      'verification_status': status.name,
      'rejection_reason': rejectionReason,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _client.from('profiles').update(updateData).eq('id', userId);

    final res = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return BaseProfile.fromJson(res);
  }

  Future<List<ReconstructionGuide>> getGuides() async {
    final res = await _client
        .from('reconstruction_guides')
        .select()
        .order('published_date', ascending: false);

    return (res as List<dynamic>)
        .map((json) => ReconstructionGuide.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ReconstructionGuide> addGuide(ReconstructionGuide guide) async {
    await _client.from('reconstruction_guides').upsert(guide.toJson());
    return guide;
  }

  Future<List<ArbitrationCase>> getArbitrationCases() async {
    final res = await _client
        .from('arbitration_cases')
        .select()
        .order('created_at', ascending: false);

    return (res as List<dynamic>)
        .map((json) => ArbitrationCase.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ArbitrationCase> issueArbitrationRuling({
    required String caseId,
    required String ruling,
  }) async {
    final updateData = {
      'syndicate_ruling': ruling,
      'status': 'resolved',
    };

    await _client.from('arbitration_cases').update(updateData).eq('id', caseId);

    final res = await _client
        .from('arbitration_cases')
        .select()
        .eq('id', caseId)
        .single();
    return ArbitrationCase.fromJson(res);
  }

  Future<SectorStatistics> getStatistics() async {
    try {
      final profilesRes = await _client.from('profiles').select('role, verification_status');
      final projectsRes = await _client.from('projects').select('area_m2, agreed_price_usd, approximate_budget_usd');
      final tasksRes = await _client.from('micro_tasks').select('reward_usd, status');

      final profiles = (profilesRes as List<dynamic>);
      final projects = (projectsRes as List<dynamic>);
      final tasks = (tasksRes as List<dynamic>);

      final verifiedEngineers = profiles.where((p) =>
          p['role'] == UserRole.engineer.name &&
          p['verification_status'] == VerificationStatus.approved.name).length;

      final activeStudents = profiles.where((p) =>
          p['role'] == UserRole.student.name).length;

      double totalArea = 0;
      double totalValue = 0;
      for (final p in projects) {
        final area = (p['area_m2'] as num?)?.toDouble() ?? 0.0;
        final price = (p['agreed_price_usd'] as num?)?.toDouble() ??
            (p['approximate_budget_usd'] as num?)?.toDouble() ?? 0.0;
        totalArea += area;
        totalValue += price;
      }

      double studentEarnings = 0;
      for (final t in tasks) {
        if (t['status'] == MicroTaskStatus.completed.name) {
          studentEarnings += (t['reward_usd'] as num?)?.toDouble() ?? 0.0;
        }
      }

      return SectorStatistics(
        totalVerifiedEngineers: verifiedEngineers,
        totalActiveStudents: activeStudents,
        totalReconstructionProjects: projects.length,
        totalReconstructedAreaM2: totalArea,
        estimatedContractVolumeUsd: totalValue,
        studentEarnedIncomeUsd: studentEarnings,
      );
    } catch (_) {
      return const SectorStatistics(
        totalVerifiedEngineers: 0,
        totalActiveStudents: 0,
        totalReconstructionProjects: 0,
        totalReconstructedAreaM2: 0.0,
        estimatedContractVolumeUsd: 0.0,
        studentEarnedIncomeUsd: 0.0,
      );
    }
  }
}
