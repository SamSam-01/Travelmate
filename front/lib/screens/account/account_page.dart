import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_spacing.dart';
import 'package:front/data/models/profile_model.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/main.dart';
import 'package:front/presentation/pages/user_search_page.dart';
import 'package:front/presentation/providers/friendship_providers.dart';
import 'package:front/presentation/widgets/friend_request_widget.dart';
import 'package:front/screens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key, this.requireSession = true});

  final bool requireSession;

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  bool _isPrivate = true;
  String? _lastProfileSignature;

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile(ProfileModel profile) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final updatedProfile = await ref
          .read(currentUserProfileProvider.notifier)
          .updateProfile(
            profile.copyWith(
              username: _usernameController.text.trim().toLowerCase(),
              displayName: _displayNameController.text.trim().isEmpty
                  ? null
                  : _displayNameController.text.trim(),
              avatarUrl: _avatarUrlController.text.trim().isEmpty
                  ? null
                  : _avatarUrlController.text.trim(),
              isPrivate: _isPrivate,
            ),
          );

      _applyProfile(updatedProfile);
      if (!mounted) {
        return;
      }
      context.showSnackBar(localizations.profileUpdatedSuccess);
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showSnackBar(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  void _applyProfile(ProfileModel profile) {
    _usernameController.text = profile.username;
    _displayNameController.text = profile.displayName ?? '';
    _avatarUrlController.text = profile.avatarUrl ?? '';
    _isPrivate = profile.isPrivate;
  }

  void _syncProfile(ProfileModel profile) {
    final signature = [
      profile.id,
      profile.username,
      profile.displayName ?? '',
      profile.avatarUrl ?? '',
      profile.isPrivate.toString(),
    ].join('|');

    if (signature == _lastProfileSignature) {
      return;
    }

    _applyProfile(profile);
    _lastProfileSignature = signature;
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil(Screens.login, (_) => false);
    });
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      if (mounted) {
        context.showSnackBar(error.message, isError: true);
      }
    } catch (_) {
      if (mounted) {
        context.showSnackBar(
          AppLocalizations.of(context)!.loginUnexpectedError,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil(Screens.login, (_) => false);
      }
    }
  }

  Future<void> _respondToRequest(
    String requestId,
    FriendRequestStatus status,
  ) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      await ref
          .read(friendshipActionsProvider.notifier)
          .respondToRequest(requestId, status);
      if (!mounted) {
        return;
      }
      context.showSnackBar(
        status == FriendRequestStatus.accepted
            ? localizations.friendRequestAcceptedSuccess
            : localizations.friendRequestDeclinedSuccess,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showSnackBar(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final session = supabase.auth.currentSession;

    if (session == null) {
      if (widget.requireSession) {
        _redirectToLogin();
      }
      return Scaffold(
        appBar: AppBar(title: Text(localizations.profileTitle)),
        body: Center(child: Text(localizations.profileLoginRequired)),
      );
    }

    final profileAsync = ref.watch(currentUserProfileProvider);
    final friendsAsync = ref.watch(friendsProvider);
    final pendingRequestsAsync = ref.watch(pendingRequestsProvider);
    final actionsState = ref.watch(friendshipActionsProvider);
    final isSaving = profileAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profileTitle),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const UserSearchPage()));
            },
            icon: const Icon(Icons.person_add_alt_1_outlined),
            tooltip: localizations.friendsSearchAction,
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          _syncProfile(profile);

          return ListView(
            padding: AppSpacing.pagePadding,
            children: [
              _SectionTitle(title: localizations.profileTitle),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: localizations.profileUsername,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _displayNameController,
                        decoration: InputDecoration(
                          labelText: localizations.profileDisplayName,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _avatarUrlController,
                        decoration: InputDecoration(
                          labelText: localizations.profileAvatarUrl,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _isPrivate,
                        onChanged: (value) =>
                            setState(() => _isPrivate = value),
                        title: Text(localizations.profilePrivate),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () => _updateProfile(profile),
                          child: Text(
                            isSaving
                                ? localizations.profileSaving
                                : localizations.profileUpdate,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(title: localizations.friendsTitle),
              const SizedBox(height: AppSpacing.md),
              _FriendsPreview(friendsAsync: friendsAsync),
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(title: localizations.requestsTab),
              const SizedBox(height: AppSpacing.md),
              _PendingRequestsPreview(
                requestsAsync: pendingRequestsAsync,
                isLoadingAction: actionsState.isLoading,
                onRespond: _respondToRequest,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: _signOut,
                child: Text(localizations.profileSignOut),
              ),
            ],
          );
        },
        error: (error, _) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _FriendsPreview extends StatelessWidget {
  const _FriendsPreview({required this.friendsAsync});

  final AsyncValue<List<UserProfile>> friendsAsync;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
          return _EmptyCard(message: localizations.friendsListEmpty);
        }

        return Column(
          children: [
            for (var index = 0; index < friends.length; index++) ...[
              Card(
                child: ListTile(
                  title: Text(friends[index].username),
                  subtitle: friends[index].displayName == null
                      ? null
                      : Text(friends[index].displayName!),
                ),
              ),
              if (index < friends.length - 1)
                const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
      },
      error: (error, _) => _EmptyCard(message: error.toString()),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _PendingRequestsPreview extends StatelessWidget {
  const _PendingRequestsPreview({
    required this.requestsAsync,
    required this.isLoadingAction,
    required this.onRespond,
  });

  final AsyncValue<List<FriendRequest>> requestsAsync;
  final bool isLoadingAction;
  final Future<void> Function(String requestId, FriendRequestStatus status)
  onRespond;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return _EmptyCard(message: localizations.requestsListEmpty);
        }

        return Column(
          children: [
            for (var index = 0; index < requests.length; index++) ...[
              FriendRequestWidget(
                request: requests[index],
                isLoading: isLoadingAction,
                onAccept: () =>
                    onRespond(requests[index].id, FriendRequestStatus.accepted),
                onDecline: () =>
                    onRespond(requests[index].id, FriendRequestStatus.declined),
              ),
              if (index < requests.length - 1)
                const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
      },
      error: (error, _) => _EmptyCard(message: error.toString()),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
