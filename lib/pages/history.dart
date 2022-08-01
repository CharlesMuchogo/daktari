// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';

class History extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Treatment History"),
      ),
      body: Center(
        child: Text(
          "Your treatment history will appear here",
        ),
      ),
    );
  }
}
