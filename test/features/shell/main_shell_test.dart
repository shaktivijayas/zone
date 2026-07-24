import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zone/features/shell/main_shell.dart';
import 'package:zone/features/shell/placeholder_tab.dart';

void main() {
  GoRouter buildTestRouter() {
    return GoRouter(
      initialLocation: '/home/map',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/home/map', builder: (context, state) => const PlaceholderTab(label: 'Map')),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/home/feed', builder: (context, state) => const PlaceholderTab(label: 'Feed')),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/home/community', builder: (context, state) => const PlaceholderTab(label: 'Community')),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/home/profile', builder: (context, state) => const PlaceholderTab(label: 'Profile')),
              ],
            ),
          ],
        ),
      ],
    );
  }

  testWidgets('shows Map tab content by default and switches on tap', (tester) async {
    final router = buildTestRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Map — coming in the next slice'), findsOneWidget);
    expect(find.text('Feed — coming in the next slice'), findsNothing);

    await tester.tap(find.text('Feed'));
    await tester.pumpAndSettle();

    expect(find.text('Feed — coming in the next slice'), findsOneWidget);
    expect(find.text('Map — coming in the next slice'), findsNothing);
  });

  testWidgets('all four tab labels are present', (tester) async {
    final router = buildTestRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
