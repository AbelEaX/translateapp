import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translate/src/features/translation/domain/entities/translation_entry.dart';

abstract class TranslationRemoteDataSource {
  Future<void> submitTranslation(TranslationEntry entry);
  Stream<List<TranslationEntry>> getCommunityTranslations();
  Future<void> updateScore({
    required String translationId,
    required String userId,
    required int voteValue,
  });

  /// Fetches the user's vote map: translationId → vote value (1, -1, or absent).
  Future<Map<String, int>> getUserVotes(String userId);
}

// Collection names
const String kTranslationCollection = 'translations';
const String kUserVotesCollection = 'user_votes';

class TranslationRemoteDataSourceImpl implements TranslationRemoteDataSource {
  final FirebaseFirestore firestore;

  TranslationRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _translationsCollection =>
      firestore.collection(kTranslationCollection);

  TranslationEntry _translationFromFirestore(DocumentSnapshot doc) {
    return TranslationEntry.fromFirestore(
      doc as DocumentSnapshot<Map<String, dynamic>>,
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
      'upvotes': 0,
      'downvotes': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<TranslationEntry>> getCommunityTranslations() {
    debugPrint(
      '📌 Stream connecting to DB: ${firestore.app.name} (ID: ${firestore.databaseId})',
    );

    return _translationsCollection
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            debugPrint(
              "⚠️ No translations found in collection '$kTranslationCollection'.",
            );
          }
          return snapshot.docs.map(_translationFromFirestore).toList();
        });
  }

  @override
  Future<Map<String, int>> getUserVotes(String userId) async {
    if (userId.isEmpty) return {};
    final doc = await firestore
        .collection(kUserVotesCollection)
        .doc(userId)
        .get();

    if (!doc.exists) return {};
    final data = doc.data();
    if (data == null || data['votes'] is! Map) return {};
    return Map<String, int>.from(data['votes'] as Map);
  }

  @override
  Future<void> updateScore({
    required String translationId,
    required String userId,
    required int voteValue,
  }) async {
    final translationRef = _translationsCollection.doc(translationId);
    final userVotesRef = firestore.collection(kUserVotesCollection).doc(userId);

    await firestore.runTransaction((transaction) async {
      final userVotesSnapshot = await transaction.get(userVotesRef);

      Map<String, int> votes = {};
      if (userVotesSnapshot.exists) {
        final data = userVotesSnapshot.data();
        if (data != null && data['votes'] is Map) {
          votes = Map<String, int>.from(data['votes'] as Map);
        }
      }

      final int previousVote = votes[translationId] ?? 0;

      int upChange = 0;
      int downChange = 0;

      if (voteValue == 1) {
        if (previousVote == 1) {
          upChange = -1;
          votes.remove(translationId);
        } else if (previousVote == -1) {
          downChange = -1;
          upChange = 1;
          votes[translationId] = 1;
        } else {
          upChange = 1;
          votes[translationId] = 1;
        }
      } else if (voteValue == -1) {
        if (previousVote == -1) {
          downChange = -1;
          votes.remove(translationId);
        } else if (previousVote == 1) {
          upChange = -1;
          downChange = 1;
          votes[translationId] = -1;
        } else {
          downChange = 1;
          votes[translationId] = -1;
        }
      }

      if (upChange != 0 || downChange != 0) {
        transaction.update(translationRef, {
          'upvotes': FieldValue.increment(upChange),
          'downvotes': FieldValue.increment(downChange),
          'score': FieldValue.increment(upChange - downChange),
        });
      }

      transaction.set(userVotesRef, {'votes': votes}, SetOptions(merge: true));

      debugPrint(
        '✅ Vote transaction complete. UpChange: $upChange, DownChange: $downChange',
      );
    });
  }
}
