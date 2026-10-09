import 'package:daktari/GlobalComponents/widgets.dart';
import 'package:daktari/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final resetPassword = TextEditingController();

  @override
  void dispose() {
    resetPassword.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: resetPassword.text.trim());
      if (!mounted) return;
      showMessage(
        context,
        title: "Check your email",
        message:
            "A password reset email has been sent. If you don't see it in your inbox, check your spam folder.",
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showMessage(context, title: "Failed", message: e.message ?? e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Reset password")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Enter the email linked to your account and we'll send you a link to reset your password.",
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              gapLarge,
              AppTextField(
                controller: resetPassword,
                label: "Email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),
              gapLarge,
              FilledButton(
                onPressed: _resetPassword,
                child: const Text("Send reset link"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
