// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_chronicles/main.dart';

void main() {
  testWidgets('App renders attribute setup', (WidgetTester tester) async {
    await tester.pumpWidget(const LifeSimApp());
    expect(find.text('属性分配'), findsOneWidget);
    expect(find.text('开始人生'), findsOneWidget);
  });
}
