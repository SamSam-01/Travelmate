import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_spacing.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/main.dart';
import 'package:front/presentation/pages/friends_page.dart';
import 'package:front/presentation/pages/user_search_page.dart';
import 'package:front/presentation/providers/friendship_providers.dart';
import 'package:front/screens.dart';
import 'package:front/screens/account/edit_profile_page.dart';
import 'package:front/screens/account/widgets/profile_sections.dart';
import 'package:front/screens/account/widgets/social_profile_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key, this.requireSession = true});

  final bool requireSession;

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
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

  void _openUserSearch() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const UserSearchPage()));
  }

  void _openFriendsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FriendsPage(initialTabIndex: 0)),
    );
  }

  void _openRequestsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FriendsPage(initialTabIndex: 1)),
    );
  }

  void _openEditProfilePage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const EditProfilePage()));
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

  String _formatCount(int? count) {
    if (count == null) {
      return '...';
    }
    return count.toString();
  }

  String _friendSubtitle(AppLocalizations localizations, int? count) {
    if (count == null) {
      return localizations.loading;
    }
    if (count == 0) {
      return localizations.friendsListEmpty;
    }
    return localizations.friendsTab;
  }

  String _requestSubtitle(AppLocalizations localizations, int? count) {
    if (count == null) {
      return localizations.loading;
    }
    if (count == 0) {
      return localizations.requestsListEmpty;
    }
    return localizations.requestsTab;
  }

  String _editSubtitle(AppLocalizations localizations) {
    return '${localizations.profileUsername} • '
        '${localizations.profileDisplayName}';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profileTitle),
        actions: [
          IconButton(
            onPressed: _openEditProfilePage,
            icon: const Icon(Icons.edit_outlined),
            tooltip: localizations.profileUpdate,
          ),
          IconButton(
            onPressed: _openUserSearch,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            tooltip: localizations.friendsSearchAction,
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          final friendCount = friendsAsync.valueOrNull?.length;
          final requestCount = pendingRequestsAsync.valueOrNull?.length;

          return ListView(
            padding: AppSpacing.pagePadding,
            children: [
              SocialProfileHeader(
                profile: profile,
                friendsLabel: localizations.friendsTitle,
                requestsLabel: localizations.requestsTab,
                visibilityLabel: localizations.profilePrivate,
                publicLabel: localizations.searchResultPublic,
                privateLabel: localizations.searchResultPrivate,
                searchActionLabel: localizations.friendsSearchAction,
                editActionLabel: localizations.profileUpdate,
                onSearchPressed: _openUserSearch,
                onEditPressed: _openEditProfilePage,
                friendCount: friendCount,
                pendingRequestCount: requestCount,
              ),
              const SizedBox(height: AppSpacing.xl),
              ProfileSectionTitle(title: localizations.profileTitle),
              const SizedBox(height: AppSpacing.md),
              ProfileNavigationCard(
                icon: Icons.edit_outlined,
                title: localizations.profileUpdate,
                subtitle: _editSubtitle(localizations),
                value: '',
                onTap: _openEditProfilePage,
              ),
              const SizedBox(height: AppSpacing.md),
              ProfileNavigationCard(
                icon: Icons.people_outline,
                title: localizations.friendsTitle,
                subtitle: _friendSubtitle(localizations, friendCount),
                value: _formatCount(friendCount),
                onTap: _openFriendsPage,
              ),
              const SizedBox(height: AppSpacing.md),
              ProfileNavigationCard(
                icon: Icons.mark_email_unread_outlined,
                title: localizations.requestsTab,
                subtitle: _requestSubtitle(localizations, requestCount),
                value: _formatCount(requestCount),
                onTap: _openRequestsPage,
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
