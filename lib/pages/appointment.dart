import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daktari/GlobalComponents/widgets.dart';
import 'package:daktari/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppointmentPage extends StatelessWidget {
  final String appointmentId;
  final String patientId;
  final String dateOfAppointment;
  final String typeOfConsultation;
  final String timeOfAppointment;
  final String addressOfHospital;
  final String doctorName;
  final String status;
  const AppointmentPage(
    this.appointmentId,
    this.patientId,
    this.dateOfAppointment,
    this.typeOfConsultation,
    this.timeOfAppointment,
    this.addressOfHospital,
    this.doctorName,
    this.status, {
    super.key,
  });

  DocumentReference get _doctorAppointment => FirebaseFirestore.instance
      .collection("Doctor")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("My appointments")
      .doc(appointmentId);

  DocumentReference get _patientAppointment => FirebaseFirestore.instance
      .collection("Patient")
      .doc(patientId)
      .collection("My appointments")
      .doc(appointmentId);

  Future<void> _cancel(BuildContext context) async {
    if (!await confirm(context,
        title: "Do you want to cancel the appointment?",
        confirmLabel: "Cancel appointment",
        destructive: true)) {
      return;
    }
    if (status != "Cancelled") {
      _patientAppointment.update({"Status": "Cancelled"});
    }
    _doctorAppointment.delete();
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _confirm(BuildContext context) async {
    if (!await confirm(context,
        title: "Do you want to confirm the appointment?",
        confirmLabel: "Confirm")) {
      return;
    }
    _doctorAppointment.update({"Status": "Confirmed"});
    _patientAppointment.update({"Status": "Confirmed"});
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("You have successfully confirmed the appointment")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Appointment")),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.page,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(doctorName,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                StatusChip(status),
              ],
            ),
            gapLarge,
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: const Text("Date"),
                    subtitle: Text(dateOfAppointment),
                  ),
                  ListTile(
                    leading: const Icon(Icons.schedule_outlined),
                    title: const Text("Time"),
                    subtitle: Text(timeOfAppointment),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text("Location"),
                    subtitle: Text(addressOfHospital),
                  ),
                  ListTile(
                    leading: const Icon(Icons.medical_services_outlined),
                    title: const Text("Consultation"),
                    subtitle: Text(typeOfConsultation),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (status != "Confirmed") ...[
              FilledButton(
                onPressed: () => _confirm(context),
                child: const Text("Confirm appointment"),
              ),
              gap,
            ],
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
              onPressed: () => _cancel(context),
              child: const Text("Cancel appointment"),
            ),
          ],
        ),
      ),
    );
  }
}
