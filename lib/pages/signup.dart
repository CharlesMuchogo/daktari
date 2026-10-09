import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:daktari/GlobalComponents/authenticationservice.dart';
import 'package:daktari/GlobalComponents/restapi.dart';
import 'package:daktari/GlobalComponents/widgets.dart';
import 'package:daktari/theme/app_theme.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String? selectedCategory;
  final firstNamecontroler = TextEditingController();
  final lastNamecontroler = TextEditingController();
  final emailcontroler = TextEditingController();
  final phoneNumbercontroler = TextEditingController();
  final passwordcontroler = TextEditingController();
  final confirmpasswordcontroler = TextEditingController();
  final licensenumbercontroler = TextEditingController();
  final currentHospitalcontroler = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      firstNamecontroler,
      lastNamecontroler,
      emailcontroler,
      phoneNumbercontroler,
      passwordcontroler,
      confirmpasswordcontroler,
      licensenumbercontroler,
      currentHospitalcontroler,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _input() async {
    if (firstNamecontroler.text.trim().isEmpty ||
        lastNamecontroler.text.trim().isEmpty ||
        emailcontroler.text.trim().isEmpty ||
        phoneNumbercontroler.text.trim().isEmpty ||
        passwordcontroler.text.trim().isEmpty ||
        confirmpasswordcontroler.text.trim().isEmpty ||
        licensenumbercontroler.text.trim().isEmpty ||
        currentHospitalcontroler.text.isEmpty ||
        selectedCategory == null) {
      showMessage(context, title: "Error", message: "Fill in all the details");
      return;
    }
    if (passwordcontroler.text != confirmpasswordcontroler.text) {
      showMessage(context, title: "Error", message: "Passwords do not match");
      return;
    }

    showLoading(context);
    final result = await context.read<AuthenticationService>().signUp(
        email: emailcontroler.text.toLowerCase().trim(),
        password: passwordcontroler.text.trim());
    if (!mounted) return;
    if (result != 'Sign up successful') {
      Navigator.pop(context);
      showMessage(context, title: "Error", message: result);
      return;
    }

    await RestApi().createData(
        firstNamecontroler.text.trim(),
        lastNamecontroler.text.trim(),
        emailcontroler.text.trim(),
        phoneNumbercontroler.text,
        licensenumbercontroler.text.trim(),
        currentHospitalcontroler.text,
        selectedCategory!);

    if (!mounted) return;
    Navigator.pop(context); // loading dialog
    Navigator.pop(context); // signup page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      controller: firstNamecontroler,
                      label: "First name",
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name),
                  gap,
                  AppTextField(
                      controller: lastNamecontroler,
                      label: "Last name",
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name),
                  gap,
                  AppTextField(
                      controller: emailcontroler,
                      label: "Email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress),
                  gap,
                  AppTextField(
                      controller: phoneNumbercontroler,
                      label: "Phone number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone),
                  gapLarge,
                  const SectionTitle("Professional details"),
                  gap,
                  AppTextField(
                      controller: licensenumbercontroler,
                      label: "Licence number",
                      icon: Icons.badge_outlined),
                  gap,
                  AppTextField(
                      controller: currentHospitalcontroler,
                      label: "Current hospital",
                      icon: Icons.local_hospital_outlined),
                  gap,
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("Doctor Categoty")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      return DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: "Specialty",
                          prefixIcon: Icon(Icons.medical_services_outlined),
                        ),
                        items: [
                          for (final doc in snapshot.data!.docs)
                            DropdownMenuItem(
                                value: doc.id, child: Text(doc.id)),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedCategory = value),
                      );
                    },
                  ),
                  gapLarge,
                  const SectionTitle("Security"),
                  gap,
                  AppTextField(
                      controller: passwordcontroler,
                      label: "Create password",
                      icon: Icons.lock_outline,
                      obscure: true),
                  gap,
                  AppTextField(
                      controller: confirmpasswordcontroler,
                      label: "Confirm password",
                      icon: Icons.lock_outline,
                      obscure: true,
                      textInputAction: TextInputAction.done),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(onPressed: _input, child: const Text("Sign up")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
