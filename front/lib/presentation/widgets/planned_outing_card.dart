import 'package:flutter/material.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/styles/colors.dart';

class PlannedOutingCard extends StatelessWidget {
  const PlannedOutingCard({
    super.key,
    required this.outing,
    required this.createdAtLabel,
  });

  final PlannedOuting outing;
  final String createdAtLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outing.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        createdAtLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.event_available_outlined,
                  color: CrazerColors.lime,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Utilisateurs',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: outing.users.isEmpty
                  ? const <Widget>[Chip(label: Text('Aucun utilisateur'))]
                  : outing.users
                        .map(
                          (user) => Chip(
                            avatar: CircleAvatar(
                              child: Text(_initials(user.name)),
                            ),
                            label: Text(user.name),
                          ),
                        )
                        .toList(growable: false),
            ),
            const SizedBox(height: 16),
            Text(
              'Activités avec horaire',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (outing.activities.isEmpty)
              const Text('Aucune activité renseignée')
            else
              Column(
                children: [
                  for (final activity in outing.activities)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 85,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: CrazerColors.lime.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              activity.time.isEmpty
                                  ? '—:—'
                                  : activity.time.replaceAll(' ', '\n'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              activity.title,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    String initial(String value) =>
        value.isEmpty ? '?' : value[0].toUpperCase();
    if (parts.length == 1) return initial(parts.first);
    return '${initial(parts.first)}${initial(parts.last)}';
  }
}
