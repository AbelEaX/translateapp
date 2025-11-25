import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Represents a local language community that users can join.
/// Translations are submitted to and filtered by these communities.
@immutable
class Community {
  final String id;
  final String name;
  final String description;
  final String adminId;
  final bool isJoined;
  final int memberCount;
  final String languageCode; // e.g., 'lg' for Luganda, 'sw' for Swahili
  final String? profilePictureUrl; // URL for the community's profile picture

  const Community({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    this.isJoined = false,
    this.memberCount = 0,
    required this.languageCode,
    this.profilePictureUrl,
  });

  /// Factory constructor to create a Community from Firestore DocumentSnapshot.
  /// This handles the extraction of data and ID safely.
  factory Community.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Community(
      id: doc.id, // Use the document ID as the community ID
      name: data['name'] as String? ?? 'Unnamed Community',
      description: data['description'] as String? ?? 'No description available.',
      adminId: data['adminId'] as String? ?? 'system',
      // 'isJoined' is client-side state, defaults to false until we check user data
      isJoined: false,
      memberCount: (data['memberCount'] as num?)?.toInt() ?? 0,
      languageCode: data['languageCode'] as String? ?? 'en',
      profilePictureUrl: data['profilePictureUrl'] as String?,
    );
  }

  /// Factory constructor to create a Community from JSON (legacy/API use).
  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? 'A community for local language enthusiasts.',
      adminId: json['adminId'] as String? ?? 'system',
      isJoined: json['isJoined'] as bool? ?? false,
      memberCount: json['memberCount'] as int? ?? 0,
      languageCode: json['languageCode'] as String? ?? 'en',
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

  /// Converts the Community model to a JSON map for storage (e.g., Firestore).
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'adminId': adminId,
      'memberCount': memberCount,
      'languageCode': languageCode,
      'profilePictureUrl': profilePictureUrl,
      // Note: We don't store 'id' or 'isJoined' inside the document data usually
    };
  }

  /// Utility function to create a copy of the model with updated fields.
  Community copyWith({
    String? id,
    String? name,
    String? description,
    String? adminId,
    bool? isJoined,
    int? memberCount,
    String? languageCode,
    String? profilePictureUrl,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminId: adminId ?? this.adminId,
      isJoined: isJoined ?? this.isJoined,
      memberCount: memberCount ?? this.memberCount,
      languageCode: languageCode ?? this.languageCode,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Community &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.adminId == adminId &&
        other.languageCode == languageCode &&
        other.memberCount == memberCount &&
        other.profilePictureUrl == profilePictureUrl;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      adminId.hashCode ^
      languageCode.hashCode ^
      memberCount.hashCode ^
      profilePictureUrl.hashCode;
}
