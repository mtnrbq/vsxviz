// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:vsxviz/main.dart';

void main() {
  testWidgets('VSXViz app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VSXVizApp());

    // Verify that our app loads with the expected UI elements.
    expect(find.text('VSXViz'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets); // Multiple instances expected (nav + appbar)
    expect(find.text('Profiles'), findsOneWidget);
    expect(find.text('Extensions'), findsOneWidget);

    // Verify that the Dashboard screen is shown by default
    expect(find.text('VS Code Extension Overview'), findsOneWidget);
    
    // Test navigation to Profiles screen
    await tester.tap(find.text('Profiles'));
    await tester.pump();
    expect(find.text('VS Code Profiles'), findsOneWidget);
  });
}
