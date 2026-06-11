import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_durations.dart';
import 'package:front/core/constants/app_spacing.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/presentation/providers/friendship_providers.dart';
import 'package:front/presentation/widgets/user_search_result_widget.dart';

class UserSearchPage extends ConsumerStatefulWidget {
  const UserSearchPage({super.key});

  @override
  ConsumerState<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends ConsumerState<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String _debouncedQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
    });

    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppDurations.searchDebounceMs),
      () {
        if (!mounted) {
          return;
        }
        setState(() {
          _debouncedQuery = value.trim();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final searchAsync = ref.watch(searchUsersProvider(_debouncedQuery));
    final friendsAsync = ref.watch(friendsProvider);
    final pendingRequestsAsync = ref.watch(pendingRequestsProvider);
    final outgoingPendingAsync = ref.watch(outgoingPendingRequestIdsProvider);
    final actionsState = ref.watch(friendshipActionsProvider);

    final friendIds =
        friendsAsync.value?.map((profile) => profile.id).toSet() ?? <String>{};
    final incomingIds =
        pendingRequestsAsync.value
            ?.map((request) => request.requester.id)
            .toSet() ??
        <String>{};
    final outgoingIds = outgoingPendingAsync.value ?? <String>{};

    return Scaffold(
      appBar: AppBar(title: Text(localizations.friendsSearchTitle)),
      body: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                labelText: localizations.friendsSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _query.trim().length < 2
                  ? Center(child: Text(localizations.friendsSearchHelper))
                  : searchAsync.when(
                      data: (profiles) {
                        if (profiles.isEmpty) {
                          return Center(
                            child: Text(localizations.friendsSearchEmpty),
                          );
                        }

                        return ListView.separated(
                          itemCount: profiles.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final profile = profiles[index];
                            final relationState = _resolveRelationState(
                              profile: profile,
                              friendIds: friendIds,
                              incomingIds: incomingIds,
                              outgoingIds: outgoingIds,
                            );

                            return UserSearchResultWidget(
                              profile: profile,
                              buttonLabel: _buttonLabel(
                                localizations,
                                relationState,
                              ),
                              isActionEnabled:
                                  relationState == _SearchRelationState.none,
                              isLoading: actionsState.isLoading,
                              onPressed: () =>
                                  _sendFriendRequest(context, profile.id),
                            );
                          },
                        );
                      },
                      error: (error, _) =>
                          Center(child: Text(error.toString())),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _SearchRelationState _resolveRelationState({
    required UserProfile profile,
    required Set<String> friendIds,
    required Set<String> incomingIds,
    required Set<String> outgoingIds,
  }) {
    if (friendIds.contains(profile.id)) {
      return _SearchRelationState.friends;
    }
    if (outgoingIds.contains(profile.id)) {
      return _SearchRelationState.pendingOutgoing;
    }
    if (incomingIds.contains(profile.id)) {
      return _SearchRelationState.pendingIncoming;
    }
    return _SearchRelationState.none;
  }

  String _buttonLabel(
    AppLocalizations localizations,
    _SearchRelationState relationState,
  ) {
    switch (relationState) {
      case _SearchRelationState.friends:
        return localizations.friendActionFriends;
      case _SearchRelationState.pendingOutgoing:
        return localizations.friendActionPending;
      case _SearchRelationState.pendingIncoming:
        return localizations.friendActionRequestReceived;
      case _SearchRelationState.none:
        return localizations.friendActionSend;
    }
  }

  Future<void> _sendFriendRequest(
    BuildContext context,
    String addresseeId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;

    try {
      await ref
          .read(friendshipActionsProvider.notifier)
          .sendFriendRequest(addresseeId);
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(localizations.friendRequestSentSuccess)),
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

enum _SearchRelationState { none, pendingOutgoing, pendingIncoming, friends }
