import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gaza_build/shared/services/supabase_service.dart';
import 'package:gaza_build/features/students/models/micro_task_model.dart';

class StudentTasksRepository {
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

  Future<List<MicroTask>> getTasks({
    String? studentId,
    String? engineerId,
    MicroTaskStatus? status,
  }) async {
    try {
      var query = _client.from('micro_tasks').select();

      if (studentId != null && _isValidUuid(studentId)) {
        query = query.eq('assigned_student_id', studentId);
      }
      if (engineerId != null && _isValidUuid(engineerId)) {
        query = query.eq('engineer_id', engineerId);
      }
      if (status != null) {
        query = query.eq('status', status.name);
      }

      final res = await query.order('created_at', ascending: false);
      return (res as List<dynamic>)
          .map((json) => MicroTask.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[StudentTasksRepository] getTasks error: $e');
      return [];
    }
  }

  Future<MicroTask> createTask(MicroTask task) async {
    try {
      final client = _client;
      final currentUser = client.auth.currentUser;
      final engineerId = currentUser?.id ?? task.engineerId;
      final engineerName = (currentUser?.userMetadata?['full_name'] as String?)?.isNotEmpty == true
          ? currentUser!.userMetadata!['full_name'] as String
          : (task.engineerName.isNotEmpty ? task.engineerName : 'مهندس معتمد');

      final map = <String, dynamic>{
        'engineer_id': engineerId,
        'engineer_name': engineerName,
        'title': task.title,
        'description': task.description,
        'task_type': task.taskType,
        'software_needed': task.softwareNeeded,
        'reward_usd': task.rewardUsd,
        'deadline_days': task.deadlineDays,
        'status': task.status.name,
      };

      if (_isValidUuid(task.id)) {
        map['id'] = task.id;
      }

      final res = await client.from('micro_tasks').insert(map).select().single();
      return MicroTask.fromJson(res);
    } catch (e) {
      debugPrint('[StudentTasksRepository] createTask error: $e');
      rethrow;
    }
  }

  Future<MicroTask> applyForTask({
    required String taskId,
    required String studentId,
    required String studentName,
  }) async {
    try {
      final updateData = {
        'assigned_student_id': studentId,
        'assigned_student_name': studentName,
        'status': MicroTaskStatus.inProgress.name,
      };

      await _client.from('micro_tasks').update(updateData).eq('id', taskId);

      final res = await _client
          .from('micro_tasks')
          .select()
          .eq('id', taskId)
          .single();
      return MicroTask.fromJson(res);
    } catch (e) {
      debugPrint('[StudentTasksRepository] applyForTask error: $e');
      rethrow;
    }
  }

  Future<MicroTask> submitDeliverable({
    required String taskId,
    required String deliverableNote,
    String? fileUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'deliverable_note': deliverableNote,
        'status': MicroTaskStatus.underReview.name,
      };
      if (fileUrl != null) {
        updateData['deliverable_file_url'] = fileUrl;
      }

      await _client.from('micro_tasks').update(updateData).eq('id', taskId);

      final res = await _client
          .from('micro_tasks')
          .select()
          .eq('id', taskId)
          .single();
      return MicroTask.fromJson(res);
    } catch (e) {
      debugPrint('[StudentTasksRepository] submitDeliverable error: $e');
      rethrow;
    }
  }

  Future<MicroTask> reviewDeliverable({
    required String taskId,
    required String mentorFeedback,
    required double rating,
  }) async {
    try {
      final updateData = {
        'mentor_feedback': mentorFeedback,
        'rating': rating,
        'status': MicroTaskStatus.completed.name,
      };

      await _client.from('micro_tasks').update(updateData).eq('id', taskId);

      final res = await _client
          .from('micro_tasks')
          .select()
          .eq('id', taskId)
          .single();
      return MicroTask.fromJson(res);
    } catch (e) {
      debugPrint('[StudentTasksRepository] reviewDeliverable error: $e');
      rethrow;
    }
  }
}
