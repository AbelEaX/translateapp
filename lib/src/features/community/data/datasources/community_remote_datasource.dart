import 'package:translate/src/features/community/domain/entities/community_model.dart';

/// Abstract contract for all community-related Firestore operations.
abstract class CommunityRemoteDataSource {
  Future<List<Community>> fetchAllCommunities(String? userId);
  Future<void> joinCommunity(String userId, String communityId);
  Future<void> leaveCommunity(String userId, String communityId);
}
