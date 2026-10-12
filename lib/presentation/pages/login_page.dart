import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/pages/auth_listener.dart';
import 'package:daktari/presentation/pages/reset_password_page.dart';
import 'package:daktari/presentation/pages/signup_page.dart';
import 'package:daktari/presentation/theme/app_theme.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:daktari/presentation/widgets/social_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() => context.read<AuthBloc>().add(
    LoginRequested(email: _email.text, password: _password.text),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final submitting = context.select(
      (AuthBloc bloc) => bloc.state.isSubmitting(AuthMethod.email),
    );
    return AuthFailureListener(
      title: "Couldn't log in",
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.page,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(subtitle: "Health Is Wealth"),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      controller: _email,
                      label: "Email address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    gap,
                    AppTextField(
                      controller: _password,
                      label: "Password",
                      icon: Icons.lock_outline,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const ResetPasswordPage(),
                          ),
                        ),
                        child: const Text("Forgot password?"),
                      ),
                    ),
                    gap,
                    LoadingButton(
                      label: "Log in",
                      loading: submitting,
                      onPressed: _login,
                    ),
                    gapLarge,
                    const OrDivider(),
                    gapLarge,
                    const SocialSignInButtons(),
                    gapLarge,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const SignupPage(),
                            ),
                          ),
                          child: const Text("Sign up"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
