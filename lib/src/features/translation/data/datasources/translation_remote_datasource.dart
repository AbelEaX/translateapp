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
const String kUserVotesCollection = 'user_votes';

class TranslationRemoteDataSourceImpl implements TranslationRemoteDataSource {
  final FirebaseFirestore firestore;

  TranslationRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _translationsCollection => firestore.collection(kTranslationCollection);

  // Helper method to convert Firestore document to Entity
  TranslationEntry _translationFromFirestore(DocumentSnapshot doc) {
    return TranslationEntry.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
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
      'score': 0,       // Net score
      'upvotes': 0,     // Explicit counter
      'downvotes': 0,   // Explicit counter
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<TranslationEntry>> getCommunityTranslations() {
    debugPrint("🔌 Stream connecting to DB: ${firestore.app.name} (ID: ${firestore.databaseId})");

    return _translationsCollection
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        debugPrint("⚠️ No translations found in collection '$kTranslationCollection'.");
      }
      return snapshot.docs.map(_translationFromFirestore).toList();
    });
  }

  // --- TRANSACTIONAL VOTE LOGIC ---
  @override
  Future<void> updateScore({
    required String translationId,
    required String userId,
    required int voteValue, // 1 for Upvote, -1 for Downvote
  }) async {
    final translationRef = _translationsCollection.doc(translationId);
    final userVotesRef = firestore.collection(kUserVotesCollection).doc(userId);

    await firestore.runTransaction((transaction) async {
      final userVotesSnapshot = await transaction.get(userVotesRef);

      // 1. Get existing vote map for this user
      Map<String, int> votes = {};
      if (userVotesSnapshot.exists) {
        final data = userVotesSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data['votes'] is Map) {
          votes = Map<String, int>.from(data['votes'] as Map).map((k, v) => MapEntry(k, v as int));
        }
      }

      // Current vote status: 0 = None, 1 = Upvoted, -1 = Downvoted
      final int previousVote = votes[translationId] ?? 0;

      int upChange = 0;
      int downChange = 0;

      // --- LOGIC MATRIX ---

      // SCENARIO A: User clicked UPVOTE (+1)
      if (voteValue == 1) {
        if (previousVote == 1) {
          // User was already Upvoted -> TOGGLE OFF (Remove Upvote)
          upChange = -1;
          votes.remove(translationId);
        } else if (previousVote == -1) {
          // User was Downvoted -> SWITCH (Remove Down, Add Up)
          downChange = -1;
          upChange = 1;
          votes[translationId] = 1;
        } else {
          // User had no vote -> NEW UPVOTE
          upChange = 1;
          votes[translationId] = 1;
        }
      }

      // SCENARIO B: User clicked DOWNVOTE (-1)
      else if (voteValue == -1) {
        if (previousVote == -1) {
          // User was already Downvoted -> TOGGLE OFF (Remove Downvote)
          downChange = -1;
          votes.remove(translationId);
        } else if (previousVote == 1) {
          // User was Upvoted -> SWITCH (Remove Up, Add Down)
          upChange = -1;
          downChange = 1;
          votes[translationId] = -1;
        } else {
          // User had no vote -> NEW DOWNVOTE
          downChange = 1;
          votes[translationId] = -1;
        }
      }

      // 2. Update the Translation Document (Counters)
      if (upChange != 0 || downChange != 0) {
        transaction.update(translationRef, {
          'upvotes': FieldValue.increment(upChange),
          'downvotes': FieldValue.increment(downChange),
          'score': FieldValue.increment(upChange - downChange),
        });
      }

      // 3. Update the User's Vote History
      transaction.set(userVotesRef, {'votes': votes}, SetOptions(merge: true));

      // MOVED INSIDE the transaction block so variables are accessible
      debugPrint("✅ Vote transaction complete. UpChange: $upChange, DownChange: $downChange");
    });
  }
}
