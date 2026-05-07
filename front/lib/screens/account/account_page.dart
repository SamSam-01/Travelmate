import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/models/profile_model.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/main.dart';
import 'package:front/presentation/providers/friendship_providers.dart';
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
      context.showSnackBar(error.toString(), isError: true);
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
      if (!mounted) return;
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
      if (mounted) context.showSnackBar(error.message, isError: true);
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
    final isSaving = profileAsync.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.profileTitle)),
      body: profileAsync.when(
        data: (profile) {
          _syncProfile(profile);

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: localizations.profileUsername,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: localizations.profileDisplayName,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _avatarUrlController,
                decoration: InputDecoration(
                  labelText: localizations.profileAvatarUrl,
                ),
              ),
              const SizedBox(height: 18),
              SwitchListTile(
                value: _isPrivate,
                onChanged: (value) => setState(() => _isPrivate = value),
                title: Text(localizations.profilePrivate),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: isSaving ? null : () => _updateProfile(profile),
                child: Text(
                  isSaving
                      ? localizations.profileSaving
                      : localizations.profileUpdate,
                ),
              ),
              const SizedBox(height: 18),
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
