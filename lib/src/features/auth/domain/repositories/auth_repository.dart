import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Stream to listen for Firebase auth state changes (login/logout)
  Stream<UserEntity?> get authStateChanges;

  // Method to handle the sign-in process
  Future<UserEntity> signInWithGoogle();

  // Method to sign out
  Future<void> signOut();
}