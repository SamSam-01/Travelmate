import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/datasources/friendship_remote_data_source.dart';
import 'package:front/data/models/friend_request_model.dart';
import 'package:front/data/models/profile_model.dart';
import 'package:front/data/repositories/friendship_repository_impl.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockFriendshipRemoteDataSource extends Mock
    implements FriendshipRemoteDataSource {}

void main() {
  late FriendshipRemoteDataSource remoteDataSource;
  late FriendshipRepositoryImpl repository;

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
    remoteDataSource = _MockFriendshipRemoteDataSource();
    repository = FriendshipRepositoryImpl(remoteDataSource);
  });

  test('should return right when datasource search succeeds', () async {
    when(() => remoteDataSource.searchUsersByUsername('sa')).thenAnswer(
      (_) async => const <ProfileModel>[
        ProfileModel(
          id: '1',
          username: 'sam',
          displayName: 'Sam',
          avatarUrl: null,
          isPrivate: true,
        ),
      ],
    );

    final result = await repository.searchUsersByUsername('sa');

    expect(result.isRight(), isTrue);
  });

  test(
    'should return left when datasource search throws postgrest exception',
    () async {
      when(
        () => remoteDataSource.searchUsersByUsername('sa'),
      ).thenThrow(const PostgrestException(message: 'search failed'));

      final result = await repository.searchUsersByUsername('sa');

      expect(result.isLeft(), isTrue);
    },
  );

  test('should return right when datasource send succeeds', () async {
    when(() => remoteDataSource.sendFriendRequest('2')).thenAnswer(
      (_) async => FriendRequestModel(
        id: request.id,
        requester: const ProfileModel(
          id: '1',
          username: 'sam',
          displayName: 'Sam',
          avatarUrl: null,
          isPrivate: true,
        ),
        addressee: const ProfileModel(
          id: '1',
          username: 'sam',
          displayName: 'Sam',
          avatarUrl: null,
          isPrivate: true,
        ),
        status: request.status,
        createdAt: request.createdAt,
      ),
    );

    final result = await repository.sendFriendRequest('2');

    expect(result.isRight(), isTrue);
  });

  test(
    'should return left when datasource send throws auth exception',
    () async {
      when(
        () => remoteDataSource.sendFriendRequest('2'),
      ).thenThrow(const AuthException('auth failed'));

      final result = await repository.sendFriendRequest('2');

      expect(result.isLeft(), isTrue);
    },
  );
}
