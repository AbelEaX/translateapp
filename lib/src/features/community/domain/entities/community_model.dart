import 'package:flutter/material.dart';

/// Domain entity representing a local language community.
/// Pure Dart — no Firebase imports.
/// Firestore serialisation lives in `data/models/community_model.dart`.
@immutable
class Community {
  final String id;
  final String name;
  final String description;
  final String adminId;
  final bool isJoined;
  final int memberCount;
  final String languageCode;
  final String? profilePictureUrl;

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

  /// Factory constructor from plain JSON (non-Firestore use, e.g. tests or API mock).
  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      name: json['name'] as String,
      description:
          json['description'] as String? ??
          'A community for local language enthusiasts.',
      adminId: json['adminId'] as String? ?? 'system',
      isJoined: json['isJoined'] as bool? ?? false,
      memberCount: json['memberCount'] as int? ?? 0,
      languageCode: json['languageCode'] as String? ?? 'en',
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

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
