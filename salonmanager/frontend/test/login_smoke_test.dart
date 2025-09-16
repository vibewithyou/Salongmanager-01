import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salonmanager/app.dart';

void main() {
  testWidgets('renders app without crash', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SalonManagerApp()));
    expect(find.text('SalonManager'), findsOneWidget);
  });
}