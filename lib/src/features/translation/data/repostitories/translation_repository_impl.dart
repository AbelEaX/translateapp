import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:translate/src/features/translation/data/models/translation_model.dart';
import 'package:translate/src/features/translation/domain/entities/translation_entry.dart';
import 'package:translate/src/features/translation/domain/repositories/translation_repository.dart';
import '../datasources/translation_remote_datasource.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationRemoteDataSource remoteDataSource;

  TranslationRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<TranslationEntry>> getCommunityTranslations() {
    final translationsStream = remoteDataSource.getCommunityTranslations();
    final userStream = FirebaseAuth.instance.authStateChanges();

    return Rx.combineLatest2<
          List<TranslationEntry>,
          User?,
          List<TranslationEntry>
        >(translationsStream, userStream, (translations, user) => translations)
        .asyncMap((translations) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return translations;

          // Delegate user_votes fetch to the datasource
          final votes = await remoteDataSource.getUserVotes(user.uid);

          return translations.map((entry) {
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
    return remoteDataSource.updateScore(
      translationId: translationId,
      userId: userId,
      voteValue: scoreChange,
    );
  }
}
