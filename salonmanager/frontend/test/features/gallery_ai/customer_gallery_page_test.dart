import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salonmanager/features/gallery_ai/ui/customer_gallery_page.dart';

void main() {
  group('CustomerGalleryPage', () {
    testWidgets('displays customer name in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerGalleryPage(
              customerId: 1,
              customerName: 'John Doe',
            ),
          ),
        ),
      );

      expect(find.text("John Doe's Gallery"), findsOneWidget);
    });

    testWidgets('shows filter toggle button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerGalleryPage(
              customerId: 1,
              customerName: 'John Doe',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('shows filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerGalleryPage(
              customerId: 1,
              customerName: 'John Doe',
            ),
          ),
        ),
      );

      expect(find.text('Before/After'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
    });

    testWidgets('toggles filter when chip is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerGalleryPage(
              customerId: 1,
              customerName: 'John Doe',
            ),
          ),
        ),
      );

      // Initially shows "Approved" chip
      expect(find.text('Approved'), findsOneWidget);
      
      // Tap the chip to toggle
      await tester.tap(find.text('Approved'));
      await tester.pump();
      
      // Should now show "All" chip
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerGalleryPage(
              customerId: 1,
              customerName: 'John Doe',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
