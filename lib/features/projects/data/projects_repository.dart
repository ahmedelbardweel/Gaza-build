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

  Future<List<Project>> getProjects({
    String? clientId,
    String? engineerId,
    ProjectStatus? status,
  }) async {
    var query = _client
        .from('projects')
        .select('*, bids:project_bids(*), milestones:project_milestones(*)');

    if (clientId != null) {
      query = query.eq('client_id', clientId);
    }
    if (engineerId != null) {
      query = query.eq('selected_engineer_id', engineerId);
    }
    if (status != null) {
      query = query.eq('status', status.name);
    }

    final res = await query.order('created_at', ascending: false);
    return (res as List<dynamic>)
        .map((json) => Project.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Project?> getProjectById(String id) async {
    final res = await _client
        .from('projects')
        .select('*, bids:project_bids(*), milestones:project_milestones(*)')
        .eq('id', id)
        .maybeSingle();

    if (res == null) return null;
    return Project.fromJson(res);
  }

  Future<Project> createProject(Project project) async {
    final map = project.toJson();
    map.remove('bids');
    map.remove('milestones');

    await _client.from('projects').upsert(map);
    return project;
  }

  Future<Project> submitBid(ProjectBid bid) async {
    await _client.from('project_bids').upsert(bid.toJson());
    final project = await getProjectById(bid.projectId);
    if (project == null) throw Exception('المشروع غير موجود');
    return project;
  }

  Future<Project> acceptBid({
    required String projectId,
    required String bidId,
  }) async {
    final project = await getProjectById(projectId);
    if (project == null) throw Exception('المشروع غير موجود');

    final bid = project.bids.firstWhere(
      (b) => b.id == bidId,
      orElse: () => throw Exception('العرض غير موجود'),
    );

    // 1. Update accepted bid in project_bids
    await _client
        .from('project_bids')
        .update({'status': 'accepted'})
        .eq('id', bidId);

    // 2. Reject other bids for this project
    await _client
        .from('project_bids')
        .update({'status': 'rejected'})
        .eq('project_id', projectId)
        .neq('id', bidId);

    // 3. Create 4 standard execution milestones
    final defaultMilestones = [
      {
        'project_id': projectId,
        'title': 'المرحلة 1: المخططات التنفيذية 2D وتوزيع المساحات',
        'description': 'إعداد المخططات المعمارية التنفيذية واعتمادها من المالك.',
        'percentage_weight': 25,
        'payment_amount_usd': bid.proposedPriceUsd * 0.25,
        'is_completed': false,
        'is_paid': false,
      },
      {
        'project_id': projectId,
        'title': 'المرحلة 2: اللقطات ثلاثية الأبعاد 3D ولوحات الخامات (Mood Boards)',
        'description': 'تجسيد التصميم بالكامل وإظهار الإضاءة والمواد البديلة المعتمدة.',
        'percentage_weight': 25,
        'payment_amount_usd': bid.proposedPriceUsd * 0.25,
        'is_completed': false,
        'is_paid': false,
      },
      {
        'project_id': projectId,
        'title': 'المرحلة 3: جدول الكميات والمواصفات (BOQ) وتوريد المواد',
        'description': 'إعداد جداول الحصر ومطابقة المواد مع معايير نقابة المهندسين.',
        'percentage_weight': 25,
        'payment_amount_usd': bid.proposedPriceUsd * 0.25,
        'is_completed': false,
        'is_paid': false,
      },
      {
        'project_id': projectId,
        'title': 'المرحلة 4: الإشراف والتنفيذ والتسليم النهائي للموقع',
        'description': 'معاينة الموقع ومطابقة التنفيذ وتسليم المشروع للعميل.',
        'percentage_weight': 25,
        'payment_amount_usd': bid.proposedPriceUsd * 0.25,
        'is_completed': false,
        'is_paid': false,
      },
    ];

    await _client.from('project_milestones').insert(defaultMilestones);

    // 4. Update project state
    await _client.from('projects').update({
      'status': ProjectStatus.inProgress.name,
      'selected_engineer_id': bid.engineerId,
      'selected_engineer_name': bid.engineerName,
      'agreed_price_usd': bid.proposedPriceUsd,
      'is_escrow_secured': true,
      'completion_percentage': 0,
    }).eq('id', projectId);

    final updated = await getProjectById(projectId);
    return updated!;
  }

  Future<Project> updateMilestoneStatus({
    required String projectId,
    required String milestoneId,
    required bool isCompleted,
    String? proofImageUrl,
  }) async {
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
          ? ProjectStatus.completed.name
          : ProjectStatus.inProgress.name;

      await _client.from('projects').update({
        'completion_percentage': completedWeight,
        'status': newStatus,
      }).eq('id', projectId);
    }

    return (await getProjectById(projectId))!;
  }
}
