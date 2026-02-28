import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translate/src/features/community/domain/entities/community_model.dart';
import 'package:translate/src/features/community/data/models/community_model.dart'
    as community_model;
import 'community_remote_datasource.dart';

const String _kCommunitiesCollection = 'communities';
const String _kUsersCollection = 'users';
const String _kJoinedCommunitiesSubcollection = 'joined_communities';

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final FirebaseFirestore firestore;

  const CommunityRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<Community>> fetchAllCommunities(String? userId) async {
    final querySnapshot = await firestore
        .collection(_kCommunitiesCollection)
        .get();

    var communities = querySnapshot.docs
        .map(community_model.CommunityModel.fromFirestore)
        .toList();

    if (userId != null && userId.isNotEmpty) {
      final joinedSnapshot = await firestore
          .collection(_kUsersCollection)
          .doc(userId)
          .collection(_kJoinedCommunitiesSubcollection)
          .get();

      final joinedIds = joinedSnapshot.docs.map((d) => d.id).toSet();

      communities = communities.map((c) {
        return joinedIds.contains(c.id) ? c.copyWith(isJoined: true) : c;
      }).toList();
    }

    return communities;
  }

  @override
  Future<void> joinCommunity(String userId, String communityId) async {
    await firestore
        .collection(_kUsersCollection)
        .doc(userId)
        .collection(_kJoinedCommunitiesSubcollection)
        .doc(communityId)
        .set({'joinedAt': FieldValue.serverTimestamp()});

    await firestore.collection(_kCommunitiesCollection).doc(communityId).update(
      {'memberCount': FieldValue.increment(1)},
    );
  }

  @override
  Future<void> leaveCommunity(String userId, String communityId) async {
    await firestore
        .collection(_kUsersCollection)
        .doc(userId)
        .collection(_kJoinedCommunitiesSubcollection)
        .doc(communityId)
        .delete();

    await firestore.collection(_kCommunitiesCollection).doc(communityId).update(
      {'memberCount': FieldValue.increment(-1)},
    );

    debugPrint('Left community: $communityId');
  }
}
