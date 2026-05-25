import 'package:flutter/material.dart';
import 'package:front/core/constants/app_spacing.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/presentation/widgets/friend_list_profile_card.dart';

class FriendProfilePage extends StatelessWidget {
  const FriendProfilePage({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final title = profile.displayName ?? profile.username;
    final privacyLabel = profile.isPrivate
        ? localizations.searchResultPrivate
        : localizations.searchResultPublic;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.profileTitle)),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          Card(
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: profile.avatarUrl != null &&
                                profile.avatarUrl!.isNotEmpty
                            ? NetworkImage(profile.avatarUrl!)
                            : null,
                        child: profile.avatarUrl == null ||
                                profile.avatarUrl!.isEmpty
                            ? Text(
                                title.isEmpty
                                    ? '?'
                                    : title.characters.first.toUpperCase(),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '@${profile.username}',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _InfoRow(
                    label: localizations.profileTitle,
                    value: title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow(
                    label: localizations.profileUsername,
                    value: '@${profile.username}',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow(
                    label: localizations.profilePrivate,
                    value: privacyLabel,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            localizations.friendsTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FriendListProfileCard(
            profile: profile,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
