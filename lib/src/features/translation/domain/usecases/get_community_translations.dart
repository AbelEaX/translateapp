import 'package:translate/src/features/translation/domain/entities/TranslationEntry.dart';
import 'package:translate/src/features/translation/domain/repositories/TranslationRepository.dart';


class GetCommunityTranslations {
  final TranslationRepository repository;

  GetCommunityTranslations(this.repository);

  // Fetches a list of the latest translations submitted by the community.
  Future<Stream<List<TranslationEntry>>> call() async {
    // We could add business logic here, like filtering out translations
    // with a low confidence score, or paginating the list.
    return await repository.getCommunityTranslations();
  }
}