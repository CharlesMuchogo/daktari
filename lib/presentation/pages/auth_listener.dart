import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthFailureListener extends StatelessWidget {
  const AuthFailureListener({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.action != current.action && current.action.isFailure,
      listener: (context, state) =>
          showMessage(context, title: title, message: state.message),
      child: child,
    );
  }
}
