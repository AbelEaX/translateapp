import 'package:flutter/material.dart';
import 'package:translate/src/features/auth/domain/entities/user_entity.dart';
import 'package:translate/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:translate/src/features/auth/domain/usecases/sign_in_with_google.dart';

enum AuthStatus {
  uninitialized, // App is starting, waiting for the initial auth check
  authenticated,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  final SignInWithGoogle signInWithGoogleUseCase; // Renamed for clarity

  AuthProvider({
    required this.authRepository,
    required SignInWithGoogle signInWithGoogle,
  }) : signInWithGoogleUseCase = signInWithGoogle {
    _listenToAuthChanges(); // Start listening immediately
  }

  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;

  UserEntity? _user;
  UserEntity? get user => _user;

  String? _error;
  String? get error => _error;

  // --- FIX 1: Use _isLoading to match UI or alias it ---
  bool _isLoading = false;

  // This getter fixes the error in AuthGate
  bool get isLoading => _isLoading;

  // Listens to the Firebase Stream and updates the Provider state
  void _listenToAuthChanges() {
    authRepository.authStateChanges.listen((userEntity) {
      if (userEntity == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
      } else {
        _status = AuthStatus.authenticated;
        _user = userEntity;
      }
      notifyListeners();
    });
  }

  // --- FIX 2: Renamed to signInWithGoogle to match AuthGate call ---
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await signInWithGoogleUseCase.call();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow; // Rethrow so UI can show snackbar if needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await authRepository.signOut();
  }
}
