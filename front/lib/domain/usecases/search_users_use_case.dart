import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/domain/repositories/friendship_repository.dart';

class SearchUsersUseCase {
  const SearchUsersUseCase(this._repository);

  final FriendshipRepository _repository;

  Future<Either<Failure, List<UserProfile>>> call(String query) {
    return _repository.searchUsersByUsername(query);
  }
}
