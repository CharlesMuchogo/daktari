import 'dart:io';

import 'package:daktari/domain/repositories/auth_repository.dart';
import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialSignInButtons extends StatelessWidget {
  const SocialSignInButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final busy = state.action.isLoading;
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final appleBackground = dark ? Colors.white : Colors.black;
    final appleForeground = dark ? Colors.black : Colors.white;

    void signIn(SocialProvider provider) =>
        context.read<AuthBloc>().add(SocialLoginRequested(provider));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: busy ? null : () => signIn(SocialProvider.google),
          icon: state.isSubmitting(AuthMethod.google)
              ? const ButtonSpinner()
              : const Text(
                  "G",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4285F4),
                  ),
                ),
          label: const Text("Continue with Google"),
        ),
        if (Platform.isIOS) ...[
          gap,
          FilledButton.icon(
            onPressed: busy ? null : () => signIn(SocialProvider.apple),
            style: FilledButton.styleFrom(
              backgroundColor: appleBackground,
              foregroundColor: appleForeground,
              disabledBackgroundColor: appleBackground.withValues(alpha: 0.55),
            ),
            icon: state.isSubmitting(AuthMethod.apple)
                ? ButtonSpinner(color: appleForeground)
                : const Icon(Icons.apple, size: 24),
            label: const Text("Continue with Apple"),
          ),
        ],
      ],
    );
  }
}
