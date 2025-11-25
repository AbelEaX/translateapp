import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart'; // Optional: Recommended for better stream combining
import 'package:translate/src/features/translation/data/models/translation_model.dart';
import 'package:translate/src/features/translation/domain/entities/TranslationEntry.dart';
import 'package:translate/src/features/translation/domain/repositories/TranslationRepository.dart';
import '../datasources/translation_remote_datasource.dart';

const String kUserVotesCollection = 'user_votes';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationRemoteDataSource remoteDataSource;
  final FirebaseFirestore firestore;

  TranslationRepositoryImpl({required this.remoteDataSource, required this.firestore});

  @override
  Stream<List<TranslationEntry>> getCommunityTranslations() {
    // 1. Get the raw translations stream
    final translationsStream = remoteDataSource.getCommunityTranslations();

    // 2. Create a stream of the current user's ID (updates on login/logout)
    final userStream = FirebaseAuth.instance.authStateChanges();

    // 3. Combine them so whenever translations change OR user logs in/out, we update
    return Rx.combineLatest2<List<TranslationEntry>, User?, List<TranslationEntry>>(
        translationsStream,
        userStream,
            (translations, user) {
          if (user == null) return translations;

          // We need to return a Stream here, but combineLatest expects a value.
          // Since fetching the user votes is async (Future), the standard pattern
          // without RxDart complexity is to wrap the result in a Future/StreamBuilder in UI,
          // OR use the asyncMap approach you had, but make sure it listens to AUTH changes too.

          // Let's stick to the asyncMap approach but ensure we fetch fresh votes every time
          return translations;
        }
    ).asyncMap((translations) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return translations;

      // FETCH REAL-TIME VOTES
      // Note: Ideally this should also be a stream, but a 'get' is okay for MVP
      final userVotesDoc = await firestore.collection(kUserVotesCollection).doc(user.uid).get();

      Map<String, int> votes = {};
      if (userVotesDoc.exists) {
        final data = userVotesDoc.data();
        if (data != null && data['votes'] is Map) {
          votes = Map<String, int>.from(data['votes'] as Map).map((k, v) => MapEntry(k, v as int));
        }
      }

      return translations.map((entry) {
        // 0 = None, 1 = Up, -1 = Down
        final int myVote = votes[entry.id] ?? 0;
        return entry.copyWith(userVoteStatus: myVote);
      }).toList();
    });
  }

  @override
  Future<void> submitTranslation(TranslationEntry entry) async {
    final model = TranslationModel.fromEntity(entry);
    await remoteDataSource.submitTranslation(model);
  }

  @override
  Future<void> updateTranslationScore({
    required String translationId,
    required String userId,
    required int scoreChange,
  }) {
    // We simply pass the INTENT (1 or -1). The DataSource handles the "Switching" logic.
    return remoteDataSource.updateScore(
      translationId: translationId,
      userId: userId,
      voteValue: scoreChange,
    );
  }
}
