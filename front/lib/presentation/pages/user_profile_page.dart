import 'package:flutter/material.dart';
import 'package:front/core/constants/app_spacing.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/l10n/app_localizations.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profileTitle),
      ),
      body: Padding(
        padding: AppSpacing.pagePadding,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl),
              CircleAvatar(
                radius: 50,
                backgroundImage: profile.avatarUrl != null
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                profile.username,
                style: theme.textTheme.headlineMedium,
              ),
              if (profile.displayName != null &&
                  profile.displayName!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.displayName!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
