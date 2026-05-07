import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/domain/entities/user_profile.dart';

abstract class FriendshipRepository {
  Future<Either<Failure, List<UserProfile>>> searchUsersByUsername(
    String query,
  );

  Future<Either<Failure, FriendRequest>> sendFriendRequest(String addresseeId);

  Future<Either<Failure, FriendRequest>> respondToRequest(
    String requestId,
    FriendRequestStatus status,
  );

  Future<Either<Failure, List<FriendRequest>>> getPendingRequests();

  Future<Either<Failure, List<UserProfile>>> getFriends();
}
