import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/domain/repositories/friendship_repository.dart';

class RespondToFriendRequestUseCase {
  const RespondToFriendRequestUseCase(this._repository);

  final FriendshipRepository _repository;

  Future<Either<Failure, FriendRequest>> call(
    String requestId,
    FriendRequestStatus status,
  ) {
    return _repository.respondToRequest(requestId, status);
  }
}
