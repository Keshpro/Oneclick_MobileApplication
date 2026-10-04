import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oneclick/features/drunk_drive/passenger/screens/drunk_drive_home_screen.dart';

void main() {
  testWidgets('DrunkDriveHomeScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DrunkDriveHomeScreen(),
      ),
    );

    expect(find.text('Drunk & Drive'), findsOneWidget);
    expect(find.text('Book a Driver'), findsOneWidget);
    expect(find.text('My Vehicles'), findsOneWidget);
  });
}
