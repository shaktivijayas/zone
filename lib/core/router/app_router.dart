import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/shell/placeholder_tab.dart';
import '../../features/map/map_screen.dart';
import '../../features/feed/feed_screen.dart';
import '../../features/community/community_screen.dart';

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
            GoRoute(path: '/home/map', builder: (context, state) => const MapScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home/feed', builder: (context, state) => const FeedScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home/community', builder: (context, state) => const CommunityScreen()),
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
