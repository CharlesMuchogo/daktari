import 'package:daktari/domain/repositories/auth_repository.dart';
import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/pages/auth_listener.dart';
import 'package:daktari/presentation/theme/app_theme.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  List<TextEditingController> get _accountFields => [
    _firstName,
    _lastName,
    _email,
    _phone,
    _password,
    _confirmPassword,
  ];

  @override
  void dispose() {
    for (final controller in _accountFields) {
      controller.dispose();
    }
    super.dispose();
  }

  void _signUp() {
    if (_accountFields.any((c) => c.text.trim().isEmpty)) {
      showMessage(context, title: "Error", message: "Fill in all the details");
      return;
    }
    if (_password.text != _confirmPassword.text) {
      showMessage(context, title: "Error", message: "Passwords do not match");
      return;
    }
    context.read<AuthBloc>().add(
      RegisterRequested(
        Registration(
          firstName: _firstName.text,
          lastName: _lastName.text,
          email: _email.text,
          phoneNumber: _phone.text,
          password: _password.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.select(
      (AuthBloc bloc) => bloc.state.isSubmitting(AuthMethod.email),
    );
    return AuthFailureListener(
      title: "Couldn't sign up",
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.page,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(subtitle: "Create your doctor account"),
                    const SizedBox(height: AppSpacing.xl),
                    const SectionTitle("Personal details"),
                    gap,
                    AppTextField(
                      controller: _firstName,
                      label: "First name",
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                    ),
                    gap,
                    AppTextField(
                      controller: _lastName,
                      label: "Last name",
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                    ),
                    gap,
                    AppTextField(
                      controller: _email,
                      label: "Email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    gap,
                    AppTextField(
                      controller: _phone,
                      label: "Phone number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    gapLarge,
                    const SectionTitle("Security"),
                    gap,
                    AppTextField(
                      controller: _password,
                      label: "Create password",
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),
                    gap,
                    AppTextField(
                      controller: _confirmPassword,
                      label: "Confirm password",
                      icon: Icons.lock_outline,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    LoadingButton(
                      label: "Sign up",
                      loading: submitting,
                      onPressed: _signUp,
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
