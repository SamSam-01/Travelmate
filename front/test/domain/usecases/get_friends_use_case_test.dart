import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/domain/repositories/friendship_repository.dart';
import 'package:front/domain/usecases/get_friends_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockFriendshipRepository extends Mock implements FriendshipRepository {}

void main() {
  late FriendshipRepository repository;
  late GetFriendsUseCase useCase;

  const profiles = <UserProfile>[
    UserProfile(
      id: '1',
      username: 'sam',
      displayName: 'Sam',
      avatarUrl: null,
      isPrivate: true,
    ),
  ];

  setUp(() {
    repository = _MockFriendshipRepository();
    useCase = GetFriendsUseCase(repository);
  });

  test('should return friends when repository succeeds', () async {
    when(
      () => repository.getFriends(),
    ).thenAnswer((_) async => const Right(profiles));

    final result = await useCase();

    expect(result, const Right<Failure, List<UserProfile>>(profiles));
  });

  test('should return failure when repository fails', () async {
    const failure = Failure('friends failed');
    when(
      () => repository.getFriends(),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase();

    expect(result, const Left<Failure, List<UserProfile>>(failure));
  });
}
