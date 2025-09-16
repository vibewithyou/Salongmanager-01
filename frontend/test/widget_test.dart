import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salonmanager/app.dart';
import 'package:salonmanager/common/ui/sm_button.dart';
import 'package:salonmanager/common/ui/sm_input.dart';
import 'package:salonmanager/common/ui/sm_card.dart';

void main() {
  group('UI Component Tests', () {
    testWidgets('SMPrimaryButton renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SMPrimaryButton(
                onPressed: null,
                child: Text('Test Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('SMPrimaryButton with loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SMPrimaryButton(
                onPressed: null,
                isLoading: true,
                child: Text('Test Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('SMInput renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SMInput(
                label: 'Test Input',
                hint: 'Enter text',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Input'), findsOneWidget);
      expect(find.text('Enter text'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('SMInput with required field shows asterisk', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SMInput(
                label: 'Required Field',
                required: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Required Field *'), findsOneWidget);
    });

    testWidgets('SMCard renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SMCard(
                child: Text('Card Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('SMCard with onTap is tappable', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SMCard(
                onTap: () => tapped = true,
                child: Text('Tappable Card'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tappable Card'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('App Integration Tests', () {
    testWidgets('App starts and shows dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: SalonManagerApp(),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Check if the app bar is present
      expect(find.byType(AppBar), findsOneWidget);
      
      // Check if the main content area is present
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
