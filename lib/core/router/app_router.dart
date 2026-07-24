import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/shell/placeholder_tab.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
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
