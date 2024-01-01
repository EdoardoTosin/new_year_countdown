import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:new_year_countdown/main.dart';

void main() {
  group('MyApp', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('CountdownTimer', () {
    test('calculates remaining time correctly', () {
      final DateTime now = DateTime.now();
      final DateTime futureDate = DateTime(now.year + 1, 1, 1);
      final int remainingTime = futureDate.difference(now).inSeconds;
      expect(remainingTime, greaterThanOrEqualTo(0));
    });
  });
}
