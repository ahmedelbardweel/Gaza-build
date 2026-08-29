import 'package:flutter/foundation.dart';
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

  bool _isValidUuid(String? id) {
    if (id == null || id.isEmpty) return false;
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(id);
  }

  Future<List<BaseProfile>> getPendingVerifications() async {
    try {
      final res = await _client
          .from('profiles')
          .select()
          .eq('verification_status', VerificationStatus.pending.name)
          .order('created_at', ascending: false);

      return (res as List<dynamic>)
          .map((json) => BaseProfile.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[SyndicateRepository] getPendingVerifications error: $e');
      return [];
    }
  }

  Future<BaseProfile> updateVerificationStatus({
    required String userId,
    required VerificationStatus status,
    String? rejectionReason,
  }) async {
    try {
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
    } catch (e) {
      debugPrint('[SyndicateRepository] updateVerificationStatus error: $e');
      rethrow;
    }
  }

  Future<List<ReconstructionGuide>> getGuides() async {
    try {
      final res = await _client
          .from('reconstruction_guides')
          .select()
          .order('published_date', ascending: false);

      return (res as List<dynamic>)
          .map((json) => ReconstructionGuide.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[SyndicateRepository] getGuides error: $e');
      return [];
    }
  }

  Future<ReconstructionGuide> addGuide(ReconstructionGuide guide) async {
    try {
      final map = guide.toJson();
      if (!_isValidUuid(guide.id)) {
        map.remove('id');
      }

      final res = await _client.from('reconstruction_guides').insert(map).select().single();
      return ReconstructionGuide.fromJson(res);
    } catch (e) {
      debugPrint('[SyndicateRepository] addGuide error: $e');
      rethrow;
    }
  }

  Future<List<ArbitrationCase>> getArbitrationCases() async {
    try {
      final res = await _client
          .from('arbitration_cases')
          .select()
          .order('created_at', ascending: false);

      return (res as List<dynamic>)
          .map((json) => ArbitrationCase.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[SyndicateRepository] getArbitrationCases error: $e');
      return [];
    }
  }

  Future<ArbitrationCase> issueArbitrationRuling({
    required String caseId,
    required String ruling,
  }) async {
    try {
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
    } catch (e) {
      debugPrint('[SyndicateRepository] issueArbitrationRuling error: $e');
      rethrow;
    }
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
