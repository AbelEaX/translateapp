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

  AuthRemoteDataSourceImpl({required this.firebaseAuth, required this.googleSignIn});

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
        // FIX: Provide a default value (0) for the required non-nullable 'points' parameter.
        points: 0,
      );
    });
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Sign in cancelled by user.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Firebase sign-in failed.');
      }

      return UserModel(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
        // FIX: Provide a default value (0) for the required non-nullable 'points' parameter.
        points: 0,
      );
    } catch (e) {
      await googleSignIn.signOut(); // Ensure clean state on failure
      // It's generally better practice to throw a custom exception, but following your existing pattern:
      throw Exception('Google Sign-In Error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }
}