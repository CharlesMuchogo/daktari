import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daktari/dependencies.dart';
import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/bloc/categories/categories_bloc.dart';
import 'package:daktari/presentation/bloc/theme/theme_cubit.dart';
import 'package:daktari/presentation/navigation/chat_router.dart';
import 'package:daktari/presentation/pages/auth_gate.dart';
import 'package:daktari/presentation/session_scope.dart';
import 'package:daktari/presentation/theme/app_theme.dart';

class App extends StatelessWidget {
  final Dependencies dependencies;

  const App({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: dependencies.auth),
        RepositoryProvider.value(value: dependencies.users),
        RepositoryProvider.value(value: dependencies.categories),
        RepositoryProvider.value(value: dependencies.appointments),
        RepositoryProvider.value(value: dependencies.chats),
        RepositoryProvider.value(value: dependencies.notifications),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(
            lazy: false,
            create: (_) => AuthBloc(
              authRepository: dependencies.auth,
              userRepository: dependencies.users,
              notificationRepository: dependencies.notifications,
            )..add(const AuthStarted()),
          ),
          BlocProvider(
            create: (_) =>
                CategoriesBloc(repository: dependencies.categories)
                  ..add(const CategoriesRequested()),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) => MaterialApp(
            title: "Daktari",
            navigatorKey: ChatRouter.navigatorKey,
            scaffoldMessengerKey: ChatRouter.messengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: mode,
            builder: (context, child) => SessionScope(child: child!),
            home: const AuthGate(),
          ),
        ),
      ),
    );
  }
}
