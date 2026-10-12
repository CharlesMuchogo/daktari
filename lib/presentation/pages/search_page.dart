import 'package:daktari/presentation/theme/app_theme.dart';
import 'package:daktari/presentation/widgets/appointment_card.dart';
import 'package:daktari/presentation/widgets/appointment_list.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
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
              controller: _query,
              hintText: "Search by patient, date, time, status…",
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: AppointmentList(
              select: (state) =>
                  state.matching(_query.text, appointmentSearchText),
              emptyIcon: Icons.search_off,
              emptyMessage: "No results found for your search",
            ),
          ),
        ],
      ),
    );
  }
}
