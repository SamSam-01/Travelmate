import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/domain/repositories/friendship_repository.dart';
import 'package:front/domain/usecases/search_users_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockFriendshipRepository extends Mock implements FriendshipRepository {}

void main() {
  late FriendshipRepository repository;
  late SearchUsersUseCase useCase;

  setUp(() {
    repository = _MockFriendshipRepository();
    useCase = SearchUsersUseCase(repository);
  });

  test('should return profiles when repository succeeds', () async {
    const profiles = <UserProfile>[
      UserProfile(
        id: '1',
        username: 'sam',
        displayName: 'Sam',
        avatarUrl: null,
        isPrivate: true,
      ),
    ];
    when(
      () => repository.searchUsersByUsername('sa'),
    ).thenAnswer((_) async => const Right(profiles));

    final result = await useCase('sa');

    expect(result, const Right<Failure, List<UserProfile>>(profiles));
  });

  test('should return failure when repository fails', () async {
    const failure = Failure('search failed');
    when(
      () => repository.searchUsersByUsername('sa'),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase('sa');

    expect(result, const Left<Failure, List<UserProfile>>(failure));
  });
}
