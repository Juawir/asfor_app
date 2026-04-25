import 'package:flutter_test/flutter_test.dart';
import 'package:asfor_app/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const AsforApp());
    expect(find.text('Dashboard ASFOR'), findsOneWidget);
  });
}
