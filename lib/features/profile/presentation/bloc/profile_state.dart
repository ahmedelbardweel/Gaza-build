import 'package:equatable/equatable.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  error,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final BaseProfile? updatedProfile;
  final dynamic roleProfile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.updatedProfile,
    this.roleProfile,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    BaseProfile? updatedProfile,
    dynamic roleProfile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      updatedProfile: updatedProfile ?? this.updatedProfile,
      roleProfile: roleProfile ?? this.roleProfile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, updatedProfile, roleProfile, errorMessage];
}
