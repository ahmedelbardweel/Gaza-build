import 'package:equatable/equatable.dart';

enum MicroTaskStatus {
  available,
  inProgress,
  underReview,
  completed;

  static MicroTaskStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'in_progress':
      case 'inprogress':
        return MicroTaskStatus.inProgress;
      case 'under_review':
      case 'underreview':
        return MicroTaskStatus.underReview;
      case 'completed':
        return MicroTaskStatus.completed;
      case 'available':
      default:
        return MicroTaskStatus.available;
    }
  }

  String get dbValue {
    switch (this) {
      case MicroTaskStatus.inProgress:
        return 'in_progress';
      case MicroTaskStatus.underReview:
        return 'under_review';
      case MicroTaskStatus.completed:
        return 'completed';
      case MicroTaskStatus.available:
        return 'available';
    }
  }

  String get displayName {
    switch (this) {
      case MicroTaskStatus.available:
        return 'متاحة للتقديم';
      case MicroTaskStatus.inProgress:
        return 'قيد التنفيذ من الطالب';
      case MicroTaskStatus.underReview:
        return 'قيد مراجعة المهندس';
      case MicroTaskStatus.completed:
        return 'مكتملة ومعتمدة';
    }
  }
}

class MicroTask extends Equatable {
  final String id;
  final String engineerId;
  final String engineerName;
  final String? assignedStudentId;
  final String? assignedStudentName;
  final String title;
  final String description;
  final String taskType; // AutoCAD, SketchUp, Moodboard, etc.
  final String softwareNeeded;
  final double rewardUsd;
  final int deadlineDays;
  final MicroTaskStatus status;
  final String? deliverableNote;
  final String? deliverableFileUrl;
  final String? mentorFeedback;
  final double? rating;
  final DateTime createdAt;

  const MicroTask({
    required this.id,
    required this.engineerId,
    required this.engineerName,
    this.assignedStudentId,
    this.assignedStudentName,
    required this.title,
    required this.description,
    required this.taskType,
    this.softwareNeeded = 'AutoCAD / SketchUp',
    required this.rewardUsd,
    this.deadlineDays = 3,
    this.status = MicroTaskStatus.available,
    this.deliverableNote,
    this.deliverableFileUrl,
    this.mentorFeedback,
    this.rating,
    required this.createdAt,
  });

  factory MicroTask.fromJson(Map<String, dynamic> json) {
    return MicroTask(
      id: json['id'] as String? ?? '',
      engineerId: json['engineer_id'] as String? ?? '',
      engineerName: json['engineer_name'] as String? ?? '',
      assignedStudentId: json['assigned_student_id'] as String?,
      assignedStudentName: json['assigned_student_name'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      taskType: json['task_type'] as String? ?? 'رسم ومخططات 2D',
      softwareNeeded: json['software_needed'] as String? ?? 'AutoCAD',
      rewardUsd: (json['reward_usd'] as num?)?.toDouble() ?? 0.0,
      deadlineDays: json['deadline_days'] as int? ?? 3,
      status: MicroTaskStatus.fromString(json['status'] as String?),
      deliverableNote: json['deliverable_note'] as String?,
      deliverableFileUrl: json['deliverable_file_url'] as String?,
      mentorFeedback: json['mentor_feedback'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'engineer_id': engineerId,
      'engineer_name': engineerName,
      'assigned_student_id': assignedStudentId,
      'assigned_student_name': assignedStudentName,
      'title': title,
      'description': description,
      'task_type': taskType,
      'software_needed': softwareNeeded,
      'reward_usd': rewardUsd,
      'deadline_days': deadlineDays,
      'status': status.dbValue,
      'deliverable_note': deliverableNote,
      'deliverable_file_url': deliverableFileUrl,
      'mentor_feedback': mentorFeedback,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MicroTask copyWith({
    String? id,
    String? engineerId,
    String? engineerName,
    String? assignedStudentId,
    String? assignedStudentName,
    String? title,
    String? description,
    String? taskType,
    String? softwareNeeded,
    double? rewardUsd,
    int? deadlineDays,
    MicroTaskStatus? status,
    String? deliverableNote,
    String? deliverableFileUrl,
    String? mentorFeedback,
    double? rating,
    DateTime? createdAt,
  }) {
    return MicroTask(
      id: id ?? this.id,
      engineerId: engineerId ?? this.engineerId,
      engineerName: engineerName ?? this.engineerName,
      assignedStudentId: assignedStudentId ?? this.assignedStudentId,
      assignedStudentName: assignedStudentName ?? this.assignedStudentName,
      title: title ?? this.title,
      description: description ?? this.description,
      taskType: taskType ?? this.taskType,
      softwareNeeded: softwareNeeded ?? this.softwareNeeded,
      rewardUsd: rewardUsd ?? this.rewardUsd,
      deadlineDays: deadlineDays ?? this.deadlineDays,
      status: status ?? this.status,
      deliverableNote: deliverableNote ?? this.deliverableNote,
      deliverableFileUrl: deliverableFileUrl ?? this.deliverableFileUrl,
      mentorFeedback: mentorFeedback ?? this.mentorFeedback,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        engineerId,
        engineerName,
        assignedStudentId,
        assignedStudentName,
        title,
        description,
        taskType,
        softwareNeeded,
        rewardUsd,
        deadlineDays,
        status,
        deliverableNote,
        deliverableFileUrl,
        mentorFeedback,
        rating,
        createdAt,
      ];
}
