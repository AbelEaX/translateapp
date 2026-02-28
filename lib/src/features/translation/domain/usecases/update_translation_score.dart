import 'package:translate/src/features/translation/domain/repositories/translation_repository.dart';

class UpdateTranslationScore {
  final TranslationRepository repository;

  UpdateTranslationScore(this.repository);

  // This method calls the repository to handle the actual score manipulation in the database.
  Future<void> call({
    required String translationId,
    required String userId,
    // FIX 1: Rename the parameter to match the repository interface signature
    required int scoreChange, // Represents the value being applied (+1 or -1)
  }) async {
    // The repository handles the complex logic of checking if the user already
    // voted and applying the transaction to Firestore.

    return repository.updateTranslationScore(
      translationId: translationId,
      userId: userId,
      // FIX 2: Pass the correctly named argument
      scoreChange: scoreChange,
    );
  }
}