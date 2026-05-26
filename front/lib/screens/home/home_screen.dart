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

  late Future<_HomeData> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _loadData();
  }

  Future<_HomeData> _loadData() async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      final results = await Future.wait([
        _activityService.fetchActivities(),
        _plannedOutingService.fetchPlannedOutings(
          currentUserId: currentUserId ?? '',
        ),
      ]);

      return _HomeData(
        activities: results[0] as List<Activity>,
        plannedOutings: results[1] as List<PlannedOuting>,
        currentUserId: currentUserId,
      );
    } on PostgrestException catch (error) {
      throw _ActivityLoadException(error.message);
    } catch (_) {
      throw const _ActivityLoadException(
        'Erreur inattendue lors du chargement des activités.',
      );
    }
  }

  Future<void> _retryLoad() async {
    setState(() {
      _homeDataFuture = _loadData();
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
          child: FutureBuilder<_HomeData>(
            future: _homeDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _HomeScreenLoading();
              }

              if (snapshot.hasError) {
                final error = snapshot.error;
                return _HomeScreenError(
                  message: error is _ActivityLoadException
                      ? error.message
                      : 'Impossible de charger les activités pour le moment.',
                  onRetry: _retryLoad,
                );
              }

              final data = snapshot.data ?? const _HomeData();
              final activities = data.activities;
              if (activities.isEmpty) {
                return _HomeScreenEmpty(onRetry: _retryLoad);
              }

              final items = activities
                  .map((activity) => activity.toCarouselItem())
                  .toList(growable: false);

              final plannedOutingItems = resolvePlannedOutingCarouselItems(
                plannedOutings: data.plannedOutings,
                activities: activities,
                userId: data.currentUserId,
              );

              return ListView(
                children: [
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
