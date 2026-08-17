// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:business_manager_web_ui/main.dart';

void main() {
  testWidgets('shows the business manager landing experience', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Business Manager'), findsOneWidget);
    expect(find.text('Plan smarter. Grow faster.'), findsOneWidget);
    expect(find.text('Revenue overview'), findsOneWidget);
    expect(find.text('Open dashboard'), findsOneWidget);
  });
}
