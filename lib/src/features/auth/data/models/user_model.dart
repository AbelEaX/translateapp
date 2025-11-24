import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.displayName,
    required super.points,
  });

  // Factory constructor to create a UserModel from a Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    // The document ID is the user's ID
    final id = doc.id;

    // Extract fields, providing sensible defaults/type checks
    final email = data?['email'] as String?;
    final displayName = data?['displayName'] as String?;
    // Ensure 'points' is safely extracted and defaults to 0
    final points = (data?['points'] is int) ? data!['points'] as int : 0;

    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      points: points,
    );
  }
}