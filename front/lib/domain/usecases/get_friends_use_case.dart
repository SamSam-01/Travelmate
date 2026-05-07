import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/domain/repositories/friendship_repository.dart';

class GetFriendsUseCase {
  const GetFriendsUseCase(this._repository);

  final FriendshipRepository _repository;

  Future<Either<Failure, List<UserProfile>>> call() {
    return _repository.getFriends();
  }
}
