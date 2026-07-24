import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zone/features/shell/main_shell.dart';

void main() {
  testWidgets('shows Map tab content by default and switches on tap', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));

    expect(find.text('Map — coming in the next slice'), findsOneWidget);
    expect(find.text('Feed — coming in the next slice'), findsNothing);

    await tester.tap(find.text('Feed'));
    await tester.pumpAndSettle();

    expect(find.text('Feed — coming in the next slice'), findsOneWidget);
    expect(find.text('Map — coming in the next slice'), findsNothing);
  });

  testWidgets('all four tab labels are present', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));

    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
