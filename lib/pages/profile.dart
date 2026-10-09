// ignore_for_file: camel_case_types

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daktari/GlobalComponents/authenticationservice.dart';
import 'package:daktari/GlobalComponents/widgets.dart';
import 'package:daktari/pages/updatedetails.dart';
import 'package:daktari/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  Future<void> _pickImage(
      String imagename, ImageSource source, String? specialty) async {
    final pictureFile = await ImagePicker().pickImage(source: source);
    if (pictureFile == null || !mounted) return;

    final croppedImage = await ImageCropper().cropImage(
      sourcePath: pictureFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: "Crop photo",
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
            lockAspectRatio: true),
        IOSUiSettings(title: "Crop photo", aspectRatioLockEnabled: true),
      ],
      compressQuality: 100,
      maxHeight: 700,
      maxWidth: 700,
      compressFormat: ImageCompressFormat.jpg,
    );
    if (croppedImage == null || !mounted) return;

    showLoading(context);
    try {
      //Upload to Firebase
      final snapshot = await FirebaseStorage.instance
          .ref()
          .child('images/{$imagename}')
          .putFile(File(croppedImage.path));
      final imageUrl = await snapshot.ref.getDownloadURL();
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection("Doctor")
          .doc(uid)
          .update({"Profile Photo": imageUrl});

      if (specialty != null) {
        await FirebaseFirestore.instance
            .collection("Doctor Cartegories")
            .doc(specialty)
            .collection("Doctors")
            .doc(uid)
            .update({"Profile Photo": imageUrl})
            .catchError((_) {});
      }
      if (mounted) Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showMessage(context, title: "Upload failed", message: e.message ?? e.code);
    }
  }

  void _chooseImageSource(String imageName, String? specialty) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(imageName, ImageSource.gallery, specialty);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(imageName, ImageSource.camera, specialty);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    final auth = context.read<AuthenticationService>();
    if (await confirm(context,
        title: "Do you want to log out?",
        confirmLabel: "Log out",
        destructive: true)) {
      await auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("Doctor")
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data();
            if (data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            String field(String key) => (data[key] ?? "").toString();

            return ListView(
              padding: AppSpacing.page,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage(field("Profile Photo")),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filled(
                          icon: const Icon(Icons.camera_alt_outlined),
                          onPressed: () => _chooseImageSource(
                              field("Email"), data["specialty"]),
                        ),
                      ),
                    ],
                  ),
                ),
                gap,
                Text(
                  "${field("First Name")} ${field("Last Name")}",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (field("specialty").isNotEmpty)
                  Text(
                    field("specialty"),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
                        MaterialPageRoute(
                          builder: (_) => UpdateDetails(
                              FirebaseAuth.instance.currentUser!.uid,
                              field("First Name"),
                              field("Last Name"),
                              field("Phone Number"),
                              field("Current Hospital"),
                              field("Description")),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Column(
                    children: [
                      _infoTile("Email", field("Email"), Icons.email_outlined),
                      _infoTile("Current hospital", field("Current Hospital"),
                          Icons.location_on_outlined),
                      _infoTile("Phone number", field("Phone Number"),
                          Icons.phone_outlined),
                      _infoTile("Description", field("Description"),
                          Icons.description_outlined),
                    ],
                  ),
                ),
                gapLarge,
                Card(
                  child: ListTile(
                    leading:
                        Icon(Icons.logout_outlined, color: theme.colorScheme.error),
                    title: Text("Log out",
                        style: TextStyle(color: theme.colorScheme.error)),
                    onTap: _signOut,
                  ),
                ),
              ],
            );
          }),
    );
  }
}

Widget _infoTile(String title, String subTitle, IconData icondata) {
  return ListTile(
    leading: Icon(icondata),
    title: Text(title),
    subtitle: Text(subTitle.isEmpty ? "—" : subTitle),
  );
}
