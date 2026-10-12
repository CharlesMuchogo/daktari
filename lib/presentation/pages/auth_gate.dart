import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/navigation/chat_router.dart';
import 'package:daktari/presentation/pages/complete_profile_page.dart';
import 'package:daktari/presentation/pages/home_shell.dart';
import 'package:daktari/presentation/pages/login_page.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        ChatRouter.navigatorKey.currentState?.popUntil(
          (route) => route.isFirst,
        );
        if (state.message.isNotEmpty &&
            state.status == AuthStatus.unauthenticated) {
          showSnack(context, state.message);
        }
      },
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.user?.hasCompleteDoctorProfile !=
              current.user?.hasCompleteDoctorProfile ||
          (previous.user == null) != (current.user == null) ||
          previous.action != current.action,
      builder: (context, state) {
        final user = state.user;
        return switch (state.status) {
          AuthStatus.unknown => const Scaffold(body: Loading()),
          AuthStatus.unauthenticated => const LoginPage(),
          AuthStatus.authenticated when user == null => Scaffold(
            body: state.action.isFailure
                ? ErrorState(
                    message: state.message,
                    onRetry: () =>
                        context.read<AuthBloc>().add(const AuthStarted()),
                  )
                : const Loading(),
          ),
          AuthStatus.authenticated when !user!.hasCompleteDoctorProfile =>
            const CompleteProfilePage(),
          AuthStatus.authenticated => const HomeShell(),
        };
      },
    );
  }
}
