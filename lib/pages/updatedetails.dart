import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daktari/GlobalComponents/widgets.dart';
import 'package:daktari/theme/app_theme.dart';
import 'package:flutter/material.dart';

class UpdateDetails extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String currentHospital;
  final String description;
  const UpdateDetails(this.userId, this.firstName, this.lastName,
      this.phoneNumber, this.currentHospital, this.description,
      {super.key});

  @override
  State<UpdateDetails> createState() => _UpdateDetailsState();
}

class _UpdateDetailsState extends State<UpdateDetails> {
  late final firstnamecontroler = TextEditingController(text: widget.firstName);
  late final lastnamecontroler = TextEditingController(text: widget.lastName);
  late final addresscontroler =
      TextEditingController(text: widget.currentHospital);
  late final phonenumbercontroler =
      TextEditingController(text: widget.phoneNumber);
  late final descriptioncontroler =
      TextEditingController(text: widget.description);

  @override
  void dispose() {
    firstnamecontroler.dispose();
    lastnamecontroler.dispose();
    addresscontroler.dispose();
    phonenumbercontroler.dispose();
    descriptioncontroler.dispose();
    super.dispose();
  }

  Future<void> updateDetails() async {
    showLoading(context);
    try {
      await FirebaseFirestore.instance
          .collection("Doctor")
          .doc(widget.userId)
          .update(
        {
          "First Name": firstnamecontroler.text,
          "Last Name": lastnamecontroler.text,
          "Current Hospital": addresscontroler.text,
          "Phone Number": phonenumbercontroler.text,
          "Description": descriptioncontroler.text
        },
      );
      if (!mounted) return;
      Navigator.pop(context); // loading dialog
      Navigator.pop(context); // this page
    } on FirebaseException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showMessage(context, title: "Error", message: e.message ?? e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update details")),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.page,
          children: [
            AppTextField(
                controller: firstnamecontroler,
                label: "First name",
                icon: Icons.person_outline),
            gap,
            AppTextField(
                controller: lastnamecontroler,
                label: "Last name",
                icon: Icons.person_outline),
            gap,
            AppTextField(
                controller: addresscontroler,
                label: "Current hospital",
                icon: Icons.location_on_outlined),
            gap,
            AppTextField(
                controller: phonenumbercontroler,
                label: "Phone number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            gap,
            AppTextField(
                controller: descriptioncontroler,
                label: "Description",
                icon: Icons.description_outlined,
                maxLines: 4,
                textInputAction: TextInputAction.newline),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
                onPressed: updateDetails, child: const Text("Save details")),
          ],
        ),
      ),
    );
  }
}
