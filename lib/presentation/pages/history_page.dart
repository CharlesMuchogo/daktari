import 'package:daktari/presentation/widgets/appointment_list.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Treatment history")),
      body: AppointmentList(
        select: (state) => state.historyAt(DateTime.now()),
        emptyIcon: Icons.history,
        emptyMessage: "Your treatment history will appear here",
      ),
    );
  }
}
