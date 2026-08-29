import 'package:equatable/equatable.dart';
import 'package:gaza_build/features/students/models/micro_task_model.dart';

enum StudentTasksStatus {
  initial,
  loading,
  loaded,
  actionSuccess,
  error,
}

class StudentTasksState extends Equatable {
  final StudentTasksStatus status;
  final List<MicroTask> tasks;
  final String? successMessage;
  final String? errorMessage;

  const StudentTasksState({
    this.status = StudentTasksStatus.initial,
    this.tasks = const [],
    this.successMessage,
    this.errorMessage,
  });

  StudentTasksState copyWith({
    StudentTasksStatus? status,
    List<MicroTask>? tasks,
    String? successMessage,
    String? errorMessage,
  }) {
    return StudentTasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tasks, successMessage, errorMessage];
}
