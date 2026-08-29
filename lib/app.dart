import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/projects/data/projects_repository.dart';
import 'features/projects/presentation/bloc/projects_bloc.dart';
import 'features/students/data/student_tasks_repository.dart';
import 'features/students/presentation/bloc/student_tasks_bloc.dart';
import 'features/syndicate/data/syndicate_repository.dart';
import 'features/syndicate/presentation/bloc/syndicate_bloc.dart';

class GazaBuildApp extends StatefulWidget {
  const GazaBuildApp({super.key});

  @override
  State<GazaBuildApp> createState() => _GazaBuildAppState();
}

class _GazaBuildAppState extends State<GazaBuildApp> {
  late final AuthRepository _authRepository;
  late final ProfileRepository _profileRepository;
  late final ProjectsRepository _projectsRepository;
  late final StudentTasksRepository _studentTasksRepository;
  late final SyndicateRepository _syndicateRepository;

  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository();
    _profileRepository = ProfileRepository();
    _projectsRepository = ProjectsRepository();
    _studentTasksRepository = StudentTasksRepository();
    _syndicateRepository = SyndicateRepository();

    _authBloc = AuthBloc(authRepository: _authRepository)
      ..add(const AuthCheckRequested());

    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _profileRepository),
        RepositoryProvider.value(value: _projectsRepository),
        RepositoryProvider.value(value: _studentTasksRepository),
        RepositoryProvider.value(value: _syndicateRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ThemeCubit(),
          ),
          BlocProvider.value(value: _authBloc),
          BlocProvider(
            create: (_) => ProfileBloc(profileRepository: _profileRepository),
          ),
          BlocProvider(
            create: (_) => ProjectsBloc(projectsRepository: _projectsRepository),
          ),
          BlocProvider(
            create: (_) => StudentTasksBloc(tasksRepository: _studentTasksRepository),
          ),
          BlocProvider(
            create: (_) => SyndicateBloc(syndicateRepository: _syndicateRepository),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'عمار - Gaza Build',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              locale: const Locale('ar'),
              supportedLocales: const [
                Locale('ar'),
                Locale('en'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: _appRouter.router,
            );
          },
        ),
      ),
    );
  }
}

