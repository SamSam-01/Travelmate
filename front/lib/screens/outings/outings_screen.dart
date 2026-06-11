import 'package:front/commons.dart';
import 'package:front/main.dart';
import 'package:front/models/activity_model.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/main.dart';
import 'package:front/screens/outings/create_outing_flow_screen.dart';
import 'package:front/services/activity_service.dart';
import 'package:front/services/planned_outing_service.dart';
import 'package:front/services/user_service.dart';
import 'package:front/presentation/widgets/planned_outing_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OutingsScreen extends StatefulWidget {
  const OutingsScreen({super.key});

  @override
  State<OutingsScreen> createState() => _OutingsScreenState();
}

class _OutingsScreenState extends State<OutingsScreen> {
  final _activityService = const ActivityService();
  final _plannedOutingService = const PlannedOutingService();
  final _userService = const UserService();

  late Future<_OutingsData> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  Future<_OutingsData> _loadData() async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      final results = await Future.wait([
        _plannedOutingService.fetchPlannedOutings(
          currentUserId: currentUserId ?? '',
        ),
        _userService.fetchUsers(),
        _activityService.fetchActivities(),
      ]);

      final outings = results[0] as List<PlannedOuting>;

      return _OutingsData(
        outings: outings,
        users: results[1] as List<PlannedOutingUser>,
        activities: results[2] as List<Activity>,
      );
    } on PostgrestException catch (error) {
      throw _OutingsLoadException(error.message);
    } catch (_) {
      throw const _OutingsLoadException(
        'Impossible de charger les sorties planifiées.',
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _futureData = _loadData();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).snackBarTheme.backgroundColor,
      ),
    );
  }

  Future<void> _openCreateFlow(_OutingsData data) async {
    final createdOuting = await Navigator.of(context).push<PlannedOuting>(
      MaterialPageRoute(
        builder: (_) => CreateOutingFlowScreen(
          users: data.users,
          activities: data.activities,
        ),
      ),
    );

    if (!mounted || createdOuting == null) {
      return;
    }

    _showSnackBar('Sortie "${createdOuting.title}" créée.');
    await _refresh();
  }

  String _formatScheduledFor(DateTime? scheduledFor) {
    if (scheduledFor == null) {
      return 'Date non définie';
    }

    final date = scheduledFor.toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return 'Prévue le $day/$month/${date.year} à $hour:$minute';
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorties'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<_OutingsData>(
            future: _futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                final error = snapshot.error;
                return _OutingsError(
                  message: error is _OutingsLoadException
                      ? error.message
                      : 'Impossible de charger les sorties pour le moment.',
                  onRetry: _refresh,
                );
              }

              final data = snapshot.data ?? const _OutingsData();
              final outings = data.outings;

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed:
                            (data.users.isEmpty || data.activities.isEmpty)
                            ? null
                            : () => _openCreateFlow(data),
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Créer une sortie',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (data.users.isEmpty)
                      _EmptyUsersHint(onRetry: _refresh)
                    else if (data.activities.isEmpty)
                      _EmptyActivitiesHint(onRetry: _refresh)
                    else if (outings.isEmpty)
                      _EmptyOutingsState(onCreate: () => _openCreateFlow(data))
                    else
                      ...outings.map(
                        (outing) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PlannedOutingCard(
                            outing: outing,
                            scheduledForLabel: _formatScheduledFor(
                              outing.scheduledFor,
                            ),
                            createdAtLabel: _formatCreatedAt(outing.createdAt),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: CrazerColors.lime),
        const SizedBox(width: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent
            ? CrazerColors.lime.withValues(alpha: 0.16)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: accent ? CrazerColors.lime : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyVisualHint extends StatelessWidget {
  const _EmptyVisualHint({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ActivityVisualItem extends StatelessWidget {
  const _ActivityVisualItem({
    required this.title,
    required this.time,
    required this.isLast,
  });

  final String title;
  final String time;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: CrazerColors.lime,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 34,
                  color: CrazerColors.lime.withValues(alpha: 0.4),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: CrazerColors.lime.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    time.isEmpty ? '—:—' : time,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyOutingsState extends StatelessWidget {
  const _EmptyOutingsState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'Aucune sortie planifiée',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Crée une sortie avec un titre, des amis participants, une date et des activités.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Créer la première sortie'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyUsersHint extends StatelessWidget {
  const _EmptyUsersHint({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'Aucun utilisateur disponible',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'La liste des profils Supabase est vide pour le moment.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Rafraîchir'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivitiesHint extends StatelessWidget {
  const _EmptyActivitiesHint({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_note_outlined, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'Aucune activité disponible',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'La table activities doit contenir au moins une activité pour créer une sortie liée.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Rafraîchir'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutingsError extends StatelessWidget {
  const _OutingsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 56, color: scheme.error),
          const SizedBox(height: 16),
          Text(
            'Impossible de charger les sorties',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _OutingsData {
  const _OutingsData({
    this.outings = const <PlannedOuting>[],
    this.users = const <PlannedOutingUser>[],
    this.activities = const <Activity>[],
  });

  final List<PlannedOuting> outings;
  final List<PlannedOutingUser> users;
  final List<Activity> activities;
}

class _OutingsLoadException implements Exception {
  const _OutingsLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}
