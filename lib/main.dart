import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translate/firebase_options.dart';
import 'package:translate/src/core/di/providers.dart';
import 'package:translate/src/core/di/service_locator.dart';
import 'package:translate/src/core/routing/app_router.dart';
import 'package:translate/src/core/theme/app_theme.dart';
import 'package:translate/src/core/theme/theme_provider.dart';
import 'package:translate/src/notifications/presentation/providers/notification_provider.dart';
import 'package:translate/src/notifications/services/notification_service.dart';

/// Top-level background message handler — must be a free function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM background] ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register background handler BEFORE Firebase.initializeApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    Firebase.app();
  }

  final sl = await ServiceLocator.configure();
  final prefs = await SharedPreferences.getInstance();
  final themeProvider = ThemeProvider(prefs);

  runApp(AppRoot(sl: sl, themeProvider: themeProvider));
}

class AppRoot extends StatefulWidget {
  final ServiceLocator sl;
  final ThemeProvider themeProvider;

  const AppRoot({super.key, required this.sl, required this.themeProvider});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  // Created once — never recreated on theme change.
  late final _router = AppRouter.router(
    FirebaseAuth.instance.authStateChanges(),
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.themeProvider),
        ...AppProviders.from(widget.sl),
      ],
      child: _NotificationInitializer(
        child: Consumer<ThemeProvider>(
          builder: (context, theme, _) {
            return MaterialApp.router(
              title: 'GoTranslate',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: theme.themeMode,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}

/// Listens to Firebase auth state and initialises / tears-down the
/// notification service and provider accordingly.
class _NotificationInitializer extends StatefulWidget {
  final Widget child;
  const _NotificationInitializer({required this.child});

  @override
  State<_NotificationInitializer> createState() =>
      _NotificationInitializerState();
}

class _NotificationInitializerState extends State<_NotificationInitializer> {
  StreamSubscription<User?>? _authSubscription;
  String? _initializedUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe once — didChangeDependencies is safe for Provider.of access.
    _authSubscription ??= FirebaseAuth.instance.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  void _onAuthStateChanged(User? user) {
    if (!mounted) return;

    final notifProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    final notifService = Provider.of<NotificationService>(
      context,
      listen: false,
    );

    if (user != null && _initializedUid != user.uid) {
      _initializedUid = user.uid;

      // Ensure a Firestore profile doc exists for this user so others can
      // resolve their name on translation cards (merge: true = safe).
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoURL': user.photoURL ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      notifService.initialize(user.uid);
      notifProvider.subscribeForUser(user.uid);
    } else if (user == null && _initializedUid != null) {
      _initializedUid = null;
      notifProvider.unsubscribe();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
