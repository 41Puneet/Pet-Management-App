 import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_health_tracker/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app builds without errors
    expect(find.text('Pet Health Tracker - Starter Project'), findsOneWidget);
  });
}
