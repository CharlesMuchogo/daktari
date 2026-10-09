import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daktari/GlobalComponents/widgets.dart';
import 'package:daktari/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpcomingAppointments extends StatelessWidget {
  const UpcomingAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Doctor")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("My appointments")
            .orderBy("Date", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const EmptyState(
                icon: Icons.error_outline,
                message: "An error occurred. Please try again later.");
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const EmptyState(
                icon: Icons.event_available_outlined,
                message: "You do not have any upcoming appointments");
          }

          return ListView.separated(
            padding: AppSpacing.page,
            itemCount: docs.length,
            separatorBuilder: (_, _) => gap,
            itemBuilder: (context, index) => AppointmentCard(docs[index]),
          );
        });
  }
}
