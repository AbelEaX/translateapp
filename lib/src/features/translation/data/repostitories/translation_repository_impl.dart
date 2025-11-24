import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translate/src/features/translation/data/models/translation_model.dart';
import 'package:translate/src/features/translation/domain/entities/TranslationEntry.dart';
import 'package:translate/src/features/translation/domain/repositories/TranslationRepository.dart';
import '../datasources/translation_remote_datasource.dart'; // Import abstract data source

// Assuming the current user ID is accessible (or passed in) to determine vote status.
// For now, we'll use a placeholder user ID, similar to the UI widget.
const String kCurrentMockUserId = 'temp-user-12345';
const String kUserVotesCollection = 'user_votes';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationRemoteDataSource remoteDataSource;
  final FirebaseFirestore firestore; // Inject Firestore instance here to check votes

  TranslationRepositoryImpl({required this.remoteDataSource, required this.firestore});

  // --- Real-Time Feed Fetching and Merging ---
  @override
  Stream<List<TranslationEntry>> getCommunityTranslations() {
    // 1. Get the stream of translation entries from the remote data source
    return remoteDataSource.getCommunityTranslations().asyncMap((translations) async {
      // 2. Fetch the current user's vote data in a single read operation
      final userVotesDoc = await firestore.collection(kUserVotesCollection).doc(kCurrentMockUserId).get();

      // Extract votes map (Map<String, int> where key is translationId and value is 1 or -1)
      Map<String, int> votes = {};
      if (userVotesDoc.exists) {
        final data = userVotesDoc.data() as Map<String, dynamic>?;
        if (data != null && data['votes'] is Map) {
          votes = Map<String, int>.from(data['votes'] as Map).map((k, v) => MapEntry(k, v as int));
        }
      }

      // 3. Map the translation list, merging the vote status
      return translations.map((entry) {
        // Check if the current user has a recorded vote (either +1 or -1) for this entry
        final hasVoted = votes.containsKey(entry.id);

        // Return a copy of the entry with the correct isVotedByUser status
        return entry.copyWith(isVotedByUser: hasVoted);
      }).toList();
    });
  }

  // --- Write Operations (Delegated) ---

  @override
  Future<void> submitTranslation(TranslationEntry entry) async {
    // Assuming TranslationModel extends TranslationEntry for direct use,
    // or provides a static method to convert.
    final model = TranslationModel.fromEntity(entry);
    await remoteDataSource.submitTranslation(model);
  }


  @override
  Future<void> updateTranslationScore({
    required String translationId,
    required String userId,
    required int scoreChange,
  }) {
    return remoteDataSource.updateScore(
      translationId: translationId,
      userId: userId,
      voteValue: scoreChange,
    );
  }
}