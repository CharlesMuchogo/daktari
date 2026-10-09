import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daktari/GlobalComponents/widgets.dart';
import 'package:daktari/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final searchdoctorcontroler = TextEditingController();

  @override
  void dispose() {
    searchdoctorcontroler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search appointments")),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.page.copyWith(top: AppSpacing.sm),
            child: SearchBar(
              controller: searchdoctorcontroler,
              hintText: "Search by date, time, status…",
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: AppSpacing.md)),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(child: searchinfo(searchdoctorcontroler.text)),
        ],
      ),
    );
  }
}

Widget searchinfo(String query) {
  return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Doctor")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("My appointments")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const EmptyState(
              icon: Icons.error_outline,
              message: "Oops, an error occurred. Please try again.");
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data!.docs
            .where((doc) => doc
                .data()
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
        if (results.isEmpty) {
          return const EmptyState(
              icon: Icons.search_off,
              message: "No results found for your search");
        }

        return ListView.separated(
          padding: AppSpacing.page.copyWith(top: 0),
          itemCount: results.length,
          separatorBuilder: (_, _) => gap,
          itemBuilder: (context, index) => AppointmentCard(results[index]),
        );
      });
}
