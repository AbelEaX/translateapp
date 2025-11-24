import '../entities/TranslationEntry.dart';
import '../repositories/TranslationRepository.dart';

class SubmitTranslation {
  final TranslationRepository repository;

  SubmitTranslation(this.repository);

  // 'call' allows us to use the class like a function: submitTranslation(entry)
  Future<void> call(TranslationEntry entry) async {
    // FIX: Use the correct field names: sourceText and translatedText
    if (entry.sourceText.trim().isEmpty || entry.translatedText.trim().isEmpty) {
      throw Exception("Translation text cannot be empty.");
    }

    // You could add profanity filters or length checks here before hitting the DB

    return await repository.submitTranslation(entry);
  }
}