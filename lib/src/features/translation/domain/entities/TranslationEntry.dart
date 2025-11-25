import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TranslationEntry extends Equatable {
  final String? id;
  final String userId;
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;

  // --- ML METADATA ---
  final String context;
  final String dialect;

  // --- COMMUNITY SCORE ---
  final int score;           // Net Score (Up - Down)
  final int upvotes;         // NEW: Count of thumbs up
  final int downvotes;       // NEW: Count of thumbs down

  // NEW: 1 = Up, -1 = Down, 0 = None
  final int userVoteStatus;

  final DateTime createdAt;

  const TranslationEntry({
    this.id,
    required this.userId,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.context,
    required this.dialect,
    this.score = 0,
    this.upvotes = 0,
    this.downvotes = 0,
    this.userVoteStatus = 0,
    required this.createdAt,
  });

  factory TranslationEntry.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      [Map<String, int>? userVotesMap] // Optional: Pass user's vote map here if available
      ) {
    final data = snapshot.data() ?? {};
    final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();

    // Safely cast numbers
    final int score = (data['score'] as num?)?.toInt() ?? 0;
    final int upvotes = (data['upvotes'] as num?)?.toInt() ?? 0;
    final int downvotes = (data['downvotes'] as num?)?.toInt() ?? 0;

    // Determine user status if map provided, otherwise 0
    int myVote = 0;
    if (userVotesMap != null && userVotesMap.containsKey(snapshot.id)) {
      myVote = userVotesMap[snapshot.id] ?? 0;
    }

    return TranslationEntry(
      id: snapshot.id,
      userId: data['userId'] as String? ?? 'anonymous',
      sourceLang: data['sourceLang'] as String? ?? 'Unknown',
      targetLang: data['targetLang'] as String? ?? 'Unknown',
      sourceText: data['sourceText'] as String? ?? '',
      translatedText: data['translatedText'] as String? ?? '',
      score: score,
      upvotes: upvotes,
      downvotes: downvotes,
      context: data['context'] as String? ?? 'N/A',
      dialect: data['dialect'] as String? ?? 'N/A',
      createdAt: timestamp.toDate(),
      userVoteStatus: myVote,
    );
  }

  TranslationEntry copyWith({
    String? id,
    String? userId,
    String? sourceText,
    String? translatedText,
    String? sourceLang,
    String? targetLang,
    String? context,
    String? dialect,
    int? score,
    int? upvotes,
    int? downvotes,
    int? userVoteStatus,
    DateTime? createdAt,
  }) {
    return TranslationEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      context: context ?? this.context,
      dialect: dialect ?? this.dialect,
      score: score ?? this.score,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      userVoteStatus: userVoteStatus ?? this.userVoteStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id, userId, sourceText, translatedText, context, dialect,
    score, upvotes, downvotes, userVoteStatus, createdAt
  ];
}
