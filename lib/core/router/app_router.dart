import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaza_build/features/auth/presentation/screens/auth_screen.dart';
import 'package:gaza_build/features/auth/presentation/screens/splash_screen.dart';
import 'package:gaza_build/features/chat/presentation/screens/chat_screen.dart';
import 'package:gaza_build/features/chat/presentation/screens/quick_consult_screen.dart';
import 'package:gaza_build/features/profile/presentation/screens/complete_profile_screen.dart';
import '../../features/projects/models/project_model.dart';
import '../../features/projects/presentation/screens/client_home_screen.dart';
import '../../features/projects/presentation/screens/create_project_screen.dart';
import '../../features/projects/presentation/screens/engineer_home_screen.dart';
import '../../features/projects/presentation/screens/project_details_screen.dart';
import '../../features/projects/presentation/screens/projects_marketplace_screen.dart';
import '../../features/students/presentation/screens/engineer_delegate_task_screen.dart';
import '../../features/students/presentation/screens/student_home_screen.dart';
import '../../features/syndicate/presentation/screens/syndicate_home_screen.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final isAuthenticated = authState.isAuthenticated;
      final user = authState.user;

      final isSplash = state.matchedLocation == '/splash';
      final isGoingToAuth = state.matchedLocation == '/auth';
      final isGoingToCompleteProfile = state.matchedLocation == '/complete-profile';

      // Keep user on splash until splash handles navigation
      if (isSplash) {
        return null;
      }

      // 1. If not authenticated, force to /auth
      if (!isAuthenticated || user == null) {
        return isGoingToAuth ? null : '/auth';
      }

      // 2. If authenticated but profile is incomplete, force to /complete-profile
      if (!user.isProfileComplete) {
        return isGoingToCompleteProfile ? null : '/complete-profile';
      }

      // 3. If authenticated & complete, and trying to go to /auth or /complete-profile, redirect to role home
      if (isGoingToAuth || isGoingToCompleteProfile) {
        return _getHomeRouteForRole(user.role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) {
          final user = authBloc.state.user!;
          return CompleteProfileScreen(user: user);
        },
      ),

      // Client Routes
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final user = authBloc.state.user!;
          return ClientHomeScreen(user: user);
        },
      ),
      GoRoute(
        path: '/projects/create',
        builder: (context, state) => const CreateProjectScreen(),
      ),
      GoRoute(
        path: '/projects/details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final project = state.extra as Project?;
          return ProjectDetailsScreen(projectId: id, initialProject: project);
        },
      ),
      GoRoute(
        path: '/projects/marketplace',
        builder: (context, state) => const ProjectsMarketplaceScreen(),
      ),

      // Engineer Routes
      GoRoute(
        path: '/engineer/home',
        builder: (context, state) {
          final user = authBloc.state.user!;
          return EngineerHomeScreen(user: user);
        },
      ),
      GoRoute(
        path: '/engineer/delegate-task',
        builder: (context, state) => const EngineerDelegateTaskScreen(),
      ),

      // Student Routes
      GoRoute(
        path: '/student/home',
        builder: (context, state) {
          final user = authBloc.state.user!;
          return StudentHomeScreen(user: user);
        },
      ),

      // Syndicate Routes
      GoRoute(
        path: '/syndicate/home',
        builder: (context, state) {
          final user = authBloc.state.user!;
          return SyndicateHomeScreen(user: user);
        },
      ),

      // Chat & Consultations
      GoRoute(
        path: '/quick-consult',
        builder: (context, state) => const QuickConsultScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ChatScreen(
            title: extra['title'] as String? ?? 'المحادثة',
            otherName: extra['otherName'] as String? ?? 'الطرف الآخر',
            otherRole: extra['otherRole'] as String? ?? 'client',
          );
        },
      ),
    ],
  );

  static String _getHomeRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.client:
        return '/home';
      case UserRole.engineer:
        return '/engineer/home';
      case UserRole.student:
        return '/student/home';
      case UserRole.syndicate:
        return '/syndicate/home';
    }
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
