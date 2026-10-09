import 'package:daktari/GlobalComponents/widgets.dart';
import 'package:flutter/material.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Treatment history")),
      body: const EmptyState(
        icon: Icons.history,
        message: "Your treatment history will appear here",
      ),
    );
  }
}
