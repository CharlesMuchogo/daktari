import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/bloc/profile/profile_bloc.dart';
import 'package:daktari/presentation/bloc/status.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileUpdateListener extends StatelessWidget {
  const ProfileUpdateListener({
    super.key,
    required this.failureTitle,
    required this.child,
    this.onSuccess,
  });

  final String failureTitle;
  final VoidCallback? onSuccess;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final user = state.user;
        if (state.status == Status.loaded && user != null) {
          context.read<AuthBloc>().add(AuthUserChanged(user));
          onSuccess?.call();
        } else if (state.status.isFailure) {
          showMessage(context, title: failureTitle, message: state.message);
        }
      },
      child: child,
    );
  }
}
