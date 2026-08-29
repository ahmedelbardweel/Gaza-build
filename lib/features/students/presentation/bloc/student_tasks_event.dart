import 'package:equatable/equatable.dart';
import 'package:gaza_build/features/students/models/micro_task_model.dart';

sealed class StudentTasksEvent extends Equatable {
  const StudentTasksEvent();

  @override
  List<Object?> get props => [];
}

final class LoadStudentTasksRequested extends StudentTasksEvent {
  final String? studentId;
  final String? engineerId;
  final MicroTaskStatus? status;

  const LoadStudentTasksRequested({
    this.studentId,
    this.engineerId,
    this.status,
  });

  @override
  List<Object?> get props => [studentId, engineerId, status];
}

final class CreateMicroTaskRequested extends StudentTasksEvent {
  final MicroTask task;

  const CreateMicroTaskRequested(this.task);

  @override
  List<Object?> get props => [task];
}

final class ApplyForTaskRequested extends StudentTasksEvent {
  final String taskId;
  final String studentId;
  final String studentName;

  const ApplyForTaskRequested({
    required this.taskId,
    required this.studentId,
    required this.studentName,
  });

  @override
  List<Object?> get props => [taskId, studentId, studentName];
}

final class SubmitTaskDeliverableRequested extends StudentTasksEvent {
  final String taskId;
  final String deliverableNote;
  final String? fileUrl;

  const SubmitTaskDeliverableRequested({
    required this.taskId,
    required this.deliverableNote,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [taskId, deliverableNote, fileUrl];
}

final class ReviewTaskRequested extends StudentTasksEvent {
  final String taskId;
  final String mentorFeedback;
  final double rating;

  const ReviewTaskRequested({
    required this.taskId,
    required this.mentorFeedback,
    required this.rating,
  });

  @override
  List<Object?> get props => [taskId, mentorFeedback, rating];
}
