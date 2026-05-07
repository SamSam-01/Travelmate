import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/domain/repositories/friendship_repository.dart';
import 'package:front/domain/usecases/send_friend_request_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockFriendshipRepository extends Mock implements FriendshipRepository {}

void main() {
  late FriendshipRepository repository;
  late SendFriendRequestUseCase useCase;

  const profile = UserProfile(
    id: '1',
    username: 'sam',
    displayName: 'Sam',
    avatarUrl: null,
    isPrivate: true,
  );
  final request = FriendRequest(
    id: 'request-1',
    requester: profile,
    addressee: profile,
    status: FriendRequestStatus.pending,
    createdAt: DateTime(2026),
  );

  setUp(() {
    repository = _MockFriendshipRepository();
    useCase = SendFriendRequestUseCase(repository);
  });

  test('should return request when repository succeeds', () async {
    when(
      () => repository.sendFriendRequest('2'),
    ).thenAnswer((_) async => Right(request));

    final result = await useCase('2');

    expect(result, Right<Failure, FriendRequest>(request));
  });

  test('should return failure when repository fails', () async {
    const failure = Failure('send failed');
    when(
      () => repository.sendFriendRequest('2'),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase('2');

    expect(result, const Left<Failure, FriendRequest>(failure));
  });
}
