import 'package:flutter_test/flutter_test.dart';
import 'package:salonmanager/app.dart';

void main() {
  testWidgets('app boots & draws home', (tester) async {
    await tester.pumpWidget(const AppRoot());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('Salon'), findsWidgets);
  });
}
