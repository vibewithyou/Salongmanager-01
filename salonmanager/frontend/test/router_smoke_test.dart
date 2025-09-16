// Minimal widget test to ensure router boot works

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salonmanager/app.dart';

void main() {
  testWidgets('App boots and renders Home route', (WidgetTester tester) async {
    await tester.pumpWidget(const SalonManagerApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}

