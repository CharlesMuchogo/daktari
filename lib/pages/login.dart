// ignore_for_file: camel_case_types

import 'package:daktari/GlobalComponents/authenticationservice.dart';
import 'package:daktari/GlobalComponents/widgets.dart';
import 'package:daktari/pages/resetpassword.dart';
import 'package:daktari/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:daktari/pages/signup.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    showLoading(context);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.toLowerCase().trim(),
          password: _password.text.trim());
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showMessage(context, title: "Error", message: e.message ?? e.code);
    }
  }

  Future<void> _loginWithGoogle() async {
    final auth = context.read<AuthenticationService>();
    showLoading(context);
    try {
      await auth.signInWithGoogle();
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showMessage(context, title: "Error", message: e.message ?? e.code);
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showMessage(context,
          title: "Google sign-in failed", message: e.description ?? e.code.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ResetPassword()),
                      ),
                      child: const Text("Forgot password?"),
                    ),
                  ),
                  gap,
                  FilledButton(onPressed: _login, child: const Text("Log in")),
                  gapLarge,
                  const OrDivider(),
                  gapLarge,
                  GoogleSignInButton(onPressed: _loginWithGoogle),
                  gapLarge,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?",
                          style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Signup()),
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
    );
  }
}
