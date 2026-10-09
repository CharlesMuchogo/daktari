// ignore_for_file: camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daktari/GlobalComponents/widgets.dart';
import 'package:daktari/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '404.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    checkDocument(_uid, context);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: theme.colorScheme.primary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: AppSpacing.page.copyWith(bottom: AppSpacing.xl),
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection("Doctor")
                        .doc(_uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final String? firstName =
                          snapshot.data?.data()?["First Name"];
                      final onPrimary = theme.colorScheme.onPrimary;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: theme.textTheme.titleMedium?.copyWith(
                                color: onPrimary.withValues(alpha: 0.8)),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            firstName == null ? "Doctor" : "Dr. $firstName",
                            style: theme.textTheme.headlineMedium?.copyWith(
                                color: onPrimary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: AppSpacing.page,
            sliver: SliverToBoxAdapter(
              child: Text("Upcoming appointments",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Doctor")
                .doc(_uid)
                .collection("My appointments")
                .orderBy("Date", descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                      icon: Icons.error_outline,
                      message: "An error occurred. Please try again later."),
                );
              }
              if (!snapshot.hasData) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                      icon: Icons.event_available_outlined,
                      message: "You do not have any upcoming appointments"),
                );
              }
              return SliverPadding(
                padding: AppSpacing.page.copyWith(top: 0),
                sliver: SliverList.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => gap,
                  itemBuilder: (context, index) => AppointmentCard(docs[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Sends the user to [Not_Authorized] if they have no "Doctor" profile.
Future<void> checkDocument(String uid, BuildContext context) async {
  final documentSnapshot =
      await FirebaseFirestore.instance.collection("Doctor").doc(uid).get();

  if (!documentSnapshot.exists && context.mounted) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const Not_Authorized()));
  }
}
