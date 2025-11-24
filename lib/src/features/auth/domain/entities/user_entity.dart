import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final int points; // Added to support the profile UI

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    required this.points,
  });

  @override
  List<Object?> get props => [id, email, displayName, points];
}