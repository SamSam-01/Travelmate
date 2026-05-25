import 'package:flutter/material.dart';
import 'package:front/core/constants/app_spacing.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/l10n/app_localizations.dart';

class FriendListProfileCard extends StatelessWidget {
  const FriendListProfileCard({
    super.key,
    required this.profile,
    required this.onTap,
  });

  final UserProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final title = profile.displayName ?? profile.username;
    final privacyLabel = profile.isPrivate
        ? localizations.searchResultPrivate
        : localizations.searchResultPublic;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Row(
            children: [
              _FriendAvatar(profile: profile),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '@${profile.username}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      privacyLabel,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final fallback = (profile.displayName ?? profile.username);
    final letter = fallback.isEmpty ? '?' : fallback.characters.first;

    return CircleAvatar(
      radius: 28,
      backgroundImage:
          profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
          ? NetworkImage(profile.avatarUrl!)
          : null,
      child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
          ? Text(
              letter.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}
