import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/data/datasources/friendship_remote_data_source.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/domain/repositories/friendship_repository.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/presentation/pages/friends_page.dart';
import 'package:front/presentation/pages/user_search_page.dart';
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
    addressee: const UserProfile(
      id: '2',
      username: 'alex',
      displayName: 'Alex',
      avatarUrl: null,
      isPrivate: true,
    ),
    status: FriendRequestStatus.pending,
    createdAt: DateTime(2026),
  );

  setUp(() {
    repository = _MockFriendshipRepository();
    remoteDataSource = _MockFriendshipRemoteDataSource();
    when(
      () => remoteDataSource.getOutgoingPendingRequestIds(),
    ).thenAnswer((_) async => <String>{});
  });

  Widget buildApp(Widget child, {List<dynamic> overrides = const []}) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('should render friends and requests when providers return data', (
    tester,
  ) async {
    when(
      () => repository.getFriends(),
    ).thenAnswer((_) async => const Right(<UserProfile>[profile]));
    when(
      () => repository.getPendingRequests(),
    ).thenAnswer((_) async => Right(<FriendRequest>[request]));

    await tester.pumpWidget(
      buildApp(
        const FriendsPage(),
        overrides: [
          friendshipRepositoryProvider.overrideWithValue(repository),
          friendshipRemoteDataSourceProvider.overrideWithValue(
            remoteDataSource,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('sam'), findsOneWidget);
    await tester.tap(find.text('Demandes'));
    await tester.pumpAndSettle();
    expect(find.text('Demande de sam'), findsOneWidget);
  });

  testWidgets('should render error state when friends provider fails', (
    tester,
  ) async {
    when(
      () => repository.getFriends(),
    ).thenAnswer((_) async => const Left(Failure('boom')));
    when(
      () => repository.getPendingRequests(),
    ).thenAnswer((_) async => const Right(<FriendRequest>[]));

    await tester.pumpWidget(
      buildApp(
        const FriendsPage(),
        overrides: [
          friendshipRepositoryProvider.overrideWithValue(repository),
          friendshipRemoteDataSourceProvider.overrideWithValue(
            remoteDataSource,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('boom'), findsOneWidget);
  });

  testWidgets(
    'should not trigger search when query length is lower than two characters',
    (tester) async {
      when(
        () => repository.getFriends(),
      ).thenAnswer((_) async => const Right(<UserProfile>[]));
      when(
        () => repository.getPendingRequests(),
      ).thenAnswer((_) async => const Right(<FriendRequest>[]));

      await tester.pumpWidget(
        buildApp(
          const UserSearchPage(),
          overrides: [
            friendshipRepositoryProvider.overrideWithValue(repository),
            friendshipRemoteDataSourceProvider.overrideWithValue(
              remoteDataSource,
            ),
          ],
        ),
      );

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 450));

      verifyNever(() => repository.searchUsersByUsername(any()));
      expect(find.text('Saisissez au moins 2 caractères.'), findsOneWidget);
    },
  );

  testWidgets(
    'should show disabled friend action when user is already a friend',
    (tester) async {
      when(
        () => repository.getFriends(),
      ).thenAnswer((_) async => const Right(<UserProfile>[profile]));
      when(
        () => repository.getPendingRequests(),
      ).thenAnswer((_) async => const Right(<FriendRequest>[]));
      when(
        () => repository.searchUsersByUsername('sam'),
      ).thenAnswer((_) async => const Right(<UserProfile>[profile]));

      await tester.pumpWidget(
        buildApp(
          const UserSearchPage(),
          overrides: [
            friendshipRepositoryProvider.overrideWithValue(repository),
            friendshipRemoteDataSourceProvider.overrideWithValue(
              remoteDataSource,
            ),
          ],
        ),
      );

      await tester.enterText(find.byType(TextField), 'sam');
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      expect(find.text('Déjà ami'), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
    },
  );
}
