import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:front/data/datasources/friendship_remote_data_source.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/domain/repositories/friendship_repository.dart';
import 'package:front/presentation/providers/friendship_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockFriendshipRepository extends Mock implements FriendshipRepository {}

class _MockFriendshipRemoteDataSource extends Mock
    implements FriendshipRemoteDataSource {}

void main() {
  late FriendshipRepository repository;
  late FriendshipRemoteDataSource remoteDataSource;

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
    remoteDataSource = _MockFriendshipRemoteDataSource();
  });

  test(
    'should return empty list when query length is lower than two characters',
    () async {
      final container = ProviderContainer(
        overrides: [friendshipRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final result = await container.read(searchUsersProvider('a').future);

      expect(result, isEmpty);
      verifyNever(() => repository.searchUsersByUsername(any()));
    },
  );

  test('should invalidate lists when send friend request succeeds', () async {
    when(
      () => repository.getFriends(),
    ).thenAnswer((_) async => const Right(<UserProfile>[profile]));
    when(
      () => repository.getPendingRequests(),
    ).thenAnswer((_) async => const Right(<FriendRequest>[]));
    when(
      () => repository.sendFriendRequest('2'),
    ).thenAnswer((_) async => Right(request));
    when(
      () => remoteDataSource.getOutgoingPendingRequestIds(),
    ).thenAnswer((_) async => <String>{});

    final container = ProviderContainer(
      overrides: [
        friendshipRepositoryProvider.overrideWithValue(repository),
        friendshipRemoteDataSourceProvider.overrideWithValue(remoteDataSource),
      ],
    );
    addTearDown(container.dispose);

    await container.read(friendsProvider.future);
    await container.read(pendingRequestsProvider.future);
    await container.read(outgoingPendingRequestIdsProvider.future);

    await container
        .read(friendshipActionsProvider.notifier)
        .sendFriendRequest('2');

    await container.read(friendsProvider.future);
    await container.read(pendingRequestsProvider.future);
    await container.read(outgoingPendingRequestIdsProvider.future);

    verify(() => repository.getFriends()).called(2);
    verify(() => repository.getPendingRequests()).called(2);
    verify(() => remoteDataSource.getOutgoingPendingRequestIds()).called(2);
  });

  test('should invalidate lists when respond to request succeeds', () async {
    when(
      () => repository.getFriends(),
    ).thenAnswer((_) async => const Right(<UserProfile>[profile]));
    when(
      () => repository.getPendingRequests(),
    ).thenAnswer((_) async => Right(<FriendRequest>[request]));
    when(
      () => repository.respondToRequest(
        'request-1',
        FriendRequestStatus.accepted,
      ),
    ).thenAnswer((_) async => Right(request));
    when(
      () => remoteDataSource.getOutgoingPendingRequestIds(),
    ).thenAnswer((_) async => <String>{});

    final container = ProviderContainer(
      overrides: [
        friendshipRepositoryProvider.overrideWithValue(repository),
        friendshipRemoteDataSourceProvider.overrideWithValue(remoteDataSource),
      ],
    );
    addTearDown(container.dispose);

    await container.read(friendsProvider.future);
    await container.read(pendingRequestsProvider.future);
    await container.read(outgoingPendingRequestIdsProvider.future);

    await container
        .read(friendshipActionsProvider.notifier)
        .respondToRequest('request-1', FriendRequestStatus.accepted);

    await container.read(friendsProvider.future);
    await container.read(pendingRequestsProvider.future);
    await container.read(outgoingPendingRequestIdsProvider.future);

    verify(() => repository.getFriends()).called(2);
    verify(() => repository.getPendingRequests()).called(2);
    verify(() => remoteDataSource.getOutgoingPendingRequestIds()).called(2);
  });
}
