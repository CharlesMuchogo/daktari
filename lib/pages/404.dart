// ignore_for_file: camel_case_types

import 'package:daktari/GlobalComponents/authenticationservice.dart';
import 'package:daktari/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../GlobalComponents/autheticationwrapper.dart';
import '../GlobalComponents/widgets.dart';

class Not_Authorized extends StatelessWidget {
  const Not_Authorized({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const EmptyState(
                icon: Icons.lock_person_outlined,
                message:
                    "Oops… you are not authorized to continue.\nPlease log out and use the right credentials.",
              ),
              gapLarge,
              FilledButton(
                onPressed: () async {
                  await context.read<AuthenticationService>().signOut();
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AuthenticationWrapper()));
                },
                child: const Text("Log out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
