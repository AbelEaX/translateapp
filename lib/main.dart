import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:translate/src/core/config/constants.dart';
import 'package:translate/src/features/auth/data/datasources/auth_remote_datasource.dart';

// --- AUTH DEPENDENCIES ---
import 'package:translate/src/features/auth/data/repostitories/auth_repository_impl.dart';
import 'package:translate/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:translate/src/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:translate/src/features/community/domain/entities/community_model.dart';

// --- NEW AUTH UI IMPORTS ---
// Ensure these paths match where you saved the previous files
import 'package:translate/src/features/auth/presentation/screens/onboarding_screen.dart';
// import 'package:translate/src/features/auth/presentation/screens/auth_gate.dart'; // (Indirectly used via Onboarding)

// --- TRANSLATION DEPENDENCIES ---
import 'package:translate/src/features/translation/data/datasources/translation_remote_datasource.dart';
import 'package:translate/src/features/translation/data/repostitories/translation_repository_impl.dart';
import 'package:translate/src/features/translation/domain/usecases/submit_translation.dart';
import 'package:translate/src/features/translation/presentation/providers/submission_provider.dart';

// --- COMMUNITY FEED DEPENDENCIES ---
import 'package:translate/src/features/translation/domain/usecases/get_community_translations.dart';
import 'package:translate/src/features/translation/domain/usecases/update_translation_score.dart';
import 'package:translate/src/features/translation/presentation/providers/community_feed_provider.dart';
// These imports are assumed to bring in the abstract Use Case definitions
// (GetAllCommunitiesUseCase, ToggleCommunityMembershipUseCase) and the
// Community entity, which are required for the placeholder classes below.

// Import UI
import 'package:translate/src/features/translation/presentation/screens/app_shell.dart';
// NOTE: firestore_service.dart import is likely vestigial and can be removed if not used.
import 'package:translate/src/services/firestore_service.dart';

// Import generated Firebase options
import 'firebase_options.dart';


// --- CONCRETE PLACEHOLDER USE CASES FOR DEPENDENCY INJECTION ---

// Placeholder concrete implementation for GetAllCommunitiesUseCase
class CommunityFetcherPlaceholder implements GetAllCommunitiesUseCase {
  @override
  Future<List<Community>> call() async {
    // Return mock data until the real repository/datasource is implemented
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      Community(
          id: 'community1',
          name: 'Global Translators',
          description: 'A community for translators worldwide.',
          adminId: '',
          languageCode: ''
      ),
      Community(
          id: 'community1',
          name: 'Luganda Language Hub',
          description: 'A dedicated group for translating between English and Luganda, focusing on proverbs and traditional usage.',
          adminId: 'admin_buganda',
          languageCode: 'lg', // Luganda
          memberCount: 2350
      ),
      Community(
          id: 'community2',
          name: 'Runyankole-Rukiga Collective',
          description: 'Translating documents and phrases for the Ankole and Kigezi regions, ensuring dialect fidelity.',
          adminId: 'admin_ankole',
          languageCode: 'nyn', // Runyankole
          memberCount: 1420
      ),
      Community(
          id: 'community3',
          name: 'Acholi & Lango Translators',
          description: 'Specializing in translating historical and contemporary texts from/to Acholi and Lango languages.',
          adminId: 'admin_north',
          languageCode: 'ach', // Acholi
          memberCount: 810
      ),
      Community(
          id: 'community4',
          name: 'Swahili East Africa Bridge',
          description: 'A community focused on improving Swahili translations used across East Africa, including Uganda.',
          adminId: 'admin_swahili',
          languageCode: 'sw', // Swahili
          memberCount: 3700
      ),
      Community(
          id: 'community5',
          name: 'Lusoga Cultural Exchange',
          description: 'Supporting translation of Lusoga texts and everyday conversations, particularly for cultural preservation.',
          adminId: 'admin_busoga',
          languageCode: 'xog', // Lusoga
          memberCount: 550
      ),

    ];
  }
}

// Placeholder concrete implementation for ToggleCommunityMembershipUseCase
class MembershipTogglePlaceholder implements ToggleCommunityMembershipUseCase {
  @override
  Future<void> call({required String communityId, required bool isJoining}) async {
    // Simulate a successful network operation for joining/leaving
    await Future.delayed(const Duration(milliseconds: 300));
    debugPrint('Placeholder: User successfully ${isJoining ? 'joined' : 'left'} community $communityId');
  }
}

// --- MAIN FUNCTION AND FIREBASE INITIALIZATION ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AppRoot());
}

// Get the main Firebase App instance
final FirebaseApp app = Firebase.app();

// --- FIRESTORE CUSTOM DATABASE INITIALIZATION ---
// Correctly initializes the custom 'gotranslate' database instance.
final FirebaseFirestore gotranslateDb = FirebaseFirestore.instanceFor(
  app: app,
  databaseId: TRANSLATION_FIRESTORE_DB_ID, // Assuming 'gotranslate' from constants.dart
);

// --- APP ROOT (COMPOSITION ROOT) ---

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {

    // --- AUTH DI SETUP ---
    final authRemoteDataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(),
    );
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
    );
    final signInWithGoogle = SignInWithGoogle(authRepository);

    // --- TRANSLATION DI SETUP ---
    // 1. Create DataSource (Injecting the CUSTOM gotranslateDb instance)
    final translationRemoteDataSource = TranslationRemoteDataSourceImpl(
      firestore: gotranslateDb,
    );

    // 2. Create Repository
    final translationRepository = TranslationRepositoryImpl(
      remoteDataSource: translationRemoteDataSource,
      firestore: gotranslateDb,
    );

    // 3. Create Translation Use Cases
    final submitUseCase = SubmitTranslation(translationRepository);
    final getCommunityTranslations = GetCommunityTranslations(translationRepository);
    final updateTranslationScore = UpdateTranslationScore(translationRepository);

    // 4. Create Community Use Cases (NEW: Instantiating the Placeholders)
    final getAllCommunities = CommunityFetcherPlaceholder();
    final toggleMembership = MembershipTogglePlaceholder();


    // --- PROVIDER SETUP ---
    return MultiProvider(
      providers: [
        // 1. Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: authRepository,
            signInWithGoogle: signInWithGoogle,
          ),
        ),
        // 2. Submission Provider (Depends on AuthProvider)
        ChangeNotifierProvider(
          create: (context) => SubmissionProvider(
            submitTranslationUseCase: submitUseCase,
            // Accesses AuthProvider using Provider.of
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
        // 3. Community Feed Provider (FIX: Injecting the new dependencies)
        ChangeNotifierProvider(
          create: (_) => CommunityFeedProvider(
            getTranslationsUseCase: getCommunityTranslations,
            updateScoreUseCase: updateTranslationScore,
            // FIX: Add required arguments
            getAllCommunitiesUseCase: getAllCommunities,
            toggleMembershipUseCase: toggleMembership,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'GoTranslate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4C579E)),
        ),
        // --- UPDATED HOME LOGIC ---
        // Instead of static AppShell, we listen to Auth State
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // 1. If the stream is still connecting, show a loader
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // 2. If we have a user, show the AppShell (Main App)
            if (snapshot.hasData && snapshot.data != null) {
              return const AppShell();
            }

            // 3. If no user, start the Authentication Flow
            return const OnboardingScreen();
          },
        ),
      ),
    );
  }
}
