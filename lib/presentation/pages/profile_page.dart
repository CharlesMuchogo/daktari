import 'package:daktari/domain/repositories/user_repository.dart';
import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/bloc/profile/profile_bloc.dart';
import 'package:daktari/presentation/pages/edit_profile_page.dart';
import 'package:daktari/presentation/pages/profile_update_listener.dart';
import 'package:daktari/presentation/theme/app_theme.dart';
import 'package:daktari/presentation/theme/theme_mode_selector.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(repository: context.read<UserRepository>()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final bloc = context.read<ProfileBloc>();
    final scheme = Theme.of(context).colorScheme;
    final picture = await ImagePicker().pickImage(source: source);
    if (picture == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picture.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      maxHeight: 700,
      maxWidth: 700,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop photo",
          toolbarColor: scheme.primary,
          toolbarWidgetColor: scheme.onPrimary,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: "Crop photo", aspectRatioLockEnabled: true),
      ],
    );
    if (cropped == null) return;
    bloc.add(ProfileUpdateSubmitted(ProfileUpdate(photoPath: cropped.path)));
  }

  void _chooseImageSource(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (source, icon, label) in [
                (ImageSource.gallery, Icons.photo_library_outlined, "Gallery"),
                (ImageSource.camera, Icons.photo_camera_outlined, "Camera"),
              ])
                ListTile(
                  leading: Icon(icon),
                  title: Text(label),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(context, source);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await confirm(
      context,
      title: "Do you want to log out?",
      confirmLabel: "Log out",
      destructive: true,
    );
    if (ok && context.mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    final uploading = context.select(
      (ProfileBloc bloc) => bloc.state.isLoading(ProfileUpdateKind.photo),
    );
    if (user == null) return const Scaffold(body: Loading());
    final theme = Theme.of(context);

    return ProfileUpdateListener(
      failureTitle: "Upload failed",
      child: Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: ListView(
          padding: AppSpacing.page,
          children: [
            Center(
              child: Stack(
                children: [
                  PersonAvatar(user.profilePhoto, radius: 64),
                  if (uploading)
                    const Positioned.fill(
                      child: CircleAvatar(
                        backgroundColor: Colors.black38,
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton.filled(
                      icon: const Icon(Icons.camera_alt_outlined),
                      onPressed: uploading
                          ? null
                          : () => _chooseImageSource(context),
                    ),
                  ),
                ],
              ),
            ),
            gap,
            Text(
              user.displayName,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (user.specialty.isNotEmpty)
              Text(
                user.specialty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            gapLarge,
            Row(
              children: [
                const Expanded(child: SectionTitle("User information")),
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text("Edit"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => EditProfilePage(user: user),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  for (final (title, value, icon) in [
                    ("Email", user.email, Icons.email_outlined),
                    (
                      "Hospital or clinic address",
                      user.hospital,
                      Icons.location_on_outlined,
                    ),
                    ("Phone number", user.phoneNumber, Icons.phone_outlined),
                    (
                      "Licence number",
                      user.licenseNumber,
                      Icons.badge_outlined,
                    ),
                    ("About", user.about, Icons.description_outlined),
                  ])
                    ListTile(
                      leading: Icon(icon),
                      title: Text(title),
                      subtitle: Text(value.isEmpty ? "—" : value),
                    ),
                ],
              ),
            ),
            gapLarge,
            const SectionTitle("Appearance"),
            const SizedBox(height: AppSpacing.sm),
            const Card(
              child: Padding(
                padding: AppSpacing.card,
                child: ThemeModeSelector(),
              ),
            ),
            gapLarge,
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.logout_outlined,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  "Log out",
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
