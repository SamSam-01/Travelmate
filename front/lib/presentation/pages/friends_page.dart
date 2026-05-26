import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_spacing.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/presentation/pages/user_search_page.dart';
import 'package:front/presentation/providers/friendship_providers.dart';
import 'package:front/presentation/widgets/friend_request_widget.dart';

class FriendsPage extends ConsumerWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final actionsState = ref.watch(friendshipActionsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.friendsTitle),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserSearchPage()),
                );
              },
              icon: const Icon(Icons.person_add_alt_1_outlined),
              tooltip: localizations.friendsSearchAction,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: localizations.friendsTab),
              Tab(text: localizations.requestsTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _FriendsTab(friendsAsync: ref.watch(friendsProvider)),
            _RequestsTab(
              requestsAsync: ref.watch(pendingRequestsProvider),
              isLoadingAction: actionsState.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsTab extends StatelessWidget {
  const _FriendsTab({required this.friendsAsync});

  final AsyncValue<List<UserProfile>> friendsAsync;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
          return _EmptyState(message: localizations.friendsListEmpty);
        }

        return ListView.separated(
          padding: AppSpacing.pagePadding,
          itemCount: friends.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final friend = friends[index];
            return Card(
              child: ListTile(
                title: Text(friend.username),
                subtitle: friend.displayName == null
                    ? null
                    : Text(friend.displayName!),
              ),
            );
          },
        );
      },
      error: (error, _) => _ErrorState(message: error.toString()),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _RequestsTab extends ConsumerWidget {
  const _RequestsTab({
    required this.requestsAsync,
    required this.isLoadingAction,
  });

  final AsyncValue<List<FriendRequest>> requestsAsync;
  final bool isLoadingAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return _EmptyState(message: localizations.requestsListEmpty);
        }

        return ListView.separated(
          padding: AppSpacing.pagePadding,
          itemCount: requests.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final request = requests[index];
            return FriendRequestWidget(
              request: request,
              isLoading: isLoadingAction,
              onAccept: () => _handleResponse(
                context,
                ref,
                request.id,
                FriendRequestStatus.accepted,
              ),
              onDecline: () => _handleResponse(
                context,
                ref,
                request.id,
                FriendRequestStatus.declined,
              ),
            );
          },
        );
      },
      error: (error, _) => _ErrorState(message: error.toString()),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _handleResponse(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    FriendRequestStatus status,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;

    try {
      await ref
          .read(friendshipActionsProvider.notifier)
          .respondToRequest(requestId, status);
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            status == FriendRequestStatus.accepted
                ? localizations.friendRequestAcceptedSuccess
                : localizations.friendRequestDeclinedSuccess,
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
