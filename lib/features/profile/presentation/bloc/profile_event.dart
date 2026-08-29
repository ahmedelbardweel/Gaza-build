import 'package:equatable/equatable.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/profile/models/profile_models.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class CompleteProfileSubmitted extends ProfileEvent {
  final BaseProfile baseProfile;
  final EngineerProfile? engineerProfile;
  final ClientProfile? clientProfile;
  final StudentProfile? studentProfile;
  final SyndicateProfile? syndicateProfile;

  const CompleteProfileSubmitted({
    required this.baseProfile,
    this.engineerProfile,
    this.clientProfile,
    this.studentProfile,
    this.syndicateProfile,
  });

  @override
  List<Object?> get props => [
        baseProfile,
        engineerProfile,
        clientProfile,
        studentProfile,
        syndicateProfile,
      ];
}

final class LoadRoleProfileRequested extends ProfileEvent {
  final String userId;
  final UserRole role;

  const LoadRoleProfileRequested({
    required this.userId,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, role];
}
