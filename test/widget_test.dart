import 'package:flutter_test/flutter_test.dart';
import 'package:eventia/app/app.dart';

void main() {
  testWidgets('Eventia app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const EventiaApp());
    expect(find.text('Eventia'), findsWidgets);
  });
}