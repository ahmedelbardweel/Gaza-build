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

  Future<List<MicroTask>> getTasks({
    String? studentId,
    String? engineerId,
    MicroTaskStatus? status,
  }) async {
    var query = _client.from('micro_tasks').select();

    if (studentId != null) {
      query = query.eq('assigned_student_id', studentId);
    }
    if (engineerId != null) {
      query = query.eq('engineer_id', engineerId);
    }
    if (status != null) {
      query = query.eq('status', status.name);
    }

    final res = await query.order('created_at', ascending: false);
    return (res as List<dynamic>)
        .map((json) => MicroTask.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<MicroTask> createTask(MicroTask task) async {
    await _client.from('micro_tasks').upsert(task.toJson());
    return task;
  }

  Future<MicroTask> applyForTask({
    required String taskId,
    required String studentId,
    required String studentName,
  }) async {
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
  }

  Future<MicroTask> submitDeliverable({
    required String taskId,
    required String deliverableNote,
    String? fileUrl,
  }) async {
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
  }

  Future<MicroTask> reviewDeliverable({
    required String taskId,
    required String mentorFeedback,
    required double rating,
  }) async {
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
  }
}
