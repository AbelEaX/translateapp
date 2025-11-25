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

// --- AUTH UI IMPORTS ---
import 'package:translate/src/features/auth/presentation/screens/onboarding_screen.dart';

// --- TRANSLATION DEPENDENCIES ---
import 'package:translate/src/features/translation/data/datasources/translation_remote_datasource.dart';
import 'package:translate/src/features/translation/data/repostitories/translation_repository_impl.dart';
import 'package:translate/src/features/translation/domain/usecases/submit_translation.dart';
import 'package:translate/src/features/translation/presentation/providers/navigation_provider.dart';
import 'package:translate/src/features/translation/presentation/providers/submission_provider.dart';

// --- COMMUNITY FEED DEPENDENCIES ---
import 'package:translate/src/features/translation/domain/usecases/get_community_translations.dart';
import 'package:translate/src/features/translation/domain/usecases/update_translation_score.dart';
import 'package:translate/src/features/translation/presentation/providers/community_feed_provider.dart';

// Import UI
import 'package:translate/src/features/translation/presentation/screens/app_shell.dart';

// Import generated Firebase options
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIX: Check if Firebase is already initialized to prevent Hot Restart crashes
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // If already initialized (hot restart), rely on existing instance
    Firebase.app();
  }

  runApp(const AppRoot());
}

// --- APP ROOT (COMPOSITION ROOT) ---

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {

    // --- FIRESTORE CUSTOM DATABASE INITIALIZATION ---
    // We move this INSIDE build or a helper to ensure safe access after initialization.
    // Using Firebase.app() ensures we get the default app instance safely.
    final FirebaseApp app = Firebase.app();

    final FirebaseFirestore gotranslateDb = FirebaseFirestore.instanceFor(
      app: app,
      databaseId: TRANSLATION_FIRESTORE_DB_ID,
    );

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
    final translationRemoteDataSource = TranslationRemoteDataSourceImpl(
      firestore: gotranslateDb,
    );

    final translationRepository = TranslationRepositoryImpl(
      remoteDataSource: translationRemoteDataSource,
      firestore: gotranslateDb,
    );

    // --- USE CASES ---
    final submitUseCase = SubmitTranslation(translationRepository);
    final getCommunityTranslations = GetCommunityTranslations(translationRepository);
    final updateTranslationScore = UpdateTranslationScore(translationRepository);

    // --- PROVIDER SETUP ---
    return MultiProvider(
      providers: [
        // Inside MultiProvider...
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        // 1. Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: authRepository,
            signInWithGoogle: signInWithGoogle,
          ),
        ),
        // 2. Submission Provider
        ChangeNotifierProvider(
          create: (context) => SubmissionProvider(
            submitTranslationUseCase: submitUseCase,
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
        // 3. Community Feed Provider
        ChangeNotifierProvider(
          create: (_) => CommunityFeedProvider(
            getTranslationsUseCase: getCommunityTranslations,
            updateScoreUseCase: updateTranslationScore,
            firestore: gotranslateDb, // Injecting custom DB
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
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              return const AppShell();
            }
            return const OnboardingScreen();
          },
        ),
      ),
    );
  }
}
