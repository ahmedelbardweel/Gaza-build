import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(const ProfileState()) {
    on<CompleteProfileSubmitted>(_onCompleteProfileSubmitted);
    on<LoadRoleProfileRequested>(_onLoadRoleProfileRequested);
  }

  Future<void> _onCompleteProfileSubmitted(
    CompleteProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final updated = await _profileRepository.completeProfile(
        baseProfile: event.baseProfile,
        engineerProfile: event.engineerProfile,
        clientProfile: event.clientProfile,
        studentProfile: event.studentProfile,
        syndicateProfile: event.syndicateProfile,
      );
      emit(state.copyWith(
        status: ProfileStatus.success,
        updatedProfile: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'حدث خطأ أثناء حفظ الملف الشخصي: $e',
      ));
    }
  }

  Future<void> _onLoadRoleProfileRequested(
    LoadRoleProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final roleData = await _profileRepository.getRoleProfile(
        event.userId,
        event.role,
      );
      emit(state.copyWith(roleProfile: roleData));
    } catch (_) {}
  }
}
