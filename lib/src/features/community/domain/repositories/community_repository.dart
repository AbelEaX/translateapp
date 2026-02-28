import 'package:translate/src/features/community/domain/entities/community_model.dart';

/// Abstract repository contract for community operations.
/// Lives in domain — pure Dart, no Firebase.
abstract class CommunityRepository {
  Future<List<Community>> getAllCommunities(String? userId);
  Future<void> joinCommunity(String userId, String communityId);
  Future<void> leaveCommunity(String userId, String communityId);
}
