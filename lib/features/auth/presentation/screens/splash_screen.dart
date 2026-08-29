import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gaza_build/core/theme/app_colors.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    // Trigger auth verification check
    context.read<AuthBloc>().add(const AuthCheckRequested());

    // Timer fallback in case state was already resolved
    _fallbackTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      _handleNavigation(context.read<AuthBloc>().state);
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _handleNavigation(AuthState state) {
    if (!mounted) return;

    if (state.status == AuthStatus.authenticated && state.user != null) {
      final user = state.user!;
      if (!user.isProfileComplete) {
        context.go('/complete-profile');
      } else {
        switch (user.role) {
          case UserRole.engineer:
            context.go('/engineer/home');
            break;
          case UserRole.client:
            context.go('/home');
            break;
          case UserRole.student:
            context.go('/student/home');
            break;
          case UserRole.syndicate:
            context.go('/syndicate/home');
            break;
        }
      }
    } else if (state.status == AuthStatus.unauthenticated) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated ||
              state.status == AuthStatus.unauthenticated) {
            _handleNavigation(state);
          }
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Center(
                child: const Text(
                  'عَمّـار',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
