import 'package:flutter/material.dart';
import 'package:front/commons.dart';
import 'package:front/models/activity_model.dart';
import 'package:front/services/activity_service.dart';
import 'package:front/widgets/home_carousel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _activityService = const ActivityService();

  late Future<List<Activity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _loadActivities();
  }

  Future<List<Activity>> _loadActivities() async {
    try {
      return await _activityService.fetchActivities();
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
      _activitiesFuture = _loadActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: FutureBuilder<List<Activity>>(
            future: _activitiesFuture,
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

              final activities = snapshot.data ?? const <Activity>[];
              if (activities.isEmpty) {
                return _HomeScreenEmpty(onRetry: _retryLoad);
              }

              final items = activities
                  .map((activity) => activity.toCarouselItem())
                  .toList(growable: false);

              return ListView(
                children: [
                  HomeCarousel(
                    title: 'Activités à découvrir',
                    subtitle: 'Trouvez quoi faire maintenant',
                    items: items,
                  ),
                  const SizedBox(height: 24),
                  HomeCarousel(
                    title: 'Sorties planifiées',
                    subtitle: 'Vos prochaines sorties à venir',
                    items: _plannedOutingsItems,
                  ),
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

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore_outlined, size: 56, color: scheme.primary),
          const SizedBox(height: 16),
          Text(
            'Aucune activité disponible',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Reviens un peu plus tard ou relance le chargement.',
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

class _HomeScreenError extends StatelessWidget {
  const _HomeScreenError({required this.message, required this.onRetry});

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
            'Impossible de charger les activités',
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

class _ActivityLoadException implements Exception {
  const _ActivityLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}

const List<HomeCarouselItem> _plannedOutingsItems = [
  HomeCarouselItem(
    title: 'Samedi · 14:00',
    subtitle: 'Visite du centre historique et cafe sur la place principale.',
    badge: 'Prevu',
    icon: Icons.event_available_outlined,
    tone: HomeCarouselTone.planned,
  ),
  HomeCarouselItem(
    title: 'Dimanche · 09:30',
    subtitle: 'Petite randonnee au lever du soleil avec vue sur la vallee.',
    badge: 'Reserve',
    icon: Icons.hiking_outlined,
    tone: HomeCarouselTone.hiking,
  ),
  HomeCarouselItem(
    title: 'Mardi · 19:00',
    subtitle: 'Diner entre amis dans le nouveau restaurant du quartier.',
    badge: 'Confirme',
    icon: Icons.dinner_dining_outlined,
    tone: HomeCarouselTone.dinner,
  ),
  HomeCarouselItem(
    title: 'Jeudi · 16:30',
    subtitle: 'Sortie detente : balade au bord de l eau et photo stop.',
    badge: 'A venir',
    icon: Icons.water_outlined,
    tone: HomeCarouselTone.water,
  ),
];
