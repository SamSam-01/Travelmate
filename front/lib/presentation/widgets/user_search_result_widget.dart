import 'package:flutter/material.dart';
import 'package:front/core/constants/app_spacing.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/l10n/app_localizations.dart';

class UserSearchResultWidget extends StatelessWidget {
  const UserSearchResultWidget({
    super.key,
    required this.profile,
    required this.buttonLabel,
    required this.isActionEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  final UserProfile profile;
  final String buttonLabel;
  final bool isActionEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.username, style: theme.textTheme.titleMedium),
            if (profile.displayName != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(profile.displayName!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              profile.isPrivate
                  ? localizations.searchResultPrivate
                  : localizations.searchResultPublic,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isActionEnabled && !isLoading ? onPressed : null,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
