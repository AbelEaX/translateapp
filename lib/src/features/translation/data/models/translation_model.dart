import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/TranslationEntry.dart';

class TranslationModel extends TranslationEntry {
  const TranslationModel({
    super.id,
    required super.userId,
    required super.sourceText,
    required super.translatedText,
    required super.sourceLang,
    required super.targetLang,
    required super.context,
    required super.dialect,
    super.score,
    required super.createdAt,
  });

  // Factory to create a Model from Firestore Data
  factory TranslationModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TranslationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      sourceText: data['sourceText'] ?? '',
      translatedText: data['translatedText'] ?? '',
      sourceLang: data['sourceLang'] ?? 'en',
      targetLang: data['targetLang'] ?? 'lg',
      context: data['context'] ?? 'General',
      dialect: data['dialect'] ?? 'Standard',
      score: data['confidenceScore'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Method to convert Model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLang': sourceLang,
      'targetLang': targetLang,
      'context': context,
      'dialect': dialect,
      'confidenceScore': score,
      'createdAt': FieldValue.serverTimestamp(), // Let server set the time
    };
  }

  // Helper to convert from Entity to Model
  factory TranslationModel.fromEntity(TranslationEntry entry) {
    return TranslationModel(
      id: entry.id,
      userId: entry.userId,
      sourceText: entry.sourceText,
      translatedText: entry.translatedText,
      sourceLang: entry.sourceLang,
      targetLang: entry.targetLang,
      context: entry.context,
      dialect: entry.dialect,
      score: entry.score,
      createdAt: entry.createdAt,
    );
  }
}