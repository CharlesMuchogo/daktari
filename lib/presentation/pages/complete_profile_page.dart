import 'package:daktari/domain/repositories/user_repository.dart';
import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/bloc/profile/profile_bloc.dart';
import 'package:daktari/presentation/pages/profile_update_listener.dart';
import 'package:daktari/presentation/theme/app_theme.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:daktari/presentation/widgets/professional_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const incompleteProfileMessage =
    "Some of your details weren't saved. Check your licence number, "
    "specialty and address, then try again.";

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(repository: context.read<UserRepository>()),
      child: const _CompleteProfileView(),
    );
  }
}

class _CompleteProfileView extends StatefulWidget {
  const _CompleteProfileView();

  @override
  State<_CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<_CompleteProfileView> {
  late final ProfessionalDetails _details;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user!;
    _details = ProfessionalDetails(
      licenseNumber: user.licenseNumber,
      hospital: user.hospital,
      categoryId: user.doctorProfile?.categoryId,
    );
  }

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  void _save() {
    if (!_details.isComplete) {
      showMessage(context, title: "Error", message: "Fill in all the details");
      return;
    }
    context.read<ProfileBloc>().add(
      ProfileUpdateSubmitted(
        ProfileUpdate(
          categoryId: _details.categoryId,
          licenseNumber: _details.licenseNumber.text,
          hospital: _details.hospital.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select(
      (ProfileBloc bloc) => bloc.state.isLoading(ProfileUpdateKind.details),
    );
    return ProfileUpdateListener(
      failureTitle: "Couldn't save your details",
      onSuccess: () {
        final saved = context.read<ProfileBloc>().state.user;
        if (saved != null && !saved.hasCompleteDoctorProfile) {
          showMessage(
            context,
            title: "Couldn't finish your profile",
            message: incompleteProfileMessage,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Complete your profile"),
          actions: [
            TextButton(
              onPressed: () =>
                  context.read<AuthBloc>().add(const LogoutRequested()),
              child: const Text("Log out"),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: AppSpacing.page,
            children: [
              Text(
                "Add your licence, specialty and where you practise. Patients "
                "find doctors by specialty and visit you at this address.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              gapLarge,
              ProfessionalFields(
                details: _details,
                onCategoryChanged: (value) =>
                    setState(() => _details.categoryId = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              LoadingButton(
                label: "Continue",
                loading: saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
