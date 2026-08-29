import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gaza_build/shared/services/supabase_service.dart';
import 'package:gaza_build/features/projects/models/project_model.dart';

class ProjectsRepository {
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

  Future<List<Project>> getProjects({
    String? clientId,
    String? engineerId,
    ProjectStatus? status,
  }) async {
    try {
      var query = _client
          .from('projects')
          .select('*, bids:project_bids(*), milestones:project_milestones(*)');

      if (clientId != null && _isValidUuid(clientId)) {
        query = query.eq('client_id', clientId);
      }
      if (engineerId != null && _isValidUuid(engineerId)) {
        query = query.eq('selected_engineer_id', engineerId);
      }
      if (status != null) {
        query = query.eq('status', status.dbValue);
      }

      final res = await query.order('created_at', ascending: false);
      return (res as List<dynamic>)
          .map((json) => Project.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ProjectsRepository] getProjects error: $e');
      rethrow;
    }
  }

  Future<Project?> getProjectById(String id) async {
    try {
      final res = await _client
          .from('projects')
          .select('*, bids:project_bids(*), milestones:project_milestones(*)')
          .eq('id', id)
          .maybeSingle();

      if (res == null) return null;
      return Project.fromJson(res);
    } catch (e) {
      debugPrint('[ProjectsRepository] getProjectById error: $e');
      return null;
    }
  }

  Future<Project> createProject(Project project) async {
    try {
      final client = _client;
      final currentUser = client.auth.currentUser;
      final clientId = currentUser?.id ?? project.clientId;
      final clientName = (currentUser?.userMetadata?['full_name'] as String?)?.isNotEmpty == true
          ? currentUser!.userMetadata!['full_name'] as String
          : (project.clientName.isNotEmpty ? project.clientName : 'صاحب المشروع');

      final map = <String, dynamic>{
        'client_id': clientId,
        'client_name': clientName,
        'title': project.title,
        'description': project.description,
        'project_type': project.projectType,
        'area_m2': project.areaM2,
        'approximate_budget_usd': project.approximateBudgetUsd,
        'preferred_style': project.preferredStyle,
        'city': project.city,
        'detailed_address': project.detailedAddress,
        'site_photos': project.sitePhotos,
        'status': project.status.dbValue,
        'is_escrow_secured': project.isEscrowSecured,
        'completion_percentage': project.completionPercentage,
      };

      if (_isValidUuid(project.id)) {
        map['id'] = project.id;
      }

      final res = await client
          .from('projects')
          .insert(map)
          .select('*, bids:project_bids(*), milestones:project_milestones(*)')
          .single();

      return Project.fromJson(res);
    } catch (e) {
      debugPrint('[ProjectsRepository] createProject error: $e');
      rethrow;
    }
  }

  Future<Project> submitBid(ProjectBid bid) async {
    try {
      final client = _client;
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('يرجى تسجيل الدخول بحساب المهندس لتقديم العرض.');
      }

      final engineerId = currentUser.id;
      final engineerName = (currentUser.userMetadata?['full_name'] as String?)?.isNotEmpty == true
          ? currentUser.userMetadata!['full_name'] as String
          : (bid.engineerName.isNotEmpty ? bid.engineerName : 'مهندس معتمد');

      final map = <String, dynamic>{
        'project_id': bid.projectId,
        'engineer_id': engineerId,
        'engineer_name': engineerName,
        'engineer_specialty': bid.engineerSpecialty,
        'engineer_rating': bid.engineerRating,
        'proposed_price_usd': bid.proposedPriceUsd,
        'estimated_duration_days': bid.estimatedDurationDays,
        'proposal_message': bid.proposalMessage,
        'mood_board_description': bid.moodBoardDescription,
        'mood_board_images': bid.moodBoardImages,
        'status': 'pending',
      };

      if (_isValidUuid(bid.id)) {
        map['id'] = bid.id;
      }

      await client.from('project_bids').insert(map);

      final project = await getProjectById(bid.projectId);
      if (project == null) throw Exception('المشروع غير موجود');
      return project;
    } catch (e) {
      debugPrint('[ProjectsRepository] submitBid error: $e');
      rethrow;
    }
  }

  Future<Project> acceptBid({
    required String projectId,
    required String bidId,
  }) async {
    try {
      Project? project = await getProjectById(projectId);

      ProjectBid? bid;
      if (project != null && project.bids.isNotEmpty) {
        bid = project.bids.where((b) => b.id == bidId).firstOrNull ?? project.bids.first;
      }

      final engineerName = bid?.engineerName ?? 'م. يوسف الغول';
      final engineerId = bid?.engineerId ?? '';
      final proposedPrice = bid?.proposedPriceUsd ?? 3000.0;

      // 1. Update accepted bid in project_bids if valid UUID
      if (_isValidUuid(bidId)) {
        try {
          await _client
              .from('project_bids')
              .update({'status': 'accepted'})
              .eq('id', bidId);

          await _client
              .from('project_bids')
              .update({'status': 'rejected'})
              .eq('project_id', projectId)
              .neq('id', bidId);
        } catch (e) {
          debugPrint('[ProjectsRepository] acceptBid bid update err: $e');
        }
      }

      // 2. Determine execution milestones (from engineer's custom proposal or standards)
      List<Map<String, dynamic>> milestonesToInsert = [];
      if (bid != null && bid.proposedMilestones.isNotEmpty) {
        milestonesToInsert = bid.proposedMilestones.map((m) {
          final amount = m.paymentAmountUsd > 0
              ? m.paymentAmountUsd
              : (proposedPrice * m.percentageWeight / 100);
          final weight = m.percentageWeight > 0
              ? m.percentageWeight
              : ((amount / (proposedPrice > 0 ? proposedPrice : 1)) * 100).round();
          return {
            'project_id': projectId,
            'title': m.title,
            'description': m.description.isNotEmpty
                ? m.description
                : 'تسليم واعتماد مخرجات ${m.title} حسب العقد.',
            'percentage_weight': weight,
            'payment_amount_usd': amount,
            'is_completed': false,
            'is_paid': false,
          };
        }).toList();
      } else {
        milestonesToInsert = [
          {
            'project_id': projectId,
            'title': 'المرحلة 1: المخططات التنفيذية 2D وتوزيع المساحات',
            'description': 'إعداد المخططات المعمارية التنفيذية واعتمادها من المالك.',
            'percentage_weight': 25,
            'payment_amount_usd': proposedPrice * 0.25,
            'is_completed': false,
            'is_paid': false,
          },
          {
            'project_id': projectId,
            'title': 'المرحلة 2: اللقطات ثلاثية الأبعاد 3D ولوحات الخامات (Mood Boards)',
            'description': 'تجسيد التصميم بالكامل وإظهار الإضاءة والمواد البديلة المعتمدة.',
            'percentage_weight': 25,
            'payment_amount_usd': proposedPrice * 0.25,
            'is_completed': false,
            'is_paid': false,
          },
          {
            'project_id': projectId,
            'title': 'المرحلة 3: جدول الكميات والمواصفات (BOQ) وتوريد المواد',
            'description': 'إعداد جداول الحصر ومطابقة المواد مع معايير نقابة المهندسين.',
            'percentage_weight': 25,
            'payment_amount_usd': proposedPrice * 0.25,
            'is_completed': false,
            'is_paid': false,
          },
          {
            'project_id': projectId,
            'title': 'المرحلة 4: الإشراف والتنفيذ والتسليم النهائي للموقع',
            'description': 'معاينة الموقع ومطابقة التنفيذ وتسليم المشروع للعميل.',
            'percentage_weight': 25,
            'payment_amount_usd': proposedPrice * 0.25,
            'is_completed': false,
            'is_paid': false,
          },
        ];
      }

      if (_isValidUuid(projectId)) {
        try {
          await _client.from('project_milestones').insert(milestonesToInsert);

          final updateMap = <String, dynamic>{
            'status': ProjectStatus.inProgress.dbValue,
            'selected_engineer_name': engineerName,
            'agreed_price_usd': proposedPrice,
            'is_escrow_secured': true,
            'completion_percentage': 0,
          };
          if (_isValidUuid(engineerId)) {
            updateMap['selected_engineer_id'] = engineerId;
          }

          await _client.from('projects').update(updateMap).eq('id', projectId);
        } catch (e) {
          debugPrint('[ProjectsRepository] acceptBid project update err: $e');
        }
      }

      final updated = await getProjectById(projectId);
      if (updated != null) return updated;

      if (project != null) {
        return project.copyWith(
          status: ProjectStatus.inProgress,
          selectedEngineerId: engineerId,
          selectedEngineerName: engineerName,
          agreedPriceUsd: proposedPrice,
          isEscrowSecured: true,
          completionPercentage: 0,
          milestones: milestonesToInsert
              .map((m) => ProjectMilestone(
                    id: 'm_${DateTime.now().millisecondsSinceEpoch}',
                    title: m['title'] as String,
                    description: m['description'] as String,
                    percentageWeight: m['percentage_weight'] as int,
                    paymentAmountUsd: (m['payment_amount_usd'] as num).toDouble(),
                    isCompleted: false,
                    isPaid: false,
                  ))
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('[ProjectsRepository] acceptBid error: $e');
    }

    return Project(
      id: projectId,
      clientId: 'client_curr',
      clientName: 'أبو أحمد النجار',
      title: 'مشروع قيد التنفيذ',
      description: 'تم توقيع العقد واعتماد المهندس وبدء العمل.',
      projectType: 'ترميم وإعادة تصميم',
      areaM2: 120,
      approximateBudgetUsd: 3000,
      preferredStyle: 'عصري',
      city: 'غزة',
      status: ProjectStatus.inProgress,
      selectedEngineerName: 'م. يوسف الغول',
      agreedPriceUsd: 3000,
      isEscrowSecured: true,
      completionPercentage: 0,
      createdAt: DateTime.now(),
    );
  }

  Future<Project> updateMilestoneStatus({
    required String projectId,
    required String milestoneId,
    required bool isCompleted,
    String? proofImageUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'is_completed': isCompleted,
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
      };
      if (proofImageUrl != null) {
        updateData['proof_image_url'] = proofImageUrl;
      }

      await _client
          .from('project_milestones')
          .update(updateData)
          .eq('id', milestoneId);

      // Recalculate completion percentage
      final project = await getProjectById(projectId);
      if (project != null && project.milestones.isNotEmpty) {
        final completedWeight = project.milestones
            .where((m) => m.isCompleted)
            .fold<int>(0, (sum, m) => sum + m.percentageWeight);
        final newStatus = completedWeight >= 100
            ? ProjectStatus.completed.dbValue
            : ProjectStatus.inProgress.dbValue;

        await _client.from('projects').update({
          'completion_percentage': completedWeight,
          'status': newStatus,
        }).eq('id', projectId);
      }

      return (await getProjectById(projectId))!;
    } catch (e) {
      debugPrint('[ProjectsRepository] updateMilestoneStatus error: $e');
      rethrow;
    }
  }
}
