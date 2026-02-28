import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translate/src/features/community/domain/entities/community_model.dart';

/// Data-layer model for Community.
/// Handles all Firestore serialisation/deserialisation.
/// The domain entity [Community] remains pure Dart.
class CommunityModel {
  /// Converts a Firestore [DocumentSnapshot] into a domain [Community] entity.
  static Community fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Community(
      id: doc.id,
      name: data['name'] as String? ?? 'Unnamed Community',
      description:
          data['description'] as String? ?? 'No description available.',
      adminId: data['adminId'] as String? ?? 'system',
      isJoined: false,
      memberCount: (data['memberCount'] as num?)?.toInt() ?? 0,
      languageCode: data['languageCode'] as String? ?? 'en',
      profilePictureUrl: data['profilePictureUrl'] as String?,
    );
  }

  /// Converts a domain [Community] to a Firestore-ready map.
  static Map<String, dynamic> toFirestore(Community community) {
    return {
      'name': community.name,
      'description': community.description,
      'adminId': community.adminId,
      'memberCount': community.memberCount,
      'languageCode': community.languageCode,
      'profilePictureUrl': community.profilePictureUrl,
    };
  }
}
