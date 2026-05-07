import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/domain/repositories/friendship_repository.dart';
import 'package:front/domain/usecases/get_pending_requests_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockFriendshipRepository extends Mock implements FriendshipRepository {}

void main() {
  late FriendshipRepository repository;
  late GetPendingRequestsUseCase useCase;

  const profile = UserProfile(
    id: '1',
    username: 'sam',
    displayName: 'Sam',
    avatarUrl: null,
    isPrivate: true,
  );
  final requests = <FriendRequest>[
    FriendRequest(
      id: 'request-1',
      requester: profile,
      addressee: profile,
      status: FriendRequestStatus.pending,
      createdAt: DateTime(2026),
    ),
  ];

  setUp(() {
    repository = _MockFriendshipRepository();
    useCase = GetPendingRequestsUseCase(repository);
  });

  test('should return requests when repository succeeds', () async {
    when(
      () => repository.getPendingRequests(),
    ).thenAnswer((_) async => Right(requests));

    final result = await useCase();

    expect(result, Right<Failure, List<FriendRequest>>(requests));
  });

  test('should return failure when repository fails', () async {
    const failure = Failure('pending failed');
    when(
      () => repository.getPendingRequests(),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase();

    expect(result, const Left<Failure, List<FriendRequest>>(failure));
  });
}
