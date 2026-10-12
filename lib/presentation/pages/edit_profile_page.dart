import 'package:daktari/domain/entities/user.dart';
import 'package:daktari/domain/repositories/user_repository.dart';
import 'package:daktari/presentation/bloc/profile/profile_bloc.dart';
import 'package:daktari/presentation/pages/profile_update_listener.dart';
import 'package:daktari/presentation/theme/app_theme.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:daktari/presentation/widgets/professional_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(repository: context.read<UserRepository>()),
      child: _EditProfileView(user: user),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView({required this.user});

  final User user;

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  late final _firstName = TextEditingController(text: widget.user.firstName);
  late final _lastName = TextEditingController(text: widget.user.lastName);
  late final _phone = TextEditingController(text: widget.user.phoneNumber);
  late final _professional = ProfessionalDetails(
    licenseNumber: widget.user.licenseNumber,
    hospital: widget.user.hospital,
    description: widget.user.about,
    categoryId: widget.user.doctorProfile?.categoryId,
  );

  @override
  void dispose() {
    for (final controller in [_firstName, _lastName, _phone]) {
      controller.dispose();
    }
    _professional.dispose();
    super.dispose();
  }

  void _save() {
    if (_firstName.text.trim().isEmpty ||
        _lastName.text.trim().isEmpty ||
        !_professional.isComplete) {
      showMessage(context, title: "Error", message: "Fill in all the details");
      return;
    }
    context.read<ProfileBloc>().add(
      ProfileUpdateSubmitted(
        ProfileUpdate(
          firstName: _firstName.text,
          lastName: _lastName.text,
          phoneNumber: _phone.text,
          categoryId: _professional.categoryId,
          licenseNumber: _professional.licenseNumber.text,
          hospital: _professional.hospital.text,
          description: _professional.description.text,
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
      failureTitle: "Error",
      onSuccess: () {
        showSnack(context, "Your details were updated");
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Update details")),
        body: SafeArea(
          child: ListView(
            padding: AppSpacing.page,
            children: [
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
                controller: _phone,
                label: "Phone number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              gapLarge,
              const SectionTitle("Professional details"),
              gap,
              ProfessionalFields(
                details: _professional,
                showDescription: true,
                onCategoryChanged: (value) =>
                    setState(() => _professional.categoryId = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              LoadingButton(
                label: "Save details",
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
