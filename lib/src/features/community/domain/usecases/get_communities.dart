import 'package:translate/src/features/community/domain/entities/community_model.dart';
import 'package:translate/src/features/community/domain/repositories/community_repository.dart';

class GetCommunities {
  final CommunityRepository repository;
  const GetCommunities(this.repository);

  Future<List<Community>> call(String? userId) =>
      repository.getAllCommunities(userId);
}
