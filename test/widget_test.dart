import 'package:daktari/GlobalComponents/widgets.dart';
import 'package:daktari/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('password field toggles visibility', (WidgetTester tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: AppTextField(
            controller: controller, label: "Password", obscure: true),
      ),
    ));

    EditableText field() => tester.widget(find.byType(EditableText));
    expect(field().obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(field().obscureText, isFalse);
  });

  testWidgets('status chip shows status', (WidgetTester tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StatusChip("Pending"))));
    expect(find.text("Pending"), findsOneWidget);
  });
}
