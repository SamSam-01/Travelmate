import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/data/datasources/friendship_remote_data_source.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/domain/repositories/friendship_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendshipRepositoryImpl implements FriendshipRepository {
  const FriendshipRepositoryImpl(this._remoteDataSource);

  final FriendshipRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<UserProfile>>> getFriends() async {
    return _run(_remoteDataSource.getFriends);
  }

  @override
  Future<Either<Failure, List<FriendRequest>>> getPendingRequests() async {
    return _run(_remoteDataSource.getPendingRequests);
  }

  @override
  Future<Either<Failure, FriendRequest>> respondToRequest(
    String requestId,
    FriendRequestStatus status,
  ) async {
    return _run(() => _remoteDataSource.respondToRequest(requestId, status));
  }

  @override
  Future<Either<Failure, List<UserProfile>>> searchUsersByUsername(
    String query,
  ) async {
    return _run(() => _remoteDataSource.searchUsersByUsername(query));
  }

  @override
  Future<Either<Failure, FriendRequest>> sendFriendRequest(
    String addresseeId,
  ) async {
    return _run(() => _remoteDataSource.sendFriendRequest(addresseeId));
  }

  Future<Either<Failure, T>> _run<T>(Future<T> Function() action) async {
    try {
      return right(await action());
    } on PostgrestException catch (error) {
      return left(Failure(error.message));
    } on AuthException catch (error) {
      return left(Failure(error.message));
    } catch (_) {
      return const Left(Failure('Unexpected repository error.'));
    }
  }
}
