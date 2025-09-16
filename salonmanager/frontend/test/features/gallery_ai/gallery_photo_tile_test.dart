import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salonmanager/features/gallery_ai/models/gallery_photo.dart';
import 'package:salonmanager/features/gallery_ai/ui/gallery_photo_tile.dart';

void main() {
  group('GalleryPhotoTile', () {
    late GalleryPhoto mockPhoto;

    setUp(() {
      mockPhoto = GalleryPhoto(
        id: 1,
        salonId: 1,
        path: 'test/path.jpg',
        createdBy: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        albumTitle: 'Test Album',
        albumVisibility: 'public',
      );
    });

    testWidgets('displays photo with correct image', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GalleryPhotoTile(photo: mockPhoto),
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays album title when available', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GalleryPhotoTile(photo: mockPhoto),
            ),
          ),
        ),
      );

      expect(find.text('Test Album'), findsOneWidget);
    });

    testWidgets('shows like and favorite buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GalleryPhotoTile(photo: mockPhoto),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('shows book from photo button when callback provided', (WidgetTester tester) async {
      bool callbackCalled = false;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GalleryPhotoTile(
                photo: mockPhoto,
                onBookFromPhoto: () {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.calendar_today));
      expect(callbackCalled, isTrue);
    });

    testWidgets('handles tap on photo', (WidgetTester tester) async {
      bool tapCalled = false;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GalleryPhotoTile(
                photo: mockPhoto,
                onTap: () {
                  tapCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapCalled, isTrue);
    });
  });
}
