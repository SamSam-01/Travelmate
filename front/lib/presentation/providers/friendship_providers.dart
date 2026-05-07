import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/datasources/friendship_remote_data_source.dart';
import 'package:front/data/models/profile_model.dart';
import 'package:front/data/repositories/friendship_repository_impl.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/domain/repositories/friendship_repository.dart';
import 'package:front/domain/usecases/get_friends_use_case.dart';
import 'package:front/domain/usecases/get_pending_requests_use_case.dart';
import 'package:front/domain/usecases/respond_to_friend_request_use_case.dart';
import 'package:front/domain/usecases/search_users_use_case.dart';
import 'package:front/domain/usecases/send_friend_request_use_case.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final friendshipRemoteDataSourceProvider = Provider<FriendshipRemoteDataSource>(
  (ref) {
    return FriendshipRemoteDataSource(ref.watch(supabaseClientProvider));
  },
);

final friendshipRepositoryProvider = Provider<FriendshipRepository>((ref) {
  return FriendshipRepositoryImpl(
    ref.watch(friendshipRemoteDataSourceProvider),
  );
});

final searchUsersUseCaseProvider = Provider<SearchUsersUseCase>((ref) {
  return SearchUsersUseCase(ref.watch(friendshipRepositoryProvider));
});

final sendFriendRequestUseCaseProvider = Provider<SendFriendRequestUseCase>(
  (ref) => SendFriendRequestUseCase(ref.watch(friendshipRepositoryProvider)),
);

final respondToFriendRequestUseCaseProvider =
    Provider<RespondToFriendRequestUseCase>((ref) {
      return RespondToFriendRequestUseCase(
        ref.watch(friendshipRepositoryProvider),
      );
    });

final getPendingRequestsUseCaseProvider = Provider<GetPendingRequestsUseCase>(
  (ref) => GetPendingRequestsUseCase(ref.watch(friendshipRepositoryProvider)),
);

final getFriendsUseCaseProvider = Provider<GetFriendsUseCase>(
  (ref) => GetFriendsUseCase(ref.watch(friendshipRepositoryProvider)),
);

final searchUsersProvider = FutureProvider.family<List<UserProfile>, String>((
  ref,
  query,
) async {
  if (query.trim().length < 2) {
    return const <UserProfile>[];
  }

  final result = await ref.watch(searchUsersUseCaseProvider).call(query);
  return result.match((failure) => throw Exception(failure.message), (data) {
    return data;
  });
});

final pendingRequestsProvider = FutureProvider<List<FriendRequest>>((
  ref,
) async {
  final result = await ref.watch(getPendingRequestsUseCaseProvider).call();
  return result.match((failure) => throw Exception(failure.message), (data) {
    return data;
  });
});

final friendsProvider = FutureProvider<List<UserProfile>>((ref) async {
  final result = await ref.watch(getFriendsUseCaseProvider).call();
  return result.match((failure) => throw Exception(failure.message), (data) {
    return data;
  });
});

final outgoingPendingRequestIdsProvider = FutureProvider<Set<String>>((
  ref,
) async {
  return ref
      .watch(friendshipRemoteDataSourceProvider)
      .getOutgoingPendingRequestIds();
});

final currentUserProfileProvider =
    AsyncNotifierProvider<CurrentUserProfileNotifier, ProfileModel>(
      CurrentUserProfileNotifier.new,
    );

final friendshipActionsProvider =
    AsyncNotifierProvider<FriendshipActionsNotifier, void>(
      FriendshipActionsNotifier.new,
    );

class CurrentUserProfileNotifier extends AsyncNotifier<ProfileModel> {
  @override
  Future<ProfileModel> build() {
    return ref
        .watch(friendshipRemoteDataSourceProvider)
        .getCurrentUserProfile();
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    state = const AsyncLoading<ProfileModel>();
    state = await AsyncValue.guard(
      () => ref
          .watch(friendshipRemoteDataSourceProvider)
          .updateCurrentUserProfile(profile),
    );
    return state.requireValue;
  }
}

class FriendshipActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> sendFriendRequest(String addresseeId) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .watch(sendFriendRequestUseCaseProvider)
          .call(addresseeId);
      result.match((failure) => throw Exception(failure.message), (_) => null);
    });
    _handleResultInvalidation();
  }

  Future<void> respondToRequest(
    String requestId,
    FriendRequestStatus status,
  ) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .watch(respondToFriendRequestUseCaseProvider)
          .call(requestId, status);
      result.match((failure) => throw Exception(failure.message), (_) => null);
    });
    _handleResultInvalidation();
  }

  void _handleResultInvalidation() {
    if (state.hasError) {
      return;
    }

    ref.invalidate(friendsProvider);
    ref.invalidate(pendingRequestsProvider);
    ref.invalidate(outgoingPendingRequestIdsProvider);
  }
}
