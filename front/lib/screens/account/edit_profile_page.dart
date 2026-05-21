import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_spacing.dart';
import 'package:front/data/models/profile_model.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/main.dart';
import 'package:front/presentation/providers/friendship_providers.dart';
import 'package:front/screens/account/widgets/profile_edit_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
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

  Future<void> _updateProfile(ProfileModel profile) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      await ref.read(currentUserProfileProvider.notifier).updateProfile(
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

      if (!mounted) {
        return;
      }
      context.showSnackBar(localizations.profileUpdatedSuccess);
      Navigator.of(context).pop();
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
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.profileUpdate)),
        body: Center(child: Text(localizations.profileLoginRequired)),
      );
    }

    final profileAsync = ref.watch(currentUserProfileProvider);
    final isSaving = profileAsync.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.profileUpdate)),
      body: profileAsync.when(
        data: (profile) {
          _syncProfile(profile);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              ProfileEditCard(
                title: localizations.profileTitle,
                usernameLabel: localizations.profileUsername,
                displayNameLabel: localizations.profileDisplayName,
                avatarUrlLabel: localizations.profileAvatarUrl,
                privateLabel: localizations.profilePrivate,
                submitLabel: isSaving
                    ? localizations.profileSaving
                    : localizations.profileUpdate,
                usernameController: _usernameController,
                displayNameController: _displayNameController,
                avatarUrlController: _avatarUrlController,
                isPrivate: _isPrivate,
                isSaving: isSaving,
                onPrivateChanged: (value) => setState(() => _isPrivate = value),
                onSubmit: () => _updateProfile(profile),
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
