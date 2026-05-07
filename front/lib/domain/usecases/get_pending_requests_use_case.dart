import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/domain/repositories/friendship_repository.dart';

class GetPendingRequestsUseCase {
  const GetPendingRequestsUseCase(this._repository);

  final FriendshipRepository _repository;

  Future<Either<Failure, List<FriendRequest>>> call() {
    return _repository.getPendingRequests();
  }
}
