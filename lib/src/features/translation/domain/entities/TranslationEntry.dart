import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- CRITICAL: Required for Timestamp and DocumentSnapshot

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

  // --- COMMUNITY SCORE (Updated) ---
  final int score;               // Total upvotes - downvotes
  final bool isVotedByUser;     // Tracks if the current user has voted on this item
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
    this.score = 0,             // Default score is 0
    this.isVotedByUser = false, // Default: user hasn't voted
    required this.createdAt,
  });

  // --- CRITICAL FACTORY METHOD: Maps Firestore fields to the Dart object ---
  factory TranslationEntry.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, [String? currentUserId]
      ) {
    // Get the data map or an empty map if it's null
    final data = snapshot.data() ?? {};

    // 1. Handle Timestamp: Convert Firestore's Timestamp object to Dart's DateTime
    final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();

    // 2. Handle Score: Safely cast the score field, defaulting to 0
    final int score = (data['score'] is int) ? data['score'] as int : 0;

    // 3. Placeholder for User Vote (Will need implementation later)
    bool voted = false;

    return TranslationEntry(
      id: snapshot.id,
      // CRITICAL: These keys must EXACTLY match your Firestore document keys (e.g., 'sourceText', 'userId', etc.)
      userId: data['userId'] as String? ?? 'anonymous',
      sourceLang: data['sourceLang'] as String? ?? 'Unknown',
      targetLang: data['targetLang'] as String? ?? 'Unknown',
      sourceText: data['sourceText'] as String? ?? '',
      translatedText: data['translatedText'] as String? ?? '',
      score: score,
      context: data['context'] as String? ?? 'N/A',
      dialect: data['dialect'] as String? ?? 'N/A',
      createdAt: timestamp.toDate(), // Use the converted DateTime
      isVotedByUser: voted,
    );
  }


  // --- CopyWith Method ---
  // Essential for state updates in Provider
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
    bool? isVotedByUser,
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
      isVotedByUser: isVotedByUser ?? this.isVotedByUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, sourceText, translatedText, context, dialect, score, isVotedByUser, createdAt];
}