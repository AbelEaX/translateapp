import 'package:flutter/foundation.dart';
import 'package:translate/src/features/translation/domain/entities/translation_entry.dart';
import 'package:translate/src/features/translation/domain/usecases/submit_translation.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class SubmissionProvider extends ChangeNotifier {
  final SubmitTranslation submitTranslationUseCase;
  final AuthProvider authProvider;
  final Uuid _uuid = const Uuid();

  SubmissionProvider({
    required this.submitTranslationUseCase,
    required this.authProvider,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Submits a new translation entry, including ML metadata (context and dialect).
  Future<bool> submit({
    // Core translation data
    required String sourceText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
    // ML Metadata
    required String context,
    required String dialect,
  }) async {
    // MODIFIED FOR DEV: Allow submission even if user is null.
    // Use "anonymous_dev_user" as a placeholder if not signed in.
    final userId = authProvider.user?.id ?? 'anonymous_dev_user';

    // Commented out the strict check for development:
    /*
    if (userId == null) {
      _error = "User not logged in. Please sign in to submit a translation.";
      notifyListeners();
      return false;
    }
    */

    if (sourceText.trim().isEmpty || translatedText.trim().isEmpty) {
      _error = "Source and translated text cannot be empty.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 3. Construct the complete TranslationEntry
      final entry = TranslationEntry(
        id: _uuid.v4(),
        createdAt: DateTime.now().toUtc(),
        userId: userId, // Uses real ID or 'anonymous_dev_user'
        sourceText: sourceText,
        translatedText: translatedText,
        sourceLang: sourceLang,
        targetLang: targetLang,
        context: context,
        dialect: dialect,
      );

      await submitTranslationUseCase.call(entry);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Submission failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
