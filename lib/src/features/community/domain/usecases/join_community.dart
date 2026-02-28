import 'package:translate/src/features/community/domain/repositories/community_repository.dart';

class JoinCommunity {
  final CommunityRepository repository;
  const JoinCommunity(this.repository);

  Future<void> call(String userId, String communityId) =>
      repository.joinCommunity(userId, communityId);
}
