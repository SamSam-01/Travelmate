import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_spacing.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/presentation/providers/outing_providers.dart';
import 'package:front/presentation/widgets/planned_outing_card.dart';

class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key, required this.profile});

  final UserProfile profile;

  String _formatCreatedAt(DateTime? createdAt) {
    if (createdAt == null) {
      return 'Créée récemment';
    }

    final date = createdAt.toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return 'Créée le $day/$month/${date.year} à $hour:$minute';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sharedOutingsAsync = ref.watch(sharedOutingsProvider(profile.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profileTitle),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
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
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Activités en commun',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ),
          sharedOutingsAsync.when(
            data: (outings) {
              if (outings.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.pagePadding,
                    child: Center(
                      child: Text(
                        'Aucune activité en cours avec cette personne.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: AppSpacing.pagePadding,
                sliver: SliverList.separated(
                  itemCount: outings.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final outing = outings[index];
                    return PlannedOutingCard(
                      outing: outing,
                      createdAtLabel: _formatCreatedAt(outing.createdAt),
                    );
                  },
                ),
              );
            },
            error: (error, _) => SliverToBoxAdapter(
              child: Center(child: Text(error.toString())),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
