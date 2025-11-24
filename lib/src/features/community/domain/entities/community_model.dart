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
  final String? profilePictureUrl; // NEW: URL for the community's profile picture

  const Community({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    this.isJoined = false,
    this.memberCount = 0,
    required this.languageCode,
    this.profilePictureUrl, // NEW
  });

  /// Factory constructor to create a Community from JSON (e.g., Firestore data).
  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? 'A community for local language enthusiasts.',
      adminId: json['adminId'] as String? ?? 'system',
      isJoined: json['isJoined'] as bool? ?? false,
      memberCount: json['memberCount'] as int? ?? 0,
      languageCode: json['languageCode'] as String? ?? 'en',
      profilePictureUrl: json['profilePictureUrl'] as String?, // NEW
    );
  }

  /// Converts the Community model to a JSON map for storage (e.g., Firestore).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'adminId': adminId,
      'memberCount': memberCount,
      'languageCode': languageCode,
      'profilePictureUrl': profilePictureUrl, // NEW
      // Note: 'isJoined' is typically a transient/local state and not stored in the community document itself.
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
    String? profilePictureUrl, // NEW
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminId: adminId ?? this.adminId,
      isJoined: isJoined ?? this.isJoined,
      memberCount: memberCount ?? this.memberCount,
      languageCode: languageCode ?? this.languageCode,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl, // NEW
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
        other.profilePictureUrl == profilePictureUrl; // NEW
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode ^ adminId.hashCode ^ languageCode.hashCode ^ memberCount.hashCode ^ profilePictureUrl.hashCode; // NEW
}