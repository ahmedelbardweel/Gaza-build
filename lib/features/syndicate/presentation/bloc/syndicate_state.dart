import 'package:equatable/equatable.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/syndicate/models/syndicate_models.dart';

enum SyndicateStatus {
  initial,
  loading,
  loaded,
  actionSuccess,
  error,
}

class SyndicateState extends Equatable {
  final SyndicateStatus status;
  final List<BaseProfile> pendingVerifications;
  final List<ReconstructionGuide> guides;
  final List<ArbitrationCase> arbitrationCases;
  final SectorStatistics statistics;
  final String? successMessage;
  final String? errorMessage;

  const SyndicateState({
    this.status = SyndicateStatus.initial,
    this.pendingVerifications = const [],
    this.guides = const [],
    this.arbitrationCases = const [],
    this.statistics = const SectorStatistics(),
    this.successMessage,
    this.errorMessage,
  });

  SyndicateState copyWith({
    SyndicateStatus? status,
    List<BaseProfile>? pendingVerifications,
    List<ReconstructionGuide>? guides,
    List<ArbitrationCase>? arbitrationCases,
    SectorStatistics? statistics,
    String? successMessage,
    String? errorMessage,
  }) {
    return SyndicateState(
      status: status ?? this.status,
      pendingVerifications: pendingVerifications ?? this.pendingVerifications,
      guides: guides ?? this.guides,
      arbitrationCases: arbitrationCases ?? this.arbitrationCases,
      statistics: statistics ?? this.statistics,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pendingVerifications,
        guides,
        arbitrationCases,
        statistics,
        successMessage,
        errorMessage,
      ];
}
