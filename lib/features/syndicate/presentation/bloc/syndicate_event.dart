import 'package:equatable/equatable.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/syndicate/models/syndicate_models.dart';

sealed class SyndicateEvent extends Equatable {
  const SyndicateEvent();

  @override
  List<Object?> get props => [];
}

final class LoadSyndicateDashboardRequested extends SyndicateEvent {
  const LoadSyndicateDashboardRequested();
}

final class UpdateVerificationRequested extends SyndicateEvent {
  final String userId;
  final VerificationStatus status;
  final String? rejectionReason;

  const UpdateVerificationRequested({
    required this.userId,
    required this.status,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [userId, status, rejectionReason];
}

final class AddGuideRequested extends SyndicateEvent {
  final ReconstructionGuide guide;

  const AddGuideRequested(this.guide);

  @override
  List<Object?> get props => [guide];
}

final class IssueRulingRequested extends SyndicateEvent {
  final String caseId;
  final String ruling;

  const IssueRulingRequested({
    required this.caseId,
    required this.ruling,
  });

  @override
  List<Object?> get props => [caseId, ruling];
}
