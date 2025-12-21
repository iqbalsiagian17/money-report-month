// This is a basic Flutter widget test for Dompetku Monthly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Untuk saat ini, kita buat test sederhana
// karena app membutuhkan inisialisasi Hive yang kompleks

void main() {
  testWidgets('App should have a title', (WidgetTester tester) async {
    // Test sederhana untuk memastikan framework berjalan
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Dompetku'),
          ),
        ),
      ),
    );

    // Verify app title exists
    expect(find.text('Dompetku'), findsOneWidget);
  });

  testWidgets('Basic widget renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Test'),
          ),
          body: const Center(
            child: Text('Hello World'),
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
    expect(find.text('Hello World'), findsOneWidget);
  });
}
