import 'package:flutter/material.dart';
import 'package:front/core/constants/app_spacing.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/styles/colors.dart';

class SocialProfileHeader extends StatelessWidget {
  const SocialProfileHeader({
    super.key,
    required this.profile,
    required this.friendsLabel,
    required this.requestsLabel,
    required this.visibilityLabel,
    required this.publicLabel,
    required this.privateLabel,
    required this.searchActionLabel,
    required this.editActionLabel,
    required this.onSearchPressed,
    required this.onEditPressed,
    this.friendCount,
    this.pendingRequestCount,
  });

  final UserProfile profile;
  final String friendsLabel;
  final String requestsLabel;
  final String visibilityLabel;
  final String publicLabel;
  final String privateLabel;
  final String searchActionLabel;
  final String editActionLabel;
  final VoidCallback onSearchPressed;
  final VoidCallback onEditPressed;
  final int? friendCount;
  final int? pendingRequestCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final privacyLabel = profile.isPrivate ? privateLabel : publicLabel;
    final displayTitle = profile.displayName ?? profile.username;
    final displaySubtitle = profile.displayName == null
        ? null
        : '@${profile.username}';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            CrazerColors.backgroundAlt,
            Color(0xFF123B54),
            Color(0xFF1B5E6C),
          ],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ProfileAvatar(
                  avatarUrl: profile.avatarUrl,
                  fallbackText: displayTitle,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        displayTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (displaySubtitle != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          displaySubtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: CrazerColors.glowSoft,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Text(
                          privacyLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: _StatPill(
                    label: friendsLabel,
                    value: _formatCount(friendCount),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatPill(
                    label: requestsLabel,
                    value: _formatCount(pendingRequestCount),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatPill(label: visibilityLabel, value: privacyLabel),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onSearchPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: CrazerColors.glowYellow,
                      foregroundColor: CrazerColors.background,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: Text(searchActionLabel),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEditPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.38),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(editActionLabel),
                  ),
                ),
              ],
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatarUrl, required this.fallbackText});

  final String? avatarUrl;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    final fallbackLetter = fallbackText.isEmpty
        ? '?'
        : fallbackText.characters.first.toUpperCase();

    return Container(
      width: 84,
      height: 84,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: <Color>[CrazerColors.glowYellow, CrazerColors.tropicalGreen],
        ),
      ),
      child: CircleAvatar(
        backgroundColor: CrazerColors.surface,
        backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
            ? NetworkImage(avatarUrl!)
            : null,
        child: avatarUrl == null || avatarUrl!.isEmpty
            ? Text(
                fallbackLetter,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: CrazerColors.glowSoft,
            ),
          ),
        ],
      ),
    );
  }
}
