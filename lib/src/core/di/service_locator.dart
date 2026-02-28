import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repostitories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';

// Translation
import '../../features/translation/data/datasources/translation_remote_datasource.dart';
import '../../features/translation/data/repostitories/translation_repository_impl.dart';
import '../../features/translation/domain/usecases/get_community_translations.dart';
import '../../features/translation/domain/usecases/submit_translation.dart';
import '../../features/translation/domain/usecases/update_translation_score.dart';

// Community
import '../../features/community/data/datasources/community_remote_datasource_impl.dart';
import '../../features/community/data/repositories/community_repository_impl.dart';
import '../../features/community/domain/usecases/get_communities.dart';
import '../../features/community/domain/usecases/join_community.dart';
import '../../features/community/domain/usecases/leave_community.dart';

// Notifications
import '../../notifications/data/datasources/notification_remote_datasource.dart';
import '../../notifications/data/repositories/notification_repository_impl.dart';
import '../../notifications/domain/repositories/notification_repository.dart';
import '../../notifications/domain/usecases/get_notifications.dart';
import '../../notifications/domain/usecases/mark_all_read.dart';
import '../../notifications/domain/usecases/mark_notification_read.dart';
import '../../notifications/services/notification_service.dart';

import '../config/constants.dart';

/// Holds all wired dependencies (datasources → repos → use cases → services).
/// Used by [AppProviders] to construct the provider tree.
class ServiceLocator {
  // --- Firestore instances ---
  final FirebaseFirestore gotranslateDb;

  // --- Auth ---
  final AuthRepository authRepository;
  final SignInWithGoogle signInWithGoogle;

  // --- Translation ---
  final SubmitTranslation submitTranslation;
  final GetCommunityTranslations getCommunityTranslations;
  final UpdateTranslationScore updateTranslationScore;

  // --- Community ---
  final GetCommunities getCommunities;
  final JoinCommunity joinCommunity;
  final LeaveCommunity leaveCommunity;

  // --- Notifications ---
  final GetNotifications getNotifications;
  final MarkNotificationRead markNotificationRead;
  final MarkAllRead markAllRead;
  final NotificationService notificationService;

  const ServiceLocator._({
    required this.gotranslateDb,
    required this.authRepository,
    required this.signInWithGoogle,
    required this.submitTranslation,
    required this.getCommunityTranslations,
    required this.updateTranslationScore,
    required this.getCommunities,
    required this.joinCommunity,
    required this.leaveCommunity,
    required this.getNotifications,
    required this.markNotificationRead,
    required this.markAllRead,
    required this.notificationService,
  });

  static Future<ServiceLocator> configure() async {
    // 1. Firebase
    final app = Firebase.app();
    final gotranslateDb = FirebaseFirestore.instanceFor(
      app: app,
      databaseId: TRANSLATION_FIRESTORE_DB_ID,
    );
    final firebaseAuth = FirebaseAuth.instance;
    final googleSignIn = GoogleSignIn();

    // 2. Data Sources
    final authDs = AuthRemoteDataSourceImpl(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
    );
    final translationDs = TranslationRemoteDataSourceImpl(
      firestore: gotranslateDb,
    );
    final communityDs = CommunityRemoteDataSourceImpl(firestore: gotranslateDb);
    final notificationDs = NotificationRemoteDataSourceImpl(
      firestore: gotranslateDb,
    );

    // 3. Repositories
    final authRepo = AuthRepositoryImpl(remoteDataSource: authDs);
    final translationRepo = TranslationRepositoryImpl(
      remoteDataSource: translationDs,
    );
    final communityRepo = CommunityRepositoryImpl(
      remoteDataSource: communityDs,
    );
    final NotificationRepository notifRepo = NotificationRepositoryImpl(
      dataSource: notificationDs,
    );

    // 4. Use Cases
    return ServiceLocator._(
      gotranslateDb: gotranslateDb,
      authRepository: authRepo,
      signInWithGoogle: SignInWithGoogle(authRepo),
      submitTranslation: SubmitTranslation(translationRepo),
      getCommunityTranslations: GetCommunityTranslations(translationRepo),
      updateTranslationScore: UpdateTranslationScore(translationRepo),
      getCommunities: GetCommunities(communityRepo),
      joinCommunity: JoinCommunity(communityRepo),
      leaveCommunity: LeaveCommunity(communityRepo),
      getNotifications: GetNotifications(notifRepo),
      markNotificationRead: MarkNotificationRead(notifRepo),
      markAllRead: MarkAllRead(notifRepo),
      notificationService: NotificationService(
        firestore: gotranslateDb,
        repository: notifRepo,
      ),
    );
  }
}
