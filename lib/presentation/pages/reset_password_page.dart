import 'package:daktari/domain/repositories/auth_repository.dart';
import 'package:daktari/presentation/bloc/password_reset/password_reset_bloc.dart';
import 'package:daktari/presentation/theme/app_theme.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PasswordResetBloc(repository: context.read<AuthRepository>()),
      child: const _ResetPasswordView(),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView();

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_email, _code, _password, _confirmPassword]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _requestCode() {
    if (_email.text.trim().isEmpty) {
      showMessage(context, title: "Error", message: "Enter your email.");
      return;
    }
    context.read<PasswordResetBloc>().add(
      PasswordResetCodeRequested(_email.text),
    );
  }

  void _reset() {
    if (_code.text.trim().isEmpty || _password.text.isEmpty) {
      showMessage(
        context,
        title: "Error",
        message: "Enter the code from your email and a new password.",
      );
      return;
    }
    if (_password.text != _confirmPassword.text) {
      showMessage(context, title: "Error", message: "Passwords do not match");
      return;
    }
    context.read<PasswordResetBloc>().add(
      PasswordResetSubmitted(code: _code.text, newPassword: _password.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<PasswordResetBloc, PasswordResetState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isFailure) {
          showMessage(context, title: "Failed", message: state.message);
        } else if (state.step == PasswordResetStep.done) {
          showSnack(context, "Password reset. Log in with your new password.");
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final loading = state.status.isLoading;
        final codeStep = state.step != PasswordResetStep.email;
        return Scaffold(
          appBar: AppBar(title: const Text("Reset password")),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    codeStep
                        ? "We sent a 6-digit code to ${state.email}. If you "
                              "don't see it in your inbox, check your spam folder."
                        : "Enter the email linked to your account and we'll "
                              "send you a code to reset your password.",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  gapLarge,
                  if (!codeStep) ...[
                    AppTextField(
                      controller: _email,
                      label: "Email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _requestCode(),
                    ),
                    gapLarge,
                    LoadingButton(
                      label: "Send reset code",
                      loading: loading,
                      onPressed: _requestCode,
                    ),
                  ] else ...[
                    AppTextField(
                      controller: _code,
                      label: "Reset code",
                      icon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    gap,
                    AppTextField(
                      controller: _password,
                      label: "New password",
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),
                    gap,
                    AppTextField(
                      controller: _confirmPassword,
                      label: "Confirm new password",
                      icon: Icons.lock_outline,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _reset(),
                    ),
                    gapLarge,
                    LoadingButton(
                      label: "Reset password",
                      loading: loading,
                      onPressed: _reset,
                    ),
                    TextButton(
                      onPressed: loading ? null : _requestCode,
                      child: const Text("Send a new code"),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
