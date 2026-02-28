import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:translate/src/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  // Maps Firebase User to our internal UserModel
  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((User? user) {
      if (user == null) {
        return null;
      }
      return UserModel(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
        points: 0,
      );
    });
  }

  /// Persists a user profile document to Firestore so that other users can
  /// resolve this person's name when viewing their translation contributions.
  Future<void> _upsertUserDocument(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // never overwrites points or other fields
      );
    } catch (e) {
      // Non-fatal — the app works without this; just log it.
      // ignore: avoid_print
      print('[Auth] Failed to upsert user doc: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Sign in cancelled by user.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Firebase sign-in failed.');
      }

      // Write/update the Firestore profile so other users can see this person's name.
      await _upsertUserDocument(user);

      return UserModel(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
        points: 0,
      );
    } catch (e) {
      await googleSignIn.signOut(); // Ensure clean state on failure
      throw Exception('Google Sign-In Error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }
}
