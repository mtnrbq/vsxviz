// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vsxviz/main.dart';

void main() {
  testWidgets('VSXViz app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VSXVizApp());

    // Verify that our app loads with the expected UI elements.
    expect(find.text('VSXViz'), findsOneWidget);
    expect(find.text('VS Code Extension Visualizer'), findsOneWidget);
    expect(find.text('Icon support ready - models updated!'), findsOneWidget);
    
    // Verify that extension icon is present
    expect(find.byIcon(Icons.extension), findsOneWidget);
  });
}
