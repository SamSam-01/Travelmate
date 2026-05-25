import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_spacing.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/presentation/pages/friend_profile_page.dart';
import 'package:front/presentation/pages/user_search_page.dart';
import 'package:front/presentation/providers/friendship_providers.dart';
import 'package:front/presentation/widgets/friend_list_profile_card.dart';
import 'package:front/presentation/widgets/friend_request_widget.dart';

class FriendsPage extends ConsumerWidget {
  const FriendsPage({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final actionsState = ref.watch(friendshipActionsProvider);
    final friendsAsync = ref.watch(friendsProvider);
    final requestsAsync = ref.watch(pendingRequestsProvider);
    final friendCount = friendsAsync.valueOrNull?.length;
    final requestCount = requestsAsync.valueOrNull?.length;

    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.friendsTitle),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserSearchPage()),
              ),
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
        body: Column(
          children: [
            Padding(
              padding: AppSpacing.pagePadding,
              child: _FriendsOverviewCard(
                friendsTitle: localizations.friendsTitle,
                requestsTitle: localizations.requestsTab,
                searchActionLabel: localizations.friendsSearchAction,
                friendCount: _formatCount(friendCount),
                requestCount: _formatCount(requestCount),
                onSearchPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserSearchPage()),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _FriendsTab(friendsAsync: friendsAsync),
                  _RequestsTab(
                    requestsAsync: requestsAsync,
                    isLoadingAction: actionsState.isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int? count) {
    if (count == null) {
      return '...';
    }
    return count.toString();
  }
}

class _FriendsOverviewCard extends StatelessWidget {
  const _FriendsOverviewCard({
    required this.friendsTitle,
    required this.requestsTitle,
    required this.searchActionLabel,
    required this.friendCount,
    required this.requestCount,
    required this.onSearchPressed,
  });

  final String friendsTitle;
  final String requestsTitle;
  final String searchActionLabel;
  final String friendCount;
  final String requestCount;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              friendsTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _OverviewStat(label: friendsTitle, value: friendCount),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _OverviewStat(
                    label: requestsTitle,
                    value: requestCount,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSearchPressed,
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: Text(searchActionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: theme.textTheme.bodySmall),
        ],
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
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final friend = friends[index];
            return FriendListProfileCard(
              profile: friend,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FriendProfilePage(profile: friend),
                ),
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
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final request = requests[index];
            return FriendRequestWidget(
              request: request,
              isLoading: isLoadingAction,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FriendProfilePage(
                    profile: request.requester,
                  ),
                ),
              ),
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
