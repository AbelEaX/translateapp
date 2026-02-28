import 'package:translate/src/features/community/domain/entities/community_model.dart';
import 'package:translate/src/features/community/domain/repositories/community_repository.dart';
import 'package:translate/src/features/community/data/datasources/community_remote_datasource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remoteDataSource;

  const CommunityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Community>> getAllCommunities(String? userId) =>
      remoteDataSource.fetchAllCommunities(userId);

  @override
  Future<void> joinCommunity(String userId, String communityId) =>
      remoteDataSource.joinCommunity(userId, communityId);

  @override
  Future<void> leaveCommunity(String userId, String communityId) =>
      remoteDataSource.leaveCommunity(userId, communityId);
}
