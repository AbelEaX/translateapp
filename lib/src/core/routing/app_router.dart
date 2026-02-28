import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/translation/presentation/screens/app_shell.dart';
import '../../features/translation/presentation/widgets/community_feed.dart';
import '../../features/translation/presentation/widgets/submission_form.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter router(Stream<User?> authStateStream) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authStateStream),
      redirect: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        final isLoggedIn = user != null;
        final isLoggingIn = state.uri.toString() == '/login';

        if (!isLoggedIn && !isLoggingIn) return '/login';
        if (isLoggedIn && isLoggingIn) return '/';

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const OnboardingScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const CommunityFeed(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/submit',
                  builder: (context, state) =>
                      const TranslationSubmissionForm(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const UserProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
