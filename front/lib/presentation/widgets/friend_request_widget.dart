import 'package:flutter/material.dart';
import 'package:front/core/constants/app_spacing.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:front/l10n/app_localizations.dart';

class FriendRequestWidget extends StatelessWidget {
  const FriendRequestWidget({
    super.key,
    required this.request,
    required this.isLoading,
    required this.onAccept,
    required this.onDecline,
  });

  final FriendRequest request;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

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
            Text(
              localizations.friendRequestFrom(request.requester.username),
              style: theme.textTheme.titleMedium,
            ),
            if (request.requester.displayName != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                request.requester.displayName!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onAccept,
                    child: Text(localizations.friendActionAccept),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onDecline,
                    child: Text(localizations.friendActionDecline),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
