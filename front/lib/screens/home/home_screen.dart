import 'package:flutter/material.dart';
import 'package:front/commons.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/main.dart';
import 'package:front/models/activity_model.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/services/activity_service.dart';
import 'package:front/services/planned_outing_service.dart';
import 'package:front/utils/planned_outings_helper.dart';
import 'package:front/widgets/home_carousel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _activityService = const ActivityService();
  final _plannedOutingService = const PlannedOutingService();

  _HomeData? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      final results = await Future.wait([
        _activityService.fetchActivities(),
        _plannedOutingService.fetchPlannedOutings(
          currentUserId: currentUserId ?? '',
        ),
      ]);

      if (mounted) {
        setState(() {
          _data = _HomeData(
            activities: results[0] as List<Activity>,
            plannedOutings: results[1] as List<PlannedOuting>,
            currentUserId: currentUserId,
          );
          _isLoading = false;
        });
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Erreur inattendue lors du chargement des activités.';
          _isLoading = false;
        });
      }
    }
  }

  void _handleStatusChanged(String outingId, String newStatus) {
    if (_data == null) return;

    final currentUserId = _data!.currentUserId ?? '';
    
    final updatedOutings = _data!.plannedOutings.map((outing) {
      if (outing.id == outingId) {
        final updatedUsers = outing.users.map((user) {
          if (user.id == currentUserId) {
            return PlannedOutingUser(
              id: user.id,
              name: user.name,
              status: newStatus,
            );
          }
          return user;
        }).toList(growable: false);

        return PlannedOuting(
          id: outing.id,
          title: outing.title,
          users: updatedUsers,
          activities: outing.activities,
          createdAt: outing.createdAt,
        );
      }
      return outing;
    }).toList(growable: false);

    setState(() {
      _data = _HomeData(
        activities: _data!.activities,
        plannedOutings: updatedOutings,
        currentUserId: _data!.currentUserId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil'), centerTitle: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Builder(
            builder: (context) {
              if (_isLoading && _data == null) {
                return const _HomeScreenLoading();
              }

              if (_error != null && _data == null) {
                return _HomeScreenError(
                  message: _error!,
                  onRetry: _loadData,
                );
              }

              final data = _data ?? const _HomeData();
              final activities = data.activities;
              if (activities.isEmpty && !_isLoading) {
                return _HomeScreenEmpty(onRetry: _loadData);
              }

              final items = activities
                  .map((activity) => activity.toCarouselItem())
                  .toList(growable: false);

              final userId = data.currentUserId ?? '';
              final acceptedOutings = data.plannedOutings
                  .where((o) => o.isUserAccepted(userId))
                  .toList(growable: false);
              final pendingOutings = data.plannedOutings
                  .where((o) => o.isUserPending(userId))
                  .toList(growable: false);

              final plannedOutingItems = resolvePlannedOutingCarouselItems(
                plannedOutings: acceptedOutings,
                activities: activities,
                userId: userId,
              );

              return ListView(
                children: [
                  _PendingOutingsSection(
                    pendingOutings: pendingOutings,
                    onStatusChanged: _handleStatusChanged,
                  ),
                  HomeCarousel(
                    title: localizations.activitiesDiscoverTitle,
                    subtitle: localizations.activitiesDiscoverSubtitle,
                    items: items,
                  ),
                  const SizedBox(height: 24),
                  if (plannedOutingItems.isNotEmpty)
                    HomeCarousel(
                      title: localizations.activitiesPlannedTitle,
                      subtitle: localizations.activitiesPlannedSubtitle,
                      items: plannedOutingItems,
                    )
                  else
                    const _PlannedOutingsEmptyCard(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeScreenLoading extends StatelessWidget {
  const _HomeScreenLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _HomeScreenEmpty extends StatelessWidget {
  const _HomeScreenEmpty({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore_outlined, size: 56, color: scheme.primary),
          const SizedBox(height: 16),
          Text(
            localizations.activitiesEmptyTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.activitiesEmptyMessage,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(localizations.retry),
          ),
        ],
      ),
    );
  }
}

class _HomeScreenError extends StatelessWidget {
  const _HomeScreenError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 56, color: scheme.error),
          const SizedBox(height: 16),
          Text(
            localizations.activitiesLoadErrorTitle,
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
            label: Text(localizations.retry),
          ),
        ],
      ),
    );
  }
}

class _ActivityLoadException implements Exception {
  const _ActivityLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _HomeData {
  const _HomeData({
    this.activities = const <Activity>[],
    this.plannedOutings = const <PlannedOuting>[],
    this.currentUserId,
  });

  final List<Activity> activities;
  final List<PlannedOuting> plannedOutings;
  final String? currentUserId;
}

class _PlannedOutingsEmptyCard extends StatelessWidget {
  const _PlannedOutingsEmptyCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sorties planifiées',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune sortie n’est encore planifiée. Va dans l’onglet Sorties pour en créer une.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingOutingsSection extends StatelessWidget {
  const _PendingOutingsSection({
    required this.pendingOutings,
    required this.onStatusChanged,
  });

  final List<PlannedOuting> pendingOutings;
  final void Function(String outingId, String newStatus) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    if (pendingOutings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invitations en attente',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...pendingOutings.map((outing) => _PendingOutingCard(
          outing: outing,
          onStatusChanged: onStatusChanged,
        )),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _PendingOutingCard extends StatefulWidget {
  const _PendingOutingCard({
    required this.outing,
    required this.onStatusChanged,
  });

  final PlannedOuting outing;
  final void Function(String outingId, String newStatus) onStatusChanged;

  @override
  State<_PendingOutingCard> createState() => _PendingOutingCardState();
}

class _PendingOutingCardState extends State<_PendingOutingCard> {
  final _service = const PlannedOutingService();
  bool _isLoading = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await _service.updateParticipantStatus(
          outingId: widget.outing.id,
          userId: userId,
          status: status,
        );
        widget.onStatusChanged(widget.outing.id, status);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mail_outline, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.outing.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.outing.summaryText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _updateStatus('declined'),
                    child: const Text('Refuser'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _updateStatus('accepted'),
                    child: const Text('Accepter'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
