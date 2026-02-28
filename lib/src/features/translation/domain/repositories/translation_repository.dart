import '../entities/translation_entry.dart';

abstract class TranslationRepository {

  // Submit a new translation
  Future<void> submitTranslation(TranslationEntry entry);

  // --- FIX 1: Change to Stream for Real-Time Updates ---
  // Get the feed of translations (for the Community tab)
  Stream<List<TranslationEntry>> getCommunityTranslations();

  // --- FIX 2: Remove Redundant Method ---
  // Future<void> voteTranslation(String id, int voteChange);

  // --- FIX 3: Adopt the Final Voting Method Signature ---
  // This method encapsulates the full voting logic (read/write transaction).
  Future<void> updateTranslationScore({
    required String translationId,
    required String userId,
    // Renamed parameter for clarity: it represents the value being applied (+1 or -1),
    // NOT the final document score.
    required int scoreChange,
  });
}