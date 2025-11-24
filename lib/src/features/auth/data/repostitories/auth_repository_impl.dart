import 'package:translate/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:translate/src/features/auth/domain/entities/user_entity.dart';
import 'package:translate/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<UserEntity> signInWithGoogle() async {
    return await remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }
}