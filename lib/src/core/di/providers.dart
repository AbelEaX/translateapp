import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/translation/presentation/providers/community_feed_provider.dart';
import '../../features/translation/presentation/providers/navigation_provider.dart';
import '../../features/translation/presentation/providers/submission_provider.dart';
import '../../notifications/presentation/providers/notification_provider.dart';
import '../../notifications/services/notification_service.dart';
import 'service_locator.dart';

/// Central configuration for every [ChangeNotifierProvider] and [Provider]
/// in the app. Import this file and [ServiceLocator] to bootstrap the
/// provider tree in [main.dart].
class AppProviders {
  /// Builds the full list of providers wired to [dependencies].
  static List<SingleChildWidget> from(ServiceLocator sl) {
    return [
      // --- Navigation ---
      ChangeNotifierProvider(create: (_) => NavigationProvider()),

      // --- Auth ---
      ChangeNotifierProvider(
        create: (_) => AuthProvider(
          authRepository: sl.authRepository,
          signInWithGoogle: sl.signInWithGoogle,
        ),
      ),

      // --- Submission ---
      ChangeNotifierProxyProvider<AuthProvider, SubmissionProvider>(
        create: (context) => SubmissionProvider(
          submitTranslationUseCase: sl.submitTranslation,
          authProvider: Provider.of<AuthProvider>(context, listen: false),
        ),
        update: (context, auth, prev) =>
            prev ??
            SubmissionProvider(
              submitTranslationUseCase: sl.submitTranslation,
              authProvider: auth,
            ),
      ),

      // --- Community Feed ---
      ChangeNotifierProvider(
        create: (_) => CommunityFeedProvider(
          getTranslationsUseCase: sl.getCommunityTranslations,
          updateScoreUseCase: sl.updateTranslationScore,
          getCommunitiesUseCase: sl.getCommunities,
          joinCommunityUseCase: sl.joinCommunity,
          leaveCommunityUseCase: sl.leaveCommunity,
        ),
      ),

      // --- Notifications ---
      ChangeNotifierProvider(
        create: (_) => NotificationProvider(
          getNotifications: sl.getNotifications,
          markNotificationRead: sl.markNotificationRead,
          markAllRead: sl.markAllRead,
        ),
      ),

      // NotificationService exposed so _NotificationInitializer can call
      // initialize(userId) after auth without going through the provider tree.
      Provider<NotificationService>.value(value: sl.notificationService),
    ];
  }
}
