// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:paysats/main.dart';

void main() {
  testWidgets('PaySats app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the splash screen or initial screen loads
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Wait for any initial animations or loading
    await tester.pumpAndSettle();
    
    // The app should load without crashing
    expect(tester.takeException(), isNull);
  });
}
