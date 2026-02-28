import 'package:translate/src/features/community/domain/repositories/community_repository.dart';

class LeaveCommunity {
  final CommunityRepository repository;
  const LeaveCommunity(this.repository);

  Future<void> call(String userId, String communityId) =>
      repository.leaveCommunity(userId, communityId);
}
