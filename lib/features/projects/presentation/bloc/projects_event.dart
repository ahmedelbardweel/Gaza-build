import 'package:equatable/equatable.dart';
import '../../models/project_model.dart';

sealed class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadProjectsRequested extends ProjectsEvent {
  final String? clientId;
  final String? engineerId;
  final ProjectStatus? status;

  const LoadProjectsRequested({
    this.clientId,
    this.engineerId,
    this.status,
  });

  @override
  List<Object?> get props => [clientId, engineerId, status];
}

final class CreateProjectRequested extends ProjectsEvent {
  final Project project;

  const CreateProjectRequested(this.project);

  @override
  List<Object?> get props => [project];
}

final class SubmitBidRequested extends ProjectsEvent {
  final ProjectBid bid;

  const SubmitBidRequested(this.bid);

  @override
  List<Object?> get props => [bid];
}

final class AcceptBidRequested extends ProjectsEvent {
  final String projectId;
  final String bidId;

  const AcceptBidRequested({
    required this.projectId,
    required this.bidId,
  });

  @override
  List<Object?> get props => [projectId, bidId];
}

final class UpdateMilestoneRequested extends ProjectsEvent {
  final String projectId;
  final String milestoneId;
  final bool isCompleted;
  final String? proofImageUrl;

  const UpdateMilestoneRequested({
    required this.projectId,
    required this.milestoneId,
    required this.isCompleted,
    this.proofImageUrl,
  });

  @override
  List<Object?> get props => [projectId, milestoneId, isCompleted, proofImageUrl];
}
