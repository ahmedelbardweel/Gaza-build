import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

final class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  final UserRole? preferredRole;

  const AuthSignInRequested({
    required this.email,
    required this.password,
    this.preferredRole,
  });

  @override
  List<Object?> get props => [email, password, preferredRole];
}

final class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final UserRole role;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, role];
}

final class AuthProfileUpdatedLocally extends AuthEvent {
  final BaseProfile profile;

  const AuthProfileUpdatedLocally(this.profile);

  @override
  List<Object?> get props => [profile];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
