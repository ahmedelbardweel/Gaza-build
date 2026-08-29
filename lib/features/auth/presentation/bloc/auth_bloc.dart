import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthProfileUpdatedLocally>(_onAuthProfileUpdatedLocally);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null) {
      emit(state.copyWith(status: AuthStatus.loading));
    }
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        ));
      }
    } catch (e) {
      if (state.user == null) {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.signInWithEmailPassword(
        email: event.email,
        password: event.password,
        preferredRole: event.preferredRole,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      ));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.signUpWithEmailPassword(
        email: event.email,
        password: event.password,
        role: event.role,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      ));
    }
  }

  void _onAuthProfileUpdatedLocally(
    AuthProfileUpdatedLocally event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: event.profile,
    ));
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await _authRepository.signOut();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
    ));
  }
}
