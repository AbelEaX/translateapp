import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translate/src/features/translation/domain/entities/TranslationEntry.dart';

abstract class TranslationRemoteDataSource {
  Future<void> submitTranslation(TranslationEntry entry);
  Stream<List<TranslationEntry>> getCommunityTranslations();
  Future<void> updateScore({required String translationId, required String userId, required int voteValue});
}

// Collection names for clarity
const String kTranslationCollection = 'translations';
const String kUserVotesCollection = 'user_votes'; // Using the new collection name

class TranslationRemoteDataSourceImpl implements TranslationRemoteDataSource {
  final FirebaseFirestore firestore;

  TranslationRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _translationsCollection => firestore.collection(kTranslationCollection);

  // Helper method to convert Firestore document to Entity (Data Transfer Object)
  TranslationEntry _translationFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null for ID: ${doc.id}");
    }

    final score = (data['score'] as num?)?.toInt() ?? 0;

    return TranslationEntry(
      id: doc.id,
      userId: data['userId'] as String? ?? '',

      // Core Text Fields
      sourceText: data['sourceText'] as String? ?? '',
      translatedText: data['translatedText'] as String? ?? '',
      sourceLang: data['sourceLang'] as String? ?? '',
      targetLang: data['targetLang'] as String? ?? '',

      // ML Metadata Fields
      context: data['context'] as String? ?? '',
      dialect: data['dialect'] as String? ?? '',

      // Score/Vote Fields
      score: score,
      // isVotedByUser is determined externally (in Provider/Repository) by checking the user_votes collection
      isVotedByUser: false,

      // Timestamp Field
      createdAt: (data['timestamp'] is Timestamp)
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now().toUtc(), // Fallback for missing timestamp
    );
  }

  @override
  Future<void> submitTranslation(TranslationEntry entry) async {
    await _translationsCollection.add({
      'userId': entry.userId,
      'sourceText': entry.sourceText,
      'translatedText': entry.translatedText,
      'sourceLang': entry.sourceLang,
      'targetLang': entry.targetLang,

      'context': entry.context,
      'dialect': entry.dialect,

      'status': 'Pending',
      'score': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // --- Implement Real-Time Stream ---
  @override
  Stream<List<TranslationEntry>> getCommunityTranslations() {
    return _translationsCollection
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      // NOTE: isVotedByUser will be false here. The Repository must merge vote data.
      return snapshot.docs.map(_translationFromFirestore).toList();
    });
  }

  // --- Transactional Score Update (Vote Logic - Provided by User) ---
  @override
  Future<void> updateScore({
    required String translationId,
    required String userId,
    required int voteValue, // The intent: +1 (upvote) or -1 (downvote)
  }) async {
    final translationRef = _translationsCollection.doc(translationId);
    // Reference the user's vote document in the dedicated collection
    final userVotesRef = firestore.collection(kUserVotesCollection).doc(userId);

    await firestore.runTransaction((transaction) async {
      final userVotesSnapshot = await transaction.get(userVotesRef);

      // Extract existing votes map
      Map<String, int> votes = {};
      if (userVotesSnapshot.exists) {
        final data = userVotesSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data['votes'] is Map) {
          // votes is stored as a Map<String, dynamic>, convert values to int
          votes = Map<String, int>.from(data['votes'] as Map).map((k, v) => MapEntry(k, v as int));
        }
      }

      // Get the current vote status for this specific translation
      final currentVote = votes[translationId] ?? 0;
      int scoreChange = 0; // The calculated delta to apply to the translation's score

      if (voteValue == 1) { // User is trying to Upvote
        if (currentVote == 1) {
          // Unvote Upvote: score down by 1, remove vote entry
          scoreChange = -1;
          votes.remove(translationId);
          debugPrint('Transaction: Upvote UNVOTED. Score change: $scoreChange');
        } else if (currentVote == -1) {
          // Switch Downvote to Upvote: score up by 2, set vote to 1
          scoreChange = 2;
          votes[translationId] = 1;
          debugPrint('Transaction: Switched from DOWN to UP. Score change: $scoreChange');
        } else { // currentVote == 0
          // New Upvote: score up by 1, set vote to 1
          scoreChange = 1;
          votes[translationId] = 1;
          debugPrint('Transaction: New UPVOTE. Score change: $scoreChange');
        }
      } else if (voteValue == -1) { // User is trying to Downvote
        if (currentVote == -1) {
          // Unvote Downvote: score up by 1, remove vote entry
          scoreChange = 1;
          votes.remove(translationId);
          debugPrint('Transaction: Downvote UNVOTED. Score change: $scoreChange');
        } else if (currentVote == 1) {
          // Switch Upvote to Downvote: score down by 2, set vote to -1
          scoreChange = -2;
          votes[translationId] = -1;
          debugPrint('Transaction: Switched from UP to DOWN. Score change: $scoreChange');
        } else { // currentVote == 0
          // New Downvote: score down by 1, set vote to -1
          scoreChange = -1;
          votes[translationId] = -1;
          debugPrint('Transaction: New DOWNVOTE. Score change: $scoreChange');
        }
      } else {
        throw Exception("Invalid vote value. Must be 1 or -1.");
      }

      // 1. Update the translation score in the main document atomically
      if (scoreChange != 0) {
        transaction.update(translationRef, {
          'score': FieldValue.increment(scoreChange),
        });
      }

      // 2. Update the user's vote record (using merge: true if setting, or implicit merge if document doesn't exist)
      transaction.set(userVotesRef, {'votes': votes}, SetOptions(merge: true));
    });

    debugPrint('Successfully updated score for $translationId. Score change was enforced transactionally.');
  }
}