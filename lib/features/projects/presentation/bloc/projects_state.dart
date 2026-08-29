import 'package:equatable/equatable.dart';
import '../../models/project_model.dart';

enum ProjectsStatus {
  initial,
  loading,
  loaded,
  actionSuccess,
  error,
}

class ProjectsState extends Equatable {
  final ProjectsStatus status;
  final List<Project> projects;
  final Project? selectedProject;
  final String? successMessage;
  final String? errorMessage;

  const ProjectsState({
    this.status = ProjectsStatus.initial,
    this.projects = const [],
    this.selectedProject,
    this.successMessage,
    this.errorMessage,
  });

  ProjectsState copyWith({
    ProjectsStatus? status,
    List<Project>? projects,
    Project? selectedProject,
    String? successMessage,
    String? errorMessage,
  }) {
    return ProjectsState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      selectedProject: selectedProject ?? this.selectedProject,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        projects,
        selectedProject,
        successMessage,
        errorMessage,
      ];
}
